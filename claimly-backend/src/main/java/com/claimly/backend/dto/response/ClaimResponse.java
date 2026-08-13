package com.claimly.backend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClaimResponse {
    private String claimReference;
    private String claimType;
    private String description;
    private String status;
    private LocalDateTime submittedAt;
    private LocalDateTime updatedAt;
    private LocalDateTime reviewedAt;
    private LocalDateTime approvedAt;
    private LocalDateTime paidAt;
    private String declineReason;
    private String payoutReference;
    private String payoutAmount;
    private List<ClaimDocumentResponse> documents;
    private List<ClaimHistoryResponse> history;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ClaimDocumentResponse {
        private String fileName;
        private String filePath;
        private Long fileSize;
        private String fileType;
        private LocalDateTime uploadedAt;
        private boolean verified;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ClaimHistoryResponse {
        private String fromStatus;
        private String toStatus;
        private String changedBy;
        private String comment;
        private LocalDateTime changedAt;
    }
}