package com.claimly.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "notification_preferences")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class NotificationPreference {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @Column(name = "claim_updates")
    private boolean claimUpdates = true;
    
    @Column(name = "payment_reminders")
    private boolean paymentReminders = true;
    
    @Column(name = "general_announcements")
    private boolean generalAnnouncements = true;
    
    @Column(name = "push_enabled")
    private boolean pushEnabled = true;
    
    @Column(name = "email_enabled")
    private boolean emailEnabled = true;
}