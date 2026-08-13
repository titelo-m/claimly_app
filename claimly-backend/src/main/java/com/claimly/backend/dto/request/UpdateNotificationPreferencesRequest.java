package com.claimly.backend.dto.request;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateNotificationPreferencesRequest {
    private boolean claimUpdates;
    private boolean paymentReminders;
    private boolean generalAnnouncements;
}