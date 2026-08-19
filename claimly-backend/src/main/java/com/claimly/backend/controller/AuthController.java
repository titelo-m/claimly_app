package com.claimly.backend.controller;

import com.claimly.backend.dto.request.*;
import com.claimly.backend.dto.response.AuthResponse;
import com.claimly.backend.dto.response.UserProfileResponse;
import com.claimly.backend.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {
    
    private final AuthService authService;
    
    public AuthController(AuthService authService) {
        this.authService = authService;
    }
    
    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }
    
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }
    
    @PostMapping("/google")
    public ResponseEntity<AuthResponse> googleLogin(@Valid @RequestBody GoogleLoginRequest request) {
        return ResponseEntity.ok(authService.googleLogin(request));
    }
    
    @PostMapping("/otp/send")
    public ResponseEntity<String> sendOTP(@RequestParam String phoneNumber) {
        authService.sendOTP(phoneNumber);
        return ResponseEntity.ok("OTP sent successfully");
    }
    
    @PostMapping("/otp/send-email")
    public ResponseEntity<String> sendEmailOTP(@RequestParam String email) {
        authService.sendEmailOTP(email);
        return ResponseEntity.ok("OTP sent to email successfully");
    }
    
    @PostMapping("/otp/verify")
    public ResponseEntity<Boolean> verifyOTP(@Valid @RequestBody OTPRequest request) {
        return ResponseEntity.ok(authService.verifyOTP(request));
    }
    
    @GetMapping("/me")
    public ResponseEntity<UserProfileResponse> getCurrentUser(@RequestHeader("Authorization") String authHeader) {
        String token = authHeader.substring(7);
        return ResponseEntity.ok(authService.getCurrentUser(token));
    }
}