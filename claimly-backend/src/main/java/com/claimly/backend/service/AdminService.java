package com.claimly.backend.service;

import com.claimly.backend.dto.response.AdminUserDetailResponse;
import com.claimly.backend.dto.response.AdminUserSummaryResponse;
import com.claimly.backend.dto.response.UserDocumentResponse;
import com.claimly.backend.entity.Policy;
import com.claimly.backend.entity.User;
import com.claimly.backend.entity.UserDocument;
import com.claimly.backend.entity.enums.UserRole;
import com.claimly.backend.entity.enums.UserStatus;
import com.claimly.backend.repository.UserDocumentRepository;
import com.claimly.backend.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Powers the ADMIN + SUPER_ADMIN "users" screens: viewing all customers,
 * approving new registrations, and suspending/reactivating accounts.
 * Only touches CUSTOMER accounts - managing other admins is SuperAdminService's job.
 */
@Service
public class AdminService {

    private final UserRepository userRepository;
    private final UserDocumentRepository userDocumentRepository;
    private final EmailService emailService;

    public AdminService(UserRepository userRepository,
                         UserDocumentRepository userDocumentRepository,
                         EmailService emailService) {
        this.userRepository = userRepository;
        this.userDocumentRepository = userDocumentRepository;
        this.emailService = emailService;
    }

    public List<AdminUserSummaryResponse> getAllCustomers() {
        return userRepository.findAll().stream()
                .filter(u -> u.getRole() == UserRole.CUSTOMER)
                .map(this::buildSummary)
                .collect(Collectors.toList());
    }

    public AdminUserDetailResponse getCustomerDetail(Long userId) {
        User user = getCustomerOrThrow(userId);
        return buildDetail(user);
    }

    @Transactional
    public void activate(Long userId) {
        User user = getCustomerOrThrow(userId);
        boolean isFirstApproval = user.getStatus() == UserStatus.PENDING_APPROVAL;
        user.setStatus(UserStatus.ACTIVE);
        userRepository.save(user);
        if (isFirstApproval) {
            emailService.sendAccountApprovedEmail(user.getEmail(), user.getFullName());
        }
    }

    @Transactional
    public void suspend(Long userId) {
        User user = getCustomerOrThrow(userId);
        user.setStatus(UserStatus.SUSPENDED);
        userRepository.save(user);
        emailService.sendAccountSuspendedEmail(user.getEmail(), user.getFullName());
    }

    @Transactional
    public void reactivate(Long userId) {
        User user = getCustomerOrThrow(userId);
        user.setStatus(UserStatus.ACTIVE);
        userRepository.save(user);
    }

    private User getCustomerOrThrow(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        if (user.getRole() != UserRole.CUSTOMER) {
            throw new RuntimeException("This account isn't a customer account");
        }
        return user;
    }

    private AdminUserSummaryResponse buildSummary(User user) {
        Policy policy = user.getPolicy();
        int docCount = userDocumentRepository.findByUserOrderByUploadedAtDesc(user).size();
        return AdminUserSummaryResponse.builder()
                .id(user.getId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .phoneNumber(user.getPhoneNumber())
                .idNumber(user.getIdNumber())
                .role(user.getRole().name())
                .status(user.getStatus().name())
                .hasCover(policy != null)
                .policyStatus(policy != null ? policy.getStatus().name() : null)
                .productType(policy != null ? policy.getProductType() : null)
                .tier(policy != null ? policy.getTier() : null)
                .documentCount(docCount)
                .createdAt(user.getCreatedAt())
                .build();
    }

    private AdminUserDetailResponse buildDetail(User user) {
        Policy policy = user.getPolicy();
        List<UserDocumentResponse> documents = userDocumentRepository
                .findByUserOrderByUploadedAtDesc(user)
                .stream()
                .map(this::buildDocumentResponse)
                .collect(Collectors.toList());

        return AdminUserDetailResponse.builder()
                .id(user.getId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .phoneNumber(user.getPhoneNumber())
                .idNumber(user.getIdNumber())
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
                .policyStatus(policy != null ? policy.getStatus().name() : null)
                .productType(policy != null ? policy.getProductType() : null)
                .tier(policy != null ? policy.getTier() : null)
                .paymentMethod(policy != null ? policy.getPaymentMethod() : null)
                .monthlyPremium(policy != null ? policy.getMonthlyPremium() : null)
                .policyNumber(policy != null ? policy.getPolicyNumber() : null)
                .documents(documents)
                .createdAt(user.getCreatedAt())
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
