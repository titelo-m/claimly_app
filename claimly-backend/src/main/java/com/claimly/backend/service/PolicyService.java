package com.claimly.backend.service;

import com.claimly.backend.dto.request.CoverSelectionRequest;
import com.claimly.backend.dto.response.UserProfileResponse;
import com.claimly.backend.entity.Policy;
import com.claimly.backend.entity.User;
import com.claimly.backend.entity.enums.PolicyStatus;
import com.claimly.backend.repository.PolicyRepository;
import com.claimly.backend.repository.UserRepository;
import com.claimly.backend.security.JwtService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Service
public class PolicyService {
    
    private final UserRepository userRepository;
    private final PolicyRepository policyRepository;
    private final JwtService jwtService;
    private final EmailService emailService;
    
    public PolicyService(UserRepository userRepository, PolicyRepository policyRepository,
                          JwtService jwtService, EmailService emailService) {
        this.userRepository = userRepository;
        this.policyRepository = policyRepository;
        this.jwtService = jwtService;
        this.emailService = emailService;
    }
    
    /**
     * A user choosing cover no longer activates it immediately - it goes to
     * PENDING and an admin/super-admin must approve it (see approveCover()
     * below) before it becomes ACTIVE. This matches the same
     * submit-then-approve pattern used for account registration.
     */
    @Transactional
    public UserProfileResponse selectCover(String token, CoverSelectionRequest request) {
        String email = jwtService.extractUsername(token);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (user.getStatus() != com.claimly.backend.entity.enums.UserStatus.ACTIVE) {
            if (user.getStatus() == com.claimly.backend.entity.enums.UserStatus.PENDING_APPROVAL) {
                throw new RuntimeException("Your account is still pending approval. You'll be able to choose cover once an admin approves it.");
            }
            throw new RuntimeException("Your account can't select cover right now. Please contact support.");
        }
        
        if (!isValidProductTier(request.getProductType(), request.getTier())) {
            throw new RuntimeException("Invalid product or tier combination");
        }
        
        BigDecimal premium = getPremium(request.getProductType(), request.getTier());
        BigDecimal benefit = getBenefit(request.getProductType(), request.getTier());
        String benefitDetails = getBenefitDetails(request.getProductType(), request.getTier());
        
        Policy policy = policyRepository.findByUser(user).orElse(new Policy());
        policy.setUser(user);
        policy.setProductType(request.getProductType());
        policy.setTier(request.getTier());
        policy.setMonthlyPremium(premium);
        policy.setBenefitAmount(benefit);
        policy.setBenefitDetails(benefitDetails);
        policy.setPaymentMethod(request.getPaymentMethod());
        policy.setPolicyNumber(generatePolicyNumber());
        policy.setStartDate(LocalDateTime.now());
        policy.setWaitingPeriodEnds(LocalDateTime.now().plusMonths(9));
        policy.setNextDebitDate(LocalDateTime.now().plusMonths(1));
        policy.setStatus(PolicyStatus.PENDING);
        
        policy = policyRepository.save(policy);
        user.setPolicy(policy);
        userRepository.save(user);

        emailService.sendCoverSubmittedEmail(user.getEmail(), user.getFullName(),
                policy.getProductType(), policy.getTier());
        
        return buildProfileResponse(user);
    }
    
    public UserProfileResponse getCurrentPolicy(String token) {
        String email = jwtService.extractUsername(token);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return buildProfileResponse(user);
    }

    /** Admin/Super Admin only - moves a PENDING policy to ACTIVE and emails the customer. */
    @Transactional
    public void approveCover(Long policyId) {
        Policy policy = policyRepository.findById(policyId)
                .orElseThrow(() -> new RuntimeException("Policy not found"));

        if (policy.getStatus() != PolicyStatus.PENDING) {
            throw new RuntimeException("Only pending cover can be approved");
        }

        policy.setStatus(PolicyStatus.ACTIVE);
        policyRepository.save(policy);

        User user = policy.getUser();
        emailService.sendCoverApprovedEmail(user.getEmail(), user.getFullName(),
                policy.getProductType(), policy.getTier(), policy.getPolicyNumber());
    }

    public java.util.List<com.claimly.backend.dto.response.PendingPolicyResponse> getPendingPolicies() {
        return policyRepository.findByStatus(PolicyStatus.PENDING).stream()
                .map(p -> com.claimly.backend.dto.response.PendingPolicyResponse.builder()
                        .id(p.getId())
                        .userId(p.getUser().getId())
                        .userFullName(p.getUser().getFullName())
                        .userEmail(p.getUser().getEmail())
                        .productType(p.getProductType())
                        .tier(p.getTier())
                        .monthlyPremium(p.getMonthlyPremium())
                        .paymentMethod(p.getPaymentMethod())
                        .submittedAt(p.getCreatedAt())
                        .build())
                .collect(java.util.stream.Collectors.toList());
    }
    
    private boolean isValidProductTier(String productType, String tier) {
        return (productType.equals("Income Protection") || productType.equals("Excess Fee Cover")) &&
                (tier.equals("BRONZE") || tier.equals("SILVER") || tier.equals("GOLD"));
    }
    
    private BigDecimal getPremium(String productType, String tier) {
        if (productType.equals("Income Protection")) {
            return switch (tier) {
                case "BRONZE" -> BigDecimal.valueOf(99);
                case "SILVER" -> BigDecimal.valueOf(189);
                case "GOLD" -> BigDecimal.valueOf(329);
                default -> BigDecimal.valueOf(99);
            };
        } else {
            return switch (tier) {
                case "BRONZE" -> BigDecimal.valueOf(79);
                case "SILVER" -> BigDecimal.valueOf(149);
                case "GOLD" -> BigDecimal.valueOf(259);
                default -> BigDecimal.valueOf(79);
            };
        }
    }
    
    private BigDecimal getBenefit(String productType, String tier) {
        if (productType.equals("Income Protection")) {
            return switch (tier) {
                case "BRONZE" -> BigDecimal.valueOf(2500);
                case "SILVER" -> BigDecimal.valueOf(5000);
                case "GOLD" -> BigDecimal.valueOf(9000);
                default -> BigDecimal.valueOf(2500);
            };
        } else {
            return switch (tier) {
                case "BRONZE" -> BigDecimal.valueOf(3500);
                case "SILVER" -> BigDecimal.valueOf(7500);
                case "GOLD" -> BigDecimal.valueOf(15000);
                default -> BigDecimal.valueOf(3500);
            };
        }
    }
    
    private String getBenefitDetails(String productType, String tier) {
        if (productType.equals("Income Protection")) {
            return switch (tier) {
                case "BRONZE" -> "Up to 3 monthly payouts";
                case "SILVER" -> "Up to 6 monthly payouts";
                case "GOLD" -> "Up to 9 monthly payouts";
                default -> "Up to 3 monthly payouts";
            };
        } else {
            return switch (tier) {
                case "BRONZE" -> "1 excess payout per 12 months";
                case "SILVER" -> "2 excess payouts per 12 months";
                case "GOLD" -> "Unlimited excess payouts per 12 months";
                default -> "1 excess payout per 12 months";
            };
        }
    }
    
    private String generatePolicyNumber() {
        return "POL-" + System.currentTimeMillis();
    }
    
    private UserProfileResponse buildProfileResponse(User user) {
        Policy policy = user.getPolicy();
        return UserProfileResponse.builder()
                .fullName(user.getFullName())
                .idNumber(user.getIdNumber())
                .phoneNumber(user.getPhoneNumber())
                .email(user.getEmail())
                .role(user.getRole().name())
                .status(user.getStatus().name())
                .hasCover(policy != null)
                .productType(policy != null ? policy.getProductType() : null)
                .tier(policy != null ? policy.getTier() : null)
                .paymentMethod(policy != null ? policy.getPaymentMethod() : null)
                .monthlyPremium(policy != null ? policy.getMonthlyPremium() : null)
                .benefitAmount(policy != null ? policy.getBenefitAmount() : null)
                .benefitDetails(policy != null ? policy.getBenefitDetails() : null)
                .nextDebitDate(policy != null ? policy.getNextDebitDate() : null)
                .waitingPeriodEnds(policy != null ? policy.getWaitingPeriodEnds() : null)
                .policyStatus(policy != null ? policy.getStatus().name() : null)
                .build();
    }
}
