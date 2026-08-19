package com.claimly.backend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatConversationSummaryResponse {
    private Long customerId;
    private String customerName;
    private String customerEmail;
    private String lastMessage;
    private LocalDateTime lastMessageAt;
    private long unreadCount;
}
