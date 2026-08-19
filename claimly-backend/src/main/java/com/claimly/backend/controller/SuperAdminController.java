package com.claimly.backend.controller;

import com.claimly.backend.dto.request.ClaimVerifyRequest;
import com.claimly.backend.dto.response.AdminSummaryResponse;
import com.claimly.backend.service.SuperAdminService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/** SUPER_ADMIN only (enforced in SecurityConfig). */
@RestController
@RequestMapping("/api/super-admin")
@CrossOrigin(origins = "*")
public class SuperAdminController {

    private final SuperAdminService superAdminService;

    public SuperAdminController(SuperAdminService superAdminService) {
        this.superAdminService = superAdminService;
    }

    @GetMapping("/admins")
    public ResponseEntity<List<AdminSummaryResponse>> getAllAdmins() {
        return ResponseEntity.ok(superAdminService.getAllAdmins());
    }

    @PutMapping("/users/{id}/promote-to-admin")
    public ResponseEntity<Void> promoteToAdmin(@PathVariable Long id) {
        superAdminService.promoteToAdmin(id);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/users/{id}/demote-to-customer")
    public ResponseEntity<Void> demoteToCustomer(@PathVariable Long id) {
        superAdminService.demoteToCustomer(id);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/admins/{id}/suspend")
    public ResponseEntity<Void> suspendAdmin(
            @PathVariable Long id,
            @RequestHeader("Authorization") String authHeader) {
        superAdminService.suspendAdmin(id, authHeader.substring(7));
        return ResponseEntity.ok().build();
    }

    @PutMapping("/admins/{id}/reactivate")
    public ResponseEntity<Void> reactivateAdmin(@PathVariable Long id) {
        superAdminService.reactivateAdmin(id);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/claims/{id}/verify")
    public ResponseEntity<Void> verifyClaim(
            @PathVariable Long id,
            @RequestHeader("Authorization") String authHeader,
            @Valid @RequestBody ClaimVerifyRequest request) {
        superAdminService.verifyClaim(id, request, authHeader.substring(7));
        return ResponseEntity.ok().build();
    }

    @PutMapping("/claims/{id}/mark-paid")
    public ResponseEntity<Void> markClaimAsPaid(
            @PathVariable Long id,
            @RequestHeader("Authorization") String authHeader,
            @Valid @RequestBody com.claimly.backend.dto.request.ClaimPayoutRequest request) {
        superAdminService.markClaimAsPaid(id, request, authHeader.substring(7));
        return ResponseEntity.ok().build();
    }
}
