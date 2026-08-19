package com.claimly.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RecordPaymentRequest {
    @NotBlank(message = "Payment method is required")
    private String paymentMethod;
}
