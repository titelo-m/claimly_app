package com.claimly.backend.service;

import com.claimly.backend.dto.request.ClaimVerifyRequest;
import com.claimly.backend.dto.response.AdminSummaryResponse;
import com.claimly.backend.entity.User;
import com.claimly.backend.entity.enums.UserRole;
import com.claimly.backend.entity.enums.UserStatus;
import com.claimly.backend.repository.UserRepository;
import com.claimly.backend.security.JwtService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * SUPER_ADMIN-only powers: promoting customers to admin (and demoting them
 * back), suspending admin accounts (an ADMIN cannot suspend another ADMIN -
 * only a SUPER_ADMIN can), and verifying (approving/declining) claims.
 */
@Service
public class SuperAdminService {

    private final UserRepository userRepository;
    private final ClaimService claimService;
    private final JwtService jwtService;
    private final EmailService emailService;

    public SuperAdminService(UserRepository userRepository, ClaimService claimService,
                              JwtService jwtService, EmailService emailService) {
        this.userRepository = userRepository;
        this.claimService = claimService;
        this.jwtService = jwtService;
        this.emailService = emailService;
    }

    public List<AdminSummaryResponse> getAllAdmins() {
        return userRepository.findAll().stream()
                .filter(u -> u.getRole() == UserRole.ADMIN || u.getRole() == UserRole.SUPER_ADMIN)
                .map(u -> AdminSummaryResponse.builder()
                        .id(u.getId())
                        .fullName(u.getFullName())
                        .email(u.getEmail())
                        .role(u.getRole().name())
                        .status(u.getStatus().name())
                        .createdAt(u.getCreatedAt())
                        .lastLogin(u.getLastLogin())
                        .build())
                .collect(Collectors.toList());
    }

    @Transactional
    public void promoteToAdmin(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        if (user.getRole() != UserRole.CUSTOMER) {
            throw new RuntimeException("Only a customer account can be promoted to admin");
        }
        user.setRole(UserRole.ADMIN);
        user.setStatus(UserStatus.ACTIVE);
        userRepository.save(user);
        emailService.sendPromotedToAdminEmail(user.getEmail(), user.getFullName());
    }

    /** Reverses promoteToAdmin - only works on ADMIN accounts, never on another SUPER_ADMIN. */
    @Transactional
    public void demoteToCustomer(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        if (user.getRole() != UserRole.ADMIN) {
            throw new RuntimeException("Only ADMIN accounts can be demoted here - not other super admins");
        }
        user.setRole(UserRole.CUSTOMER);
        userRepository.save(user);
        emailService.sendDemotedToCustomerEmail(user.getEmail(), user.getFullName());
    }

    @Transactional
    public void suspendAdmin(Long adminId, String actingToken) {
        User admin = userRepository.findById(adminId)
                .orElseThrow(() -> new RuntimeException("Admin not found"));
        if (admin.getRole() != UserRole.ADMIN) {
            throw new RuntimeException("Only ADMIN accounts can be suspended here - not other super admins");
        }
        admin.setStatus(UserStatus.SUSPENDED);
        userRepository.save(admin);
        emailService.sendAccountSuspendedEmail(admin.getEmail(), admin.getFullName());
    }

    @Transactional
    public void reactivateAdmin(Long adminId) {
        User admin = userRepository.findById(adminId)
                .orElseThrow(() -> new RuntimeException("Admin not found"));
        if (admin.getRole() != UserRole.ADMIN) {
            throw new RuntimeException("Only ADMIN accounts can be reactivated here");
        }
        admin.setStatus(UserStatus.ACTIVE);
        userRepository.save(admin);
    }

    public void verifyClaim(Long claimId, ClaimVerifyRequest request, String actingToken) {
        String email = jwtService.extractUsername(actingToken);
        User reviewer = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        claimService.verifyClaim(claimId, request.isApprove(), request.getDeclineReason(), reviewer.getFullName());
    }

    public void markClaimAsPaid(Long claimId, com.claimly.backend.dto.request.ClaimPayoutRequest request, String actingToken) {
        String email = jwtService.extractUsername(actingToken);
        User reviewer = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        claimService.markAsPaid(claimId, request.getPayoutAmount(), request.getPayoutReference(), reviewer.getFullName());
    }
}
