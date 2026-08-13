package com.claimly.backend.controller;

import com.claimly.backend.dto.response.UserDocumentResponse;
import com.claimly.backend.service.DocumentService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/documents")
@CrossOrigin(origins = "*")
public class DocumentController {

    private final DocumentService documentService;

    public DocumentController(DocumentService documentService) {
        this.documentService = documentService;
    }

    @PostMapping("/upload")
    public ResponseEntity<UserDocumentResponse> upload(
            @RequestHeader("Authorization") String authHeader,
            @RequestParam("file") MultipartFile file,
            @RequestParam("documentType") String documentType) {
        String token = authHeader.substring(7);
        return ResponseEntity.ok(documentService.upload(token, file, documentType));
    }

    @GetMapping
    public ResponseEntity<List<UserDocumentResponse>> getMyDocuments(
            @RequestHeader("Authorization") String authHeader) {
        String token = authHeader.substring(7);
        return ResponseEntity.ok(documentService.getMyDocuments(token));
    }
}
