package com.claimly.backend.controller;

import com.claimly.backend.dto.request.ClaimSubmitRequest;
import com.claimly.backend.dto.response.ClaimResponse;
import com.claimly.backend.dto.response.ClaimSummaryResponse;
import com.claimly.backend.service.ClaimService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/claims")
@CrossOrigin(origins = "*")
public class ClaimController {
    
    private final ClaimService claimService;
    
    public ClaimController(ClaimService claimService) {
        this.claimService = claimService;
    }
    
    @PostMapping("/submit")
    public ResponseEntity<ClaimResponse> submitClaim(
            @RequestHeader("Authorization") String authHeader,
            @Valid @RequestPart("claim") ClaimSubmitRequest request,
            @RequestPart(value = "documents", required = false) List<MultipartFile> documents) {
        String token = authHeader.substring(7);
        return ResponseEntity.ok(claimService.submitClaim(token, request, documents));
    }
    
    @GetMapping
    public ResponseEntity<List<ClaimSummaryResponse>> getClaims(@RequestHeader("Authorization") String authHeader) {
        String token = authHeader.substring(7);
        return ResponseEntity.ok(claimService.getUserClaims(token));
    }
    
    @GetMapping("/{claimReference}")
    public ResponseEntity<ClaimResponse> getClaim(
            @RequestHeader("Authorization") String authHeader,
            @PathVariable String claimReference) {
        String token = authHeader.substring(7);
        return ResponseEntity.ok(claimService.getClaimByReference(token, claimReference));
    }
}