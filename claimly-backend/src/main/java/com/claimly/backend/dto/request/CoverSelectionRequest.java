package com.claimly.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CoverSelectionRequest {
    
    @NotBlank(message = "Product type is required")
    private String productType;
    
    @NotBlank(message = "Tier is required")
    private String tier;
    
    @NotBlank(message = "Payment method is required")
    private String paymentMethod;
}