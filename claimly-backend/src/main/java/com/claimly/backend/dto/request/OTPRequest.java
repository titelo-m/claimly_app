package com.claimly.backend.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

/**
 * Request body for OTP verification.
 * Supports two verification methods:
 *  - method="email"  -> email must be set, otp was sent via sendEmailOTP
 *  - method="phone"  -> phoneNumber must be set, otp was sent via sendOTP
 * phoneNumber/email are intentionally NOT @NotBlank here because only one
 * of them is required, depending on "method". That combination is validated
 * in AuthService.verifyOTP() instead of via annotations.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class OTPRequest {

    @Pattern(regexp = "^[0-9]{10}$", message = "Phone number must be exactly 10 digits")
    private String phoneNumber;

    @Email(message = "Please enter a valid email address")
    private String email;

    @NotBlank(message = "OTP code is required")
    @Pattern(regexp = "^[0-9]{6}$", message = "OTP must be exactly 6 digits")
    private String otpCode;

    /** "email" or "phone". Defaults to "phone" for backwards compatibility. */
    private String method = "phone";
}
