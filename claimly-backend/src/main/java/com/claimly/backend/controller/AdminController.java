package com.claimly.backend.controller;

import com.claimly.backend.dto.response.AdminClaimResponse;
import com.claimly.backend.dto.response.AdminPaymentResponse;
import com.claimly.backend.dto.response.AdminUserDetailResponse;
import com.claimly.backend.dto.response.AdminUserSummaryResponse;
import com.claimly.backend.dto.response.PendingPolicyResponse;
import com.claimly.backend.dto.request.RecordPaymentRequest;
import com.claimly.backend.dto.request.RejectProofRequest;
import com.claimly.backend.service.AdminService;
import com.claimly.backend.service.ClaimService;
import com.claimly.backend.service.PaymentService;
import com.claimly.backend.service.PolicyService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * ADMIN + SUPER_ADMIN only (enforced in SecurityConfig). Lets staff review
 * new registrations, approve/suspend customer accounts, approve pending
 * cover selections, record monthly payments, and see claims. Claim
 * *verification* itself is SUPER_ADMIN only - see SuperAdminController.
 */
@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminController {

    private final AdminService adminService;
    private final ClaimService claimService;
    private final PolicyService policyService;
    private final PaymentService paymentService;

    public AdminController(AdminService adminService, ClaimService claimService,
                            PolicyService policyService, PaymentService paymentService) {
        this.adminService = adminService;
        this.claimService = claimService;
        this.policyService = policyService;
        this.paymentService = paymentService;
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

    @GetMapping("/policies/pending")
    public ResponseEntity<List<PendingPolicyResponse>> getPendingPolicies() {
        return ResponseEntity.ok(policyService.getPendingPolicies());
    }

    @PutMapping("/policies/{id}/approve")
    public ResponseEntity<Void> approvePolicy(@PathVariable Long id) {
        policyService.approveCover(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/payments/outstanding")
    public ResponseEntity<List<AdminPaymentResponse>> getOutstandingPayments() {
        return ResponseEntity.ok(paymentService.getOutstandingPayments());
    }

    @PutMapping("/payments/{id}/record")
    public ResponseEntity<Void> recordPayment(
            @PathVariable Long id,
            @RequestHeader("Authorization") String authHeader,
            @Valid @RequestBody RecordPaymentRequest request) {
        String token = authHeader.substring(7);
        paymentService.recordPayment(id, request.getPaymentMethod(), token);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/payments/{id}/approve-proof")
    public ResponseEntity<Void> approveProof(
            @PathVariable Long id,
            @RequestHeader("Authorization") String authHeader) {
        String token = authHeader.substring(7);
        paymentService.approveProofOfPayment(id, token);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/payments/{id}/reject-proof")
    public ResponseEntity<Void> rejectProof(
            @PathVariable Long id,
            @RequestHeader("Authorization") String authHeader,
            @RequestBody RejectProofRequest request) {
        String token = authHeader.substring(7);
        paymentService.rejectProofOfPayment(id, request.getReason(), token);
        return ResponseEntity.ok().build();
    }
}
