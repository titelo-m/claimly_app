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
 * SUPER_ADMIN-only powers: promoting customers to admin, suspending admin
 * accounts (an ADMIN cannot suspend another ADMIN - only a SUPER_ADMIN can),
 * and verifying (approving/declining) claims.
 */
@Service
public class SuperAdminService {

    private final UserRepository userRepository;
    private final ClaimService claimService;
    private final JwtService jwtService;

    public SuperAdminService(UserRepository userRepository, ClaimService claimService, JwtService jwtService) {
        this.userRepository = userRepository;
        this.claimService = claimService;
        this.jwtService = jwtService;
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
}
