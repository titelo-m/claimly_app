package com.claimly.backend.dto.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ClaimVerifyRequest {
    private boolean approve;
    private String declineReason;
}
