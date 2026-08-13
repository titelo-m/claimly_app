package com.claimly.backend.entity;

import com.claimly.backend.entity.enums.PolicyStatus;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "policies")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Policy {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "policy_number", unique = true, nullable = false)
    private String policyNumber;
    
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @Column(name = "product_type", nullable = false)
    private String productType;
    
    @Column(name = "tier", nullable = false)
    private String tier;
    
    @Column(name = "monthly_premium", nullable = false)
    private BigDecimal monthlyPremium;
    
    @Column(name = "benefit_amount", nullable = false)
    private BigDecimal benefitAmount;
    
    @Column(name = "benefit_details")
    private String benefitDetails;
    
    @Column(name = "payment_method", nullable = false)
    private String paymentMethod;
    
    @Column(name = "account_number")
    private String accountNumber;
    
    @Column(name = "next_debit_date")
    private LocalDateTime nextDebitDate;
    
    @Enumerated(EnumType.STRING)
    private PolicyStatus status = PolicyStatus.ACTIVE;
    
    @Column(name = "start_date")
    private LocalDateTime startDate;
    
    @Column(name = "waiting_period_ends")
    private LocalDateTime waitingPeriodEnds;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (startDate == null) {
            startDate = LocalDateTime.now();
        }
        if (waitingPeriodEnds == null) {
            waitingPeriodEnds = startDate.plusMonths(9);
        }
        if (nextDebitDate == null) {
            nextDebitDate = startDate.plusMonths(1);
        }
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}