package com.claimly.backend.controller;

import com.claimly.backend.dto.request.UpdateNotificationPreferencesRequest;
import com.claimly.backend.dto.request.UpdatePayoutRequest;
import com.claimly.backend.dto.response.UserProfileResponse;
import com.claimly.backend.service.ProfileService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/profile")
@CrossOrigin(origins = "*")
public class ProfileController {
    
    private final ProfileService profileService;
    
    public ProfileController(ProfileService profileService) {
        this.profileService = profileService;
    }
    
    @GetMapping
    public ResponseEntity<UserProfileResponse> getProfile(@RequestHeader("Authorization") String authHeader) {
        String token = authHeader.substring(7);
        return ResponseEntity.ok(profileService.getProfile(token));
    }
    
    @PutMapping("/payout")
    public ResponseEntity<UserProfileResponse> updatePayout(
            @RequestHeader("Authorization") String authHeader,
            @Valid @RequestBody UpdatePayoutRequest request) {
        String token = authHeader.substring(7);
        return ResponseEntity.ok(profileService.updatePayout(token, request));
    }
    
    @PutMapping("/notifications")
    public ResponseEntity<Void> updateNotificationPreferences(
            @RequestHeader("Authorization") String authHeader,
            @Valid @RequestBody UpdateNotificationPreferencesRequest request) {
        String token = authHeader.substring(7);
        profileService.updateNotificationPreferences(token, request);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/picture")
    public ResponseEntity<UserProfileResponse> uploadProfilePicture(
            @RequestHeader("Authorization") String authHeader,
            @RequestParam("file") MultipartFile file) {
        String token = authHeader.substring(7);
        return ResponseEntity.ok(profileService.uploadProfilePicture(token, file));
    }
}