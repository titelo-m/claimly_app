package com.claimly.backend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AdminUserSummaryResponse {
    private Long id;
    private String fullName;
    private String email;
    private String phoneNumber;
    private String idNumber;
    private String role;
    private String status;
    private boolean hasCover;
    private String policyStatus;
    private String productType;
    private String tier;
    private int documentCount;
    private LocalDateTime createdAt;
}
