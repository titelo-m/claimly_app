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
public class UserDocumentResponse {
    private Long id;
    private String documentType;
    private String fileName;
    private String fileUrl;
    private Long fileSize;
    private boolean verified;
    private LocalDateTime uploadedAt;
}
