package com.claimly.backend.repository;

import com.claimly.backend.entity.PaymentRecord;
import com.claimly.backend.entity.Policy;
import com.claimly.backend.entity.enums.PaymentRecordStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface PaymentRecordRepository extends JpaRepository<PaymentRecord, Long> {
    List<PaymentRecord> findByPolicyOrderByDueDateDesc(Policy policy);
    Optional<PaymentRecord> findFirstByPolicyOrderByDueDateDesc(Policy policy);
    List<PaymentRecord> findByStatus(PaymentRecordStatus status);
    List<PaymentRecord> findByStatusAndDueDateBefore(PaymentRecordStatus status, LocalDateTime cutoff);
    List<PaymentRecord> findByStatusAndReminderSentFalseAndDueDateBetween(
            PaymentRecordStatus status, LocalDateTime from, LocalDateTime to);
}
