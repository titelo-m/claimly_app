package com.claimly.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdatePayoutRequest {
    
    @NotBlank(message = "Account number is required")
    private String accountNumber;
}