package com.claimly.backend.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ClaimPayoutRequest {
    @NotNull(message = "Payout amount is required")
    @DecimalMin(value = "0.01", message = "Payout amount must be greater than 0")
    private BigDecimal payoutAmount;

    @NotBlank(message = "Payout reference is required")
    private String payoutReference;
}
