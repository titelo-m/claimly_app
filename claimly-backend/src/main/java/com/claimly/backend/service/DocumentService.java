package com.claimly.backend.service;

import com.claimly.backend.dto.response.UserDocumentResponse;
import com.claimly.backend.entity.User;
import com.claimly.backend.entity.UserDocument;
import com.claimly.backend.entity.enums.DocumentType;
import com.claimly.backend.repository.UserDocumentRepository;
import com.claimly.backend.repository.UserRepository;
import com.claimly.backend.security.JwtService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class DocumentService {

    private final UserRepository userRepository;
    private final UserDocumentRepository userDocumentRepository;
    private final JwtService jwtService;

    private static final List<String> ALLOWED_TYPES = List.of(
            "image/jpeg", "image/png", "image/webp", "application/pdf"
    );
    private static final long MAX_SIZE_BYTES = 10 * 1024 * 1024; // 10MB

    public DocumentService(UserRepository userRepository,
                            UserDocumentRepository userDocumentRepository,
                            JwtService jwtService) {
        this.userRepository = userRepository;
        this.userDocumentRepository = userDocumentRepository;
        this.jwtService = jwtService;
    }

    @Transactional
    public UserDocumentResponse upload(String token, MultipartFile file, String documentTypeRaw) {
        if (file == null || file.isEmpty()) {
            throw new RuntimeException("Please choose a file to upload");
        }
        if (!ALLOWED_TYPES.contains(file.getContentType())) {
            throw new RuntimeException("Only JPG, PNG, WEBP or PDF files are allowed");
        }
        if (file.getSize() > MAX_SIZE_BYTES) {
            throw new RuntimeException("File must be smaller than 10MB");
        }

        DocumentType documentType;
        try {
            documentType = DocumentType.valueOf(documentTypeRaw);
        } catch (Exception e) {
            throw new RuntimeException("Unknown document type: " + documentTypeRaw);
        }

        String email = jwtService.extractUsername(token);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        try {
            Path uploadDir = Paths.get("uploads", "documents");
            Files.createDirectories(uploadDir);

            String originalName = file.getOriginalFilename() != null ? file.getOriginalFilename() : "document";
            String extension = "";
            if (originalName.contains(".")) {
                extension = originalName.substring(originalName.lastIndexOf('.'));
            }
            String storedName = "user-" + user.getId() + "-" + documentType.name() + "-" + UUID.randomUUID() + extension;
            Path destination = uploadDir.resolve(storedName);

            Files.copy(file.getInputStream(), destination, StandardCopyOption.REPLACE_EXISTING);

            UserDocument doc = new UserDocument();
            doc.setUser(user);
            doc.setDocumentType(documentType);
            doc.setFileName(originalName);
            doc.setFileUrl("/uploads/documents/" + storedName);
            doc.setFileSize(file.getSize());
            doc = userDocumentRepository.save(doc);

            return buildResponse(doc);
        } catch (IOException e) {
            throw new RuntimeException("Failed to save document: " + e.getMessage());
        }
    }

    public List<UserDocumentResponse> getMyDocuments(String token) {
        String email = jwtService.extractUsername(token);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return userDocumentRepository.findByUserOrderByUploadedAtDesc(user)
                .stream()
                .map(this::buildResponse)
                .collect(Collectors.toList());
    }

    private UserDocumentResponse buildResponse(UserDocument doc) {
        return UserDocumentResponse.builder()
                .id(doc.getId())
                .documentType(doc.getDocumentType().name())
                .fileName(doc.getFileName())
                .fileUrl(doc.getFileUrl())
                .fileSize(doc.getFileSize())
                .verified(doc.isVerified())
                .uploadedAt(doc.getUploadedAt())
                .build();
    }
}
