package com.claimly.backend.controller;

import com.claimly.backend.dto.request.ChatSendRequest;
import com.claimly.backend.dto.response.ChatConversationSummaryResponse;
import com.claimly.backend.dto.response.ChatMessageResponse;
import com.claimly.backend.service.ChatService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/** ADMIN + SUPER_ADMIN only (enforced in SecurityConfig via /api/admin/**). */
@RestController
@RequestMapping("/api/admin/chat")
@CrossOrigin(origins = "*")
public class AdminChatController {

    private final ChatService chatService;

    public AdminChatController(ChatService chatService) {
        this.chatService = chatService;
    }

    @GetMapping("/conversations")
    public ResponseEntity<List<ChatConversationSummaryResponse>> getAllConversations() {
        return ResponseEntity.ok(chatService.getAllConversations());
    }

    @GetMapping("/conversations/{customerId}")
    public ResponseEntity<List<ChatMessageResponse>> getConversation(@PathVariable Long customerId) {
        return ResponseEntity.ok(chatService.getConversation(customerId));
    }

    @PostMapping("/conversations/{customerId}")
    public ResponseEntity<ChatMessageResponse> reply(
            @RequestHeader("Authorization") String authHeader,
            @PathVariable Long customerId,
            @Valid @RequestBody ChatSendRequest request) {
        String token = authHeader.substring(7);
        return ResponseEntity.ok(chatService.replyAsStaff(token, customerId, request.getMessage()));
    }
}
