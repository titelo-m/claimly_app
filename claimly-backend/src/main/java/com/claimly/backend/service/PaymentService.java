package com.claimly.backend.service;

import com.claimly.backend.dto.response.AdminPaymentResponse;
import com.claimly.backend.dto.response.PaymentRecordResponse;
import com.claimly.backend.entity.PaymentRecord;
import com.claimly.backend.entity.Policy;
import com.claimly.backend.entity.User;
import com.claimly.backend.entity.enums.PaymentRecordStatus;
import com.claimly.backend.entity.enums.PolicyStatus;
import com.claimly.backend.entity.enums.ProofOfPaymentStatus;
import com.claimly.backend.repository.PaymentRecordRepository;
import com.claimly.backend.repository.PolicyRepository;
import com.claimly.backend.repository.UserRepository;
import com.claimly.backend.security.JwtService;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * The monthly billing ledger. There's no live payment gateway yet - a
 * customer pays outside the app (EFT, cash, etc.), uploads a proof of
 * payment, and an admin reviews it before the account is reactivated.
 * An admin can also record a payment directly without proof (e.g. if a
 * customer paid in cash at an office). The daily scheduled job is what
 * enforces "pay by the due date or your cover is suspended".
 */
@Service
public class PaymentService {

    private static final BigDecimal LATE_PENALTY = BigDecimal.valueOf(20);
    private static final List<String> ALLOWED_PROOF_TYPES =
            List.of("image/jpeg", "image/png", "image/webp", "application/pdf");
    private static final long MAX_PROOF_SIZE_BYTES = 10 * 1024 * 1024; // 10MB

    private final PaymentRecordRepository paymentRecordRepository;
    private final PolicyRepository policyRepository;
    private final UserRepository userRepository;
    private final JwtService jwtService;
    private final EmailService emailService;

    public PaymentService(PaymentRecordRepository paymentRecordRepository,
                           PolicyRepository policyRepository,
                           UserRepository userRepository,
                           JwtService jwtService,
                           EmailService emailService) {
        this.paymentRecordRepository = paymentRecordRepository;
        this.policyRepository = policyRepository;
        this.userRepository = userRepository;
        this.jwtService = jwtService;
        this.emailService = emailService;
    }

    /** Called the moment a policy is approved (PolicyService.approveCover). */
    @Transactional
    public void createInitialBillingRecord(Policy policy) {
        LocalDateTime periodStart = LocalDateTime.now();
        LocalDateTime dueDate = periodStart.plusMonths(1);

        policy.setNextDebitDate(dueDate);
        policyRepository.save(policy);

        PaymentRecord record = new PaymentRecord();
        record.setPolicy(policy);
        record.setBillingPeriodStart(periodStart);
        record.setDueDate(dueDate);
        record.setAmountDue(policy.getMonthlyPremium());
        paymentRecordRepository.save(record);
    }

    private void generateNextBillingRecord(Policy policy) {
        LocalDateTime periodStart = LocalDateTime.now();
        LocalDateTime dueDate = periodStart.plusMonths(1);

        policy.setNextDebitDate(dueDate);
        policyRepository.save(policy);

        PaymentRecord record = new PaymentRecord();
        record.setPolicy(policy);
        record.setBillingPeriodStart(periodStart);
        record.setDueDate(dueDate);
        record.setAmountDue(policy.getMonthlyPremium());
        paymentRecordRepository.save(record);
    }

    public List<PaymentRecordResponse> getMyPaymentHistory(String token) {
        User user = userFromToken(token);
        Policy policy = user.getPolicy();
        if (policy == null) return List.of();

        return paymentRecordRepository.findByPolicyOrderByDueDateDesc(policy).stream()
                .map(this::buildResponse)
                .collect(Collectors.toList());
    }

    /**
     * Customer uploads proof of payment (bank EFT screenshot, deposit slip,
     * etc.) against a specific outstanding record. This does NOT mark the
     * payment as received on its own - an admin still has to review it and
     * approve it via approveProof() before the cover is reactivated.
     */
    @Transactional
    public PaymentRecordResponse uploadProofOfPayment(String token, Long paymentRecordId, MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new RuntimeException("Please choose a file to upload");
        }
        if (!ALLOWED_PROOF_TYPES.contains(file.getContentType())) {
            throw new RuntimeException("Only JPG, PNG, WEBP or PDF files are allowed");
        }
        if (file.getSize() > MAX_PROOF_SIZE_BYTES) {
            throw new RuntimeException("File must be smaller than 10MB");
        }

        User user = userFromToken(token);
        PaymentRecord record = paymentRecordRepository.findById(paymentRecordId)
                .orElseThrow(() -> new RuntimeException("Payment record not found"));

