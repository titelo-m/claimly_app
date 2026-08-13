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
public class AdminClaimResponse {
    private Long id;
    private String claimReference;
    private String claimType;
    private String description;
    private String status;
    private String userFullName;
    private String userEmail;
    private LocalDateTime submittedAt;
}
