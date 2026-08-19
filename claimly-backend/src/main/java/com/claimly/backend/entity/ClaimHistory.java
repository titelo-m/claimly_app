package com.claimly.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "claim_history")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ClaimHistory {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "claim_id", nullable = false)
    private Claim claim;
    
    @Column(name = "from_status")
    private String fromStatus;
    
    @Column(name = "to_status", nullable = false)
    private String toStatus;
    
    @Column(name = "changed_by")
    private String changedBy;
    
    @Column(name = "comment")
    private String comment;
    
    @Column(name = "changed_at")
    private LocalDateTime changedAt;
    
    @PrePersist
    protected void onCreate() {
        changedAt = LocalDateTime.now();
    }
}