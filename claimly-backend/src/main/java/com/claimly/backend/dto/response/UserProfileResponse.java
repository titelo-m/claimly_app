package com.claimly.backend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileResponse {
    private String fullName;
    private String idNumber;
    private String phoneNumber;
    private String email;
    private String role;
    private String status;

    private LocalDate dateOfBirth;
    private String gender;
    private String employmentStatus;
    private String occupation;
    private BigDecimal monthlyIncome;
    private String nextOfKinName;
    private String nextOfKinPhone;
    private String profilePictureUrl;

    private boolean hasCover;
    private String productType;
    private String tier;
    private String paymentMethod;
    private BigDecimal monthlyPremium;
    private BigDecimal benefitAmount;
    private String benefitDetails;
    private LocalDateTime nextDebitDate;
    private LocalDateTime waitingPeriodEnds;
    private String policyStatus;

    private List<UserDocumentResponse> documents;
}
