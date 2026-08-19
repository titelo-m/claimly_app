package com.claimly.backend.controller;

import com.claimly.backend.dto.request.ChatSendRequest;
import com.claimly.backend.dto.response.ChatMessageResponse;
import com.claimly.backend.service.ChatService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/** Customer side of support chat - always operates on the caller's own thread. */
@RestController
@RequestMapping("/api/chat")
@CrossOrigin(origins = "*")
public class ChatController {

    private final ChatService chatService;

    public ChatController(ChatService chatService) {
        this.chatService = chatService;
    }

    @GetMapping("/messages")
    public ResponseEntity<List<ChatMessageResponse>> getMyMessages(
            @RequestHeader("Authorization") String authHeader) {
        String token = authHeader.substring(7);
        return ResponseEntity.ok(chatService.getMyConversation(token));
    }

    @PostMapping("/messages")
    public ResponseEntity<ChatMessageResponse> sendMessage(
            @RequestHeader("Authorization") String authHeader,
            @Valid @RequestBody ChatSendRequest request) {
        String token = authHeader.substring(7);
        return ResponseEntity.ok(chatService.sendAsCustomer(token, request.getMessage()));
    }
}
