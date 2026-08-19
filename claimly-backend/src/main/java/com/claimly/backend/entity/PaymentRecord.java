package com.claimly.backend.entity;

import com.claimly.backend.entity.enums.PaymentRecordStatus;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * One row per billing month per policy. This is the ledger the whole
 * suspend/penalty/reactivate workflow is driven from - there's no live
 * payment gateway yet, so "paid" means an admin has manually confirmed
 * the customer paid (EFT, cash, etc.) and recorded it here.
 */
@Entity
@Table(name = "payment_records")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PaymentRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "policy_id", nullable = false)
    private Policy policy;

    @Column(name = "billing_period_start", nullable = false)
    private LocalDateTime billingPeriodStart;

    @Column(name = "due_date", nullable = false)
    private LocalDateTime dueDate;

    @Column(name = "amount_due", nullable = false)
    private BigDecimal amountDue;

    @Column(name = "penalty_amount")
    private BigDecimal penaltyAmount = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    private PaymentRecordStatus status = PaymentRecordStatus.PENDING;

    @Column(name = "paid_at")
    private LocalDateTime paidAt;

    @Column(name = "payment_method")
    private String paymentMethod;

    @Column(name = "recorded_by")
    private String recordedBy;

    // ---- Customer-submitted proof of payment ----
    @Column(name = "proof_of_payment_url")
    private String proofOfPaymentUrl;

    @Column(name = "proof_of_payment_file_name")
    private String proofOfPaymentFileName;

    @Column(name = "proof_of_payment_uploaded_at")
    private LocalDateTime proofOfPaymentUploadedAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "proof_of_payment_status")
    private com.claimly.backend.entity.enums.ProofOfPaymentStatus proofOfPaymentStatus =
            com.claimly.backend.entity.enums.ProofOfPaymentStatus.NOT_SUBMITTED;

    @Column(name = "proof_of_payment_rejection_reason")
    private String proofOfPaymentRejectionReason;

    /** Prevents the reminder job from emailing the same person daily. */
    @Column(name = "reminder_sent")
    private boolean reminderSent = false;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
