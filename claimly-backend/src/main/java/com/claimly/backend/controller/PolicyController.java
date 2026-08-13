package com.claimly.backend.controller;

import com.claimly.backend.dto.request.CoverSelectionRequest;
import com.claimly.backend.dto.response.UserProfileResponse;
import com.claimly.backend.service.PolicyService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/policy")
@CrossOrigin(origins = "*")
public class PolicyController {
    
    private final PolicyService policyService;
    
    public PolicyController(PolicyService policyService) {
        this.policyService = policyService;
    }
    
    @PostMapping("/select")
    public ResponseEntity<UserProfileResponse> selectCover(
            @RequestHeader("Authorization") String authHeader,
            @Valid @RequestBody CoverSelectionRequest request) {
        String token = authHeader.substring(7);
        return ResponseEntity.ok(policyService.selectCover(token, request));
    }
    
    @GetMapping("/current")
    public ResponseEntity<UserProfileResponse> getCurrentPolicy(@RequestHeader("Authorization") String authHeader) {
        String token = authHeader.substring(7);
        return ResponseEntity.ok(policyService.getCurrentPolicy(token));
    }
}