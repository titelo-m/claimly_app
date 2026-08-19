package com.claimly.backend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentRecordResponse {
    private Long id;
    private LocalDateTime billingPeriodStart;
    private LocalDateTime dueDate;
    private BigDecimal amountDue;
    private BigDecimal penaltyAmount;
    private BigDecimal totalDue;
    private String status;
    private LocalDateTime paidAt;
    private String paymentMethod;
    private String proofOfPaymentUrl;
    private String proofOfPaymentFileName;
    private LocalDateTime proofOfPaymentUploadedAt;
    private String proofOfPaymentStatus;
    private String proofOfPaymentRejectionReason;
}