        if (record.getPolicy().getUser() == null ||
                !record.getPolicy().getUser().getId().equals(user.getId())) {
            throw new RuntimeException("You do not have permission to update this payment");
        }
        if (record.getStatus() == PaymentRecordStatus.PAID) {
            throw new RuntimeException("This payment has already been confirmed as paid");
        }

        try {
            Path uploadDir = Paths.get("uploads", "payment-proofs");
            Files.createDirectories(uploadDir);

            String originalName = file.getOriginalFilename() != null ? file.getOriginalFilename() : "proof";
            String extension = "";
            if (originalName.contains(".")) {
                extension = originalName.substring(originalName.lastIndexOf('.'));
            }
            String storedName = "payment-" + record.getId() + "-" + UUID.randomUUID() + extension;
            Path destination = uploadDir.resolve(storedName);
            Files.copy(file.getInputStream(), destination, StandardCopyOption.REPLACE_EXISTING);

            record.setProofOfPaymentUrl("/uploads/payment-proofs/" + storedName);
            record.setProofOfPaymentFileName(originalName);
            record.setProofOfPaymentUploadedAt(LocalDateTime.now());
            record.setProofOfPaymentStatus(ProofOfPaymentStatus.PENDING_REVIEW);
            record.setProofOfPaymentRejectionReason(null);
            record = paymentRecordRepository.save(record);
        } catch (IOException e) {
            throw new RuntimeException("Failed to save proof of payment: " + e.getMessage());
        }

        emailService.sendProofOfPaymentSubmittedEmail(user.getEmail(), user.getFullName());

