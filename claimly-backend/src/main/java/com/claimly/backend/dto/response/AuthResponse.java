package com.claimly.backend.dto.response;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    private String token;
    private String email;
    private String fullName;
    private String phoneNumber;
    private String role;
    private String status;
    private boolean hasCover;
    private String productType;
    private String tier;
    private String paymentMethod;
    private String profilePictureUrl;
}
