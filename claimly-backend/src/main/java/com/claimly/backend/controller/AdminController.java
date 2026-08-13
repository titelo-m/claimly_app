package com.claimly.backend.controller;

import com.claimly.backend.dto.response.AdminClaimResponse;
import com.claimly.backend.dto.response.AdminUserDetailResponse;
import com.claimly.backend.dto.response.AdminUserSummaryResponse;
import com.claimly.backend.service.AdminService;
import com.claimly.backend.service.ClaimService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * ADMIN + SUPER_ADMIN only (enforced in SecurityConfig). Lets staff review
 * new registrations, approve/suspend customer accounts, and see claims.
 * Claim *verification* itself is SUPER_ADMIN only - see SuperAdminController.
 */
@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminController {

    private final AdminService adminService;
    private final ClaimService claimService;

    public AdminController(AdminService adminService, ClaimService claimService) {
        this.adminService = adminService;
        this.claimService = claimService;
    }

    @GetMapping("/users")
    public ResponseEntity<List<AdminUserSummaryResponse>> getAllUsers() {
        return ResponseEntity.ok(adminService.getAllCustomers());
    }

    @GetMapping("/users/{id}")
    public ResponseEntity<AdminUserDetailResponse> getUserDetail(@PathVariable Long id) {
        return ResponseEntity.ok(adminService.getCustomerDetail(id));
    }

    @PutMapping("/users/{id}/activate")
    public ResponseEntity<Void> activate(@PathVariable Long id) {
        adminService.activate(id);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/users/{id}/suspend")
    public ResponseEntity<Void> suspend(@PathVariable Long id) {
        adminService.suspend(id);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/users/{id}/reactivate")
    public ResponseEntity<Void> reactivate(@PathVariable Long id) {
        adminService.reactivate(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/claims")
    public ResponseEntity<List<AdminClaimResponse>> getAllClaims() {
        return ResponseEntity.ok(claimService.getAllClaimsForAdmin());
    }
}