        return buildResponse(record);
    }

    /** Admin/super-admin view: every PENDING or OVERDUE payment, most urgent first. */
    public List<AdminPaymentResponse> getOutstandingPayments() {
        List<PaymentRecord> pending = paymentRecordRepository.findByStatus(PaymentRecordStatus.PENDING);
        List<PaymentRecord> overdue = paymentRecordRepository.findByStatus(PaymentRecordStatus.OVERDUE);

        return java.util.stream.Stream.concat(overdue.stream(), pending.stream())
                .map(this::buildAdminResponse)
                .collect(Collectors.toList());
    }

    /** Admin/super-admin confirming a customer has paid - directly, no proof needed. */
    @Transactional
    public void recordPayment(Long paymentRecordId, String paymentMethod, String actingToken) {
        User actor = userFromToken(actingToken);
        PaymentRecord record = paymentRecordRepository.findById(paymentRecordId)
                .orElseThrow(() -> new RuntimeException("Payment record not found"));
        markPaidAndReactivate(record, paymentMethod, actor.getFullName());
    }

    /** Admin/super-admin approving a customer-submitted proof of payment. */
    @Transactional
    public void approveProofOfPayment(Long paymentRecordId, String actingToken) {
        User actor = userFromToken(actingToken);
        PaymentRecord record = paymentRecordRepository.findById(paymentRecordId)
                .orElseThrow(() -> new RuntimeException("Payment record not found"));

        if (record.getProofOfPaymentStatus() != ProofOfPaymentStatus.PENDING_REVIEW) {
            throw new RuntimeException("There's no proof of payment awaiting review on this record");
        }

        markPaidAndReactivate(record, "Proof of payment (uploaded)", actor.getFullName());
    }

    /** Admin/super-admin rejecting a customer-submitted proof of payment. */
    @Transactional
    public void rejectProofOfPayment(Long paymentRecordId, String reason, String actingToken) {
        PaymentRecord record = paymentRecordRepository.findById(paymentRecordId)
                .orElseThrow(() -> new RuntimeException("Payment record not found"));

        if (record.getProofOfPaymentStatus() != ProofOfPaymentStatus.PENDING_REVIEW) {
            throw new RuntimeException("There's no proof of payment awaiting review on this record");
        }

        record.setProofOfPaymentStatus(ProofOfPaymentStatus.REJECTED);
        record.setProofOfPaymentRejectionReason(reason);
        paymentRecordRepository.save(record);

        User user = record.getPolicy().getUser();
        emailService.sendProofOfPaymentRejectedEmail(user.getEmail(), user.getFullName(), reason);
    }

    private void markPaidAndReactivate(PaymentRecord record, String paymentMethod, String actorName) {
        if (record.getStatus() == PaymentRecordStatus.PAID) {
            throw new RuntimeException("This payment has already been recorded as paid");
        }

        record.setStatus(PaymentRecordStatus.PAID);
        record.setPaidAt(LocalDateTime.now());
        record.setPaymentMethod(paymentMethod);
        record.setRecordedBy(actorName);
        record.setProofOfPaymentStatus(record.getProofOfPaymentUrl() != null
                ? ProofOfPaymentStatus.NOT_SUBMITTED // proof served its purpose, clear the review state
                : record.getProofOfPaymentStatus());
        paymentRecordRepository.save(record);

        Policy policy = record.getPolicy();
        if (policy.getStatus() == PolicyStatus.LAPSED) {
            policy.setStatus(PolicyStatus.ACTIVE);
            policyRepository.save(policy);
        }

        User user = policy.getUser();
        BigDecimal totalPaid = record.getAmountDue().add(record.getPenaltyAmount());
        emailService.sendPaymentReceivedEmail(user.getEmail(), user.getFullName(), totalPaid.toString());

        // Roll the billing cycle forward so there's always exactly one
        // open (PENDING) record per active policy.
        generateNextBillingRecord(policy);
    }

    // ============ Scheduled enforcement ============
    // Runs once a day. A fixed 2am local-time cron keeps this out of
    // business hours; adjust if you deploy across time zones.

    @Scheduled(cron = "0 0 2 * * *")
    @Transactional
    public void sendUpcomingPaymentReminders() {
        LocalDateTime now = LocalDateTime.now();
        List<PaymentRecord> dueSoon = paymentRecordRepository
                .findByStatusAndReminderSentFalseAndDueDateBetween(
                        PaymentRecordStatus.PENDING, now, now.plusDays(3));

        for (PaymentRecord record : dueSoon) {
            User user = record.getPolicy().getUser();
            emailService.sendPaymentReminderEmail(
                    user.getEmail(), user.getFullName(),
                    record.getAmountDue().toString(),
                    record.getDueDate().toLocalDate().toString());
            record.setReminderSent(true);
            paymentRecordRepository.save(record);
        }
    }

    @Scheduled(cron = "0 30 2 * * *")
    @Transactional
    public void suspendOverdueAccounts() {
        LocalDateTime cutoff = LocalDateTime.now().minusDays(1);
        List<PaymentRecord> overdue = paymentRecordRepository
                .findByStatusAndDueDateBefore(PaymentRecordStatus.PENDING, cutoff);

        for (PaymentRecord record : overdue) {
            record.setStatus(PaymentRecordStatus.OVERDUE);
            record.setPenaltyAmount(LATE_PENALTY);
            paymentRecordRepository.save(record);

            Policy policy = record.getPolicy();
            policy.setStatus(PolicyStatus.LAPSED);
            policyRepository.save(policy);

            User user = policy.getUser();
            BigDecimal totalDue = record.getAmountDue().add(LATE_PENALTY);
            emailService.sendPaymentOverdueSuspendedEmail(user.getEmail(), user.getFullName(), totalDue.toString());
        }
    }

    // ============ helpers ============

    private User userFromToken(String token) {
        String email = jwtService.extractUsername(token);
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    private PaymentRecordResponse buildResponse(PaymentRecord r) {
        return PaymentRecordResponse.builder()
                .id(r.getId())
                .billingPeriodStart(r.getBillingPeriodStart())
                .dueDate(r.getDueDate())
                .amountDue(r.getAmountDue())
                .penaltyAmount(r.getPenaltyAmount())
                .totalDue(r.getAmountDue().add(r.getPenaltyAmount()))
                .status(r.getStatus().name())
                .paidAt(r.getPaidAt())
                .paymentMethod(r.getPaymentMethod())
                .proofOfPaymentUrl(r.getProofOfPaymentUrl())
                .proofOfPaymentFileName(r.getProofOfPaymentFileName())
                .proofOfPaymentUploadedAt(r.getProofOfPaymentUploadedAt())
                .proofOfPaymentStatus(r.getProofOfPaymentStatus() != null ? r.getProofOfPaymentStatus().name() : null)
                .proofOfPaymentRejectionReason(r.getProofOfPaymentRejectionReason())
                .build();
    }

    private AdminPaymentResponse buildAdminResponse(PaymentRecord r) {
        Policy policy = r.getPolicy();
        User user = policy.getUser();
        return AdminPaymentResponse.builder()
                .id(r.getId())
                .userId(user.getId())
                .userFullName(user.getFullName())
                .userEmail(user.getEmail())
                .productType(policy.getProductType())
                .tier(policy.getTier())
                .amountDue(r.getAmountDue())
                .penaltyAmount(r.getPenaltyAmount())
                .totalDue(r.getAmountDue().add(r.getPenaltyAmount()))
                .dueDate(r.getDueDate())
                .status(r.getStatus().name())
                .proofOfPaymentUrl(r.getProofOfPaymentUrl())
                .proofOfPaymentFileName(r.getProofOfPaymentFileName())
                .proofOfPaymentUploadedAt(r.getProofOfPaymentUploadedAt())
                .proofOfPaymentStatus(r.getProofOfPaymentStatus() != null ? r.getProofOfPaymentStatus().name() : null)
                .build();
    }
}
