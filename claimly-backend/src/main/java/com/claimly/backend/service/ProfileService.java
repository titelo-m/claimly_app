package com.claimly.backend.service;

import com.claimly.backend.dto.request.UpdateNotificationPreferencesRequest;
import com.claimly.backend.dto.request.UpdatePayoutRequest;
import com.claimly.backend.dto.response.UserDocumentResponse;
import com.claimly.backend.dto.response.UserProfileResponse;
import com.claimly.backend.entity.NotificationPreference;
import com.claimly.backend.entity.Policy;
import com.claimly.backend.entity.User;
import com.claimly.backend.entity.UserDocument;
import com.claimly.backend.repository.NotificationPreferenceRepository;
import com.claimly.backend.repository.PolicyRepository;
import com.claimly.backend.repository.UserDocumentRepository;
import com.claimly.backend.repository.UserRepository;
import com.claimly.backend.security.JwtService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class ProfileService {
    
    private final UserRepository userRepository;
    private final PolicyRepository policyRepository;
    private final NotificationPreferenceRepository notificationPreferenceRepository;
    private final UserDocumentRepository userDocumentRepository;
    private final JwtService jwtService;

    private static final List<String> ALLOWED_IMAGE_TYPES =
            List.of("image/jpeg", "image/png", "image/webp");
    private static final long MAX_IMAGE_SIZE_BYTES = 5 * 1024 * 1024; // 5MB
    
    public ProfileService(UserRepository userRepository,
                          PolicyRepository policyRepository,
                          NotificationPreferenceRepository notificationPreferenceRepository,
                          UserDocumentRepository userDocumentRepository,
                          JwtService jwtService) {
        this.userRepository = userRepository;
        this.policyRepository = policyRepository;
        this.notificationPreferenceRepository = notificationPreferenceRepository;
        this.userDocumentRepository = userDocumentRepository;
        this.jwtService = jwtService;
    }
    
    public UserProfileResponse getProfile(String token) {
        String email = jwtService.extractUsername(token);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return buildProfileResponse(user);
    }
    
    @Transactional
    public UserProfileResponse updatePayout(String token, UpdatePayoutRequest request) {
        String email = jwtService.extractUsername(token);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        Policy policy = user.getPolicy();
        if (policy == null) {
            throw new RuntimeException("No active policy found");
        }
        
        policy.setAccountNumber(request.getAccountNumber());
        policy = policyRepository.save(policy);
        
        return buildProfileResponse(user);
    }
    
    @Transactional
    public void updateNotificationPreferences(String token, UpdateNotificationPreferencesRequest request) {
        String email = jwtService.extractUsername(token);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        NotificationPreference preferences = notificationPreferenceRepository.findByUser(user)
                .orElse(new NotificationPreference());
        
        preferences.setUser(user);
        preferences.setClaimUpdates(request.isClaimUpdates());
        preferences.setPaymentReminders(request.isPaymentReminders());
        preferences.setGeneralAnnouncements(request.isGeneralAnnouncements());
        
        notificationPreferenceRepository.save(preferences);
    }

    @Transactional
    public UserProfileResponse uploadProfilePicture(String token, MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new RuntimeException("Please choose an image to upload");
        }
        if (!ALLOWED_IMAGE_TYPES.contains(file.getContentType())) {
            throw new RuntimeException("Only JPG, PNG or WEBP images are allowed");
        }
        if (file.getSize() > MAX_IMAGE_SIZE_BYTES) {
            throw new RuntimeException("Image must be smaller than 5MB");
        }

        String email = jwtService.extractUsername(token);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        try {
            Path uploadDir = Paths.get("uploads", "profile-pictures");
            Files.createDirectories(uploadDir);

            String originalName = file.getOriginalFilename();
            String extension = "";
            if (originalName != null && originalName.contains(".")) {
                extension = originalName.substring(originalName.lastIndexOf('.'));
            }
            String filename = "user-" + user.getId() + "-" + UUID.randomUUID() + extension;
            Path destination = uploadDir.resolve(filename);

            Files.copy(file.getInputStream(), destination, StandardCopyOption.REPLACE_EXISTING);

            user.setProfilePictureUrl("/uploads/profile-pictures/" + filename);
            user = userRepository.save(user);
        } catch (IOException e) {
            throw new RuntimeException("Failed to save profile picture: " + e.getMessage());
        }

        return buildProfileResponse(user);
    }
    
    private UserProfileResponse buildProfileResponse(User user) {
        Policy policy = user.getPolicy();
        List<UserDocumentResponse> documents = userDocumentRepository
                .findByUserOrderByUploadedAtDesc(user)
                .stream()
                .map(this::buildDocumentResponse)
                .collect(Collectors.toList());

        return UserProfileResponse.builder()
                .fullName(user.getFullName())
                .idNumber(user.getIdNumber())
                .phoneNumber(user.getPhoneNumber())
                .email(user.getEmail())
                .role(user.getRole().name())
                .status(user.getStatus().name())
                .dateOfBirth(user.getDateOfBirth())
                .gender(user.getGender())
                .employmentStatus(user.getEmploymentStatus())
                .occupation(user.getOccupation())
                .monthlyIncome(user.getMonthlyIncome())
                .nextOfKinName(user.getNextOfKinName())
                .nextOfKinPhone(user.getNextOfKinPhone())
                .profilePictureUrl(user.getProfilePictureUrl())
                .hasCover(policy != null)
                .productType(policy != null ? policy.getProductType() : null)
                .tier(policy != null ? policy.getTier() : null)
                .paymentMethod(policy != null ? policy.getPaymentMethod() : null)
                .monthlyPremium(policy != null ? policy.getMonthlyPremium() : null)
                .benefitAmount(policy != null ? policy.getBenefitAmount() : null)
                .benefitDetails(policy != null ? policy.getBenefitDetails() : null)
                .nextDebitDate(policy != null ? policy.getNextDebitDate() : null)
                .waitingPeriodEnds(policy != null ? policy.getWaitingPeriodEnds() : null)
                .documents(documents)
                .build();
    }

    private UserDocumentResponse buildDocumentResponse(UserDocument doc) {
        return UserDocumentResponse.builder()
                .id(doc.getId())
                .documentType(doc.getDocumentType().name())
                .fileName(doc.getFileName())
                .fileUrl(doc.getFileUrl())
                .fileSize(doc.getFileSize())
                .verified(doc.isVerified())
                .uploadedAt(doc.getUploadedAt())
                .build();
    }
}
