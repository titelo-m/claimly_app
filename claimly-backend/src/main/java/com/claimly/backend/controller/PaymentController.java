package com.claimly.backend.controller;

import com.claimly.backend.dto.response.PaymentRecordResponse;
import com.claimly.backend.service.PaymentService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

/** Customer's own payment history and proof-of-payment upload - always the caller's own policy. */
@RestController
@RequestMapping("/api/payments")
@CrossOrigin(origins = "*")
public class PaymentController {

    private final PaymentService paymentService;

    public PaymentController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    @GetMapping("/history")
    public ResponseEntity<List<PaymentRecordResponse>> getMyPaymentHistory(
            @RequestHeader("Authorization") String authHeader) {
        String token = authHeader.substring(7);
        return ResponseEntity.ok(paymentService.getMyPaymentHistory(token));
    }

    @PostMapping("/{id}/proof")
    public ResponseEntity<PaymentRecordResponse> uploadProofOfPayment(
            @PathVariable Long id,
            @RequestHeader("Authorization") String authHeader,
            @RequestParam("file") MultipartFile file) {
        String token = authHeader.substring(7);
        return ResponseEntity.ok(paymentService.uploadProofOfPayment(token, id, file));
    }
}
