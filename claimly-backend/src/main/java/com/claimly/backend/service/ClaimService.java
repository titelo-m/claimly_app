package com.claimly.backend.service;

import com.claimly.backend.dto.request.ClaimSubmitRequest;
import com.claimly.backend.dto.response.ClaimResponse;
import com.claimly.backend.dto.response.ClaimSummaryResponse;
import com.claimly.backend.entity.Claim;
import com.claimly.backend.entity.ClaimDocument;
import com.claimly.backend.entity.ClaimHistory;
import com.claimly.backend.entity.User;
import com.claimly.backend.repository.ClaimRepository;
import com.claimly.backend.repository.UserRepository;
import com.claimly.backend.security.JwtService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class ClaimService {
    
    private final UserRepository userRepository;
    private final ClaimRepository claimRepository;
    private final JwtService jwtService;
    private final EmailService emailService;
    private final String UPLOAD_DIR = "uploads/claims/";
    
    public ClaimService(UserRepository userRepository, ClaimRepository claimRepository,
                         JwtService jwtService, EmailService emailService) {
        this.userRepository = userRepository;
        this.claimRepository = claimRepository;
        this.jwtService = jwtService;
        this.emailService = emailService;
        
        try {
            Files.createDirectories(Paths.get(UPLOAD_DIR));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    @Transactional
    public ClaimResponse submitClaim(String token, ClaimSubmitRequest request, List<MultipartFile> documents) {
        String email = jwtService.extractUsername(token);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        if (user.getPolicy() == null) {
            throw new RuntimeException("User has no active policy");
        }
        
        if (!isValidClaimType(request.getClaimType())) {
            throw new RuntimeException("Invalid claim type");
        }
        
        Claim claim = new Claim();
        claim.setUser(user);
        claim.setPolicy(user.getPolicy());
        claim.setClaimType(request.getClaimType());
        claim.setDescription(request.getDescription());
        claim.setClaimReference(generateClaimReference());
        
        claim = claimRepository.save(claim);
        
        ClaimHistory history = new ClaimHistory();
        history.setClaim(claim);
        history.setToStatus("SUBMITTED");
        history.setChangedBy(user.getFullName());
        history.setComment("Claim submitted by user");
        claim.getHistory().add(history);
        
        if (documents != null && !documents.isEmpty()) {
            for (MultipartFile file : documents) {
                try {
                    String fileName = saveFile(file);
                    ClaimDocument doc = new ClaimDocument();
                    doc.setClaim(claim);
                    doc.setFileName(file.getOriginalFilename());
                    doc.setFilePath(fileName);
                    doc.setFileSize(file.getSize());
                    doc.setFileType(file.getContentType());
                    claim.getDocuments().add(doc);
                } catch (IOException e) {
                    throw new RuntimeException("Failed to upload document: " + e.getMessage());
                }
            }
        }
        
        claim = claimRepository.save(claim);
        return buildClaimResponse(claim);
    }
    
    public List<ClaimSummaryResponse> getUserClaims(String token) {
        String email = jwtService.extractUsername(token);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        return claimRepository.findByUserOrderBySubmittedAtDesc(user)
                .stream()
                .map(this::buildClaimSummaryResponse)
                .collect(Collectors.toList());
    }
    
    public ClaimResponse getClaimByReference(String token, String claimReference) {
        String email = jwtService.extractUsername(token);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        Claim claim = claimRepository.findByClaimReference(claimReference)
                .orElseThrow(() -> new RuntimeException("Claim not found"));
        
        if (!claim.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("You do not have permission to view this claim");
        }
        
        return buildClaimResponse(claim);
    }

    /** Used by admin/super-admin dashboards - every claim, most recent first. */
    public List<com.claimly.backend.dto.response.AdminClaimResponse> getAllClaimsForAdmin() {
        return claimRepository.findAllByOrderBySubmittedAtDesc()
                .stream()
                .map(this::buildAdminClaimResponse)
                .collect(Collectors.toList());
    }

    /** Super-admin only: approve or decline a submitted claim. */
    @Transactional
    public void verifyClaim(Long claimId, boolean approve, String declineReason, String reviewerName) {
        Claim claim = claimRepository.findById(claimId)
                .orElseThrow(() -> new RuntimeException("Claim not found"));

        com.claimly.backend.entity.enums.ClaimStatus fromStatus = claim.getStatus();

        if (approve) {
            claim.setStatus(com.claimly.backend.entity.enums.ClaimStatus.APPROVED);
            claim.setApprovedAt(java.time.LocalDateTime.now());
        } else {
            claim.setStatus(com.claimly.backend.entity.enums.ClaimStatus.DECLINED);
            claim.setDeclineReason(declineReason != null ? declineReason : "Declined by super admin");
        }
        claim.setReviewedAt(java.time.LocalDateTime.now());

        ClaimHistory history = new ClaimHistory();
        history.setClaim(claim);
        history.setFromStatus(fromStatus.name());
        history.setToStatus(claim.getStatus().name());
        history.setChangedBy(reviewerName);
        history.setComment(approve ? "Approved by super admin" : "Declined: " + claim.getDeclineReason());
        claim.getHistory().add(history);

        claimRepository.save(claim);

        User claimant = claim.getUser();
        emailService.sendClaimDecisionEmail(claimant.getEmail(), claimant.getFullName(),
                claim.getClaimReference(), approve, claim.getDeclineReason());
    }

    /** Super-admin only: records the payout on an already-approved claim and marks it Paid. */
    @Transactional
    public void markAsPaid(Long claimId, java.math.BigDecimal payoutAmount, String payoutReference, String actorName) {
        Claim claim = claimRepository.findById(claimId)
                .orElseThrow(() -> new RuntimeException("Claim not found"));

        if (claim.getStatus() != com.claimly.backend.entity.enums.ClaimStatus.APPROVED) {
            throw new RuntimeException("Only an approved claim can be marked as paid");
        }

        com.claimly.backend.entity.enums.ClaimStatus fromStatus = claim.getStatus();
        claim.setStatus(com.claimly.backend.entity.enums.ClaimStatus.PAID);
        claim.setPayoutAmount(payoutAmount);
        claim.setPayoutReference(payoutReference);
        claim.setPaidAt(java.time.LocalDateTime.now());

        ClaimHistory history = new ClaimHistory();
        history.setClaim(claim);
        history.setFromStatus(fromStatus.name());
        history.setToStatus(claim.getStatus().name());
        history.setChangedBy(actorName);
        history.setComment("Paid out R" + payoutAmount + " · ref " + payoutReference);
        claim.getHistory().add(history);

        claimRepository.save(claim);

        User claimant = claim.getUser();
        emailService.sendClaimPaidEmail(claimant.getEmail(), claimant.getFullName(),
                claim.getClaimReference(), payoutAmount.toString(), payoutReference);
    }
    
    private String saveFile(MultipartFile file) throws IOException {
        String fileName = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();
        Path filePath = Paths.get(UPLOAD_DIR + fileName);
        Files.write(filePath, file.getBytes());
        return filePath.toString();
    }
    
    private boolean isValidClaimType(String claimType) {
        return List.of("Illness", "Injury / Accident", "Retrenchment").contains(claimType);
    }
    
    private String generateClaimReference() {
        return "CLM-" + System.currentTimeMillis();
    }
    
    private ClaimSummaryResponse buildClaimSummaryResponse(Claim claim) {
        return ClaimSummaryResponse.builder()
                .claimReference(claim.getClaimReference())
                .claimType(claim.getClaimType())
                .status(claim.getStatus().name())
                .submittedAt(claim.getSubmittedAt())
                .build();
    }
    
    private ClaimResponse buildClaimResponse(Claim claim) {
        return ClaimResponse.builder()
                .claimReference(claim.getClaimReference())
                .claimType(claim.getClaimType())
                .description(claim.getDescription())
                .status(claim.getStatus().name())
                .submittedAt(claim.getSubmittedAt())
                .updatedAt(claim.getUpdatedAt())
                .reviewedAt(claim.getReviewedAt())
                .approvedAt(claim.getApprovedAt())
                .paidAt(claim.getPaidAt())
                .declineReason(claim.getDeclineReason())
                .payoutReference(claim.getPayoutReference())
                .payoutAmount(claim.getPayoutAmount() != null ? claim.getPayoutAmount().toString() : null)
                .documents(claim.getDocuments().stream()
                        .map(doc -> ClaimResponse.ClaimDocumentResponse.builder()
                                .fileName(doc.getFileName())
                                .filePath(doc.getFilePath())
                                .fileSize(doc.getFileSize())
                                .fileType(doc.getFileType())
                                .uploadedAt(doc.getUploadedAt())
                                .verified(doc.isVerified())
                                .build())
                        .collect(Collectors.toList()))
                .history(claim.getHistory().stream()
                        .map(h -> ClaimResponse.ClaimHistoryResponse.builder()
                                .fromStatus(h.getFromStatus())
                                .toStatus(h.getToStatus())
                                .changedBy(h.getChangedBy())
                                .comment(h.getComment())
                                .changedAt(h.getChangedAt())
                                .build())
                        .collect(Collectors.toList()))
                .build();
    }

    private com.claimly.backend.dto.response.AdminClaimResponse buildAdminClaimResponse(Claim claim) {
        return com.claimly.backend.dto.response.AdminClaimResponse.builder()
                .id(claim.getId())
                .claimReference(claim.getClaimReference())
                .claimType(claim.getClaimType())
                .description(claim.getDescription())
                .status(claim.getStatus().name())
                .userFullName(claim.getUser().getFullName())
                .userEmail(claim.getUser().getEmail())
                .submittedAt(claim.getSubmittedAt())
                .payoutAmount(claim.getPayoutAmount() != null ? claim.getPayoutAmount().toString() : null)
                .payoutReference(claim.getPayoutReference())
                .paidAt(claim.getPaidAt())
                .build();
    }
}