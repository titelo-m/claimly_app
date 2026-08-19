package com.claimly.backend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PendingPolicyResponse {
    private Long id;
    private Long userId;
    private String userFullName;
    private String userEmail;
    private String productType;
    private String tier;
    private BigDecimal monthlyPremium;
    private String paymentMethod;
    private LocalDateTime submittedAt;
}
