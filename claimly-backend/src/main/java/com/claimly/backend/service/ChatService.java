package com.claimly.backend.service;

import com.claimly.backend.dto.response.ChatConversationSummaryResponse;
import com.claimly.backend.dto.response.ChatMessageResponse;
import com.claimly.backend.entity.ChatMessage;
import com.claimly.backend.entity.User;
import com.claimly.backend.repository.ChatMessageRepository;
import com.claimly.backend.repository.UserRepository;
import com.claimly.backend.security.JwtService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ChatService {

    private final UserRepository userRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final JwtService jwtService;

    public ChatService(UserRepository userRepository, ChatMessageRepository chatMessageRepository, JwtService jwtService) {
        this.userRepository = userRepository;
        this.chatMessageRepository = chatMessageRepository;
        this.jwtService = jwtService;
    }

    // ============ CUSTOMER SIDE ============

    /** The customer's own conversation with support. Marks staff messages as read. */
    @Transactional
    public List<ChatMessageResponse> getMyConversation(String token) {
        User customer = userFromToken(token);
        List<ChatMessage> messages = chatMessageRepository.findByCustomerOrderBySentAtAsc(customer);

        messages.stream()
                .filter(m -> !m.getSenderRole().equals("CUSTOMER") && !m.isRead())
                .forEach(m -> m.setRead(true));

        return messages.stream().map(this::buildResponse).collect(Collectors.toList());
    }

    @Transactional
    public ChatMessageResponse sendAsCustomer(String token, String text) {
        User customer = userFromToken(token);
        return saveMessage(customer, customer, "CUSTOMER", text);
    }

    // ============ ADMIN / SUPER_ADMIN SIDE ============

    /** One row per customer who has ever messaged support, most recently active first. */
    public List<ChatConversationSummaryResponse> getAllConversations() {
        return chatMessageRepository.findDistinctCustomers().stream()
                .map(customer -> {
                    List<ChatMessage> thread = chatMessageRepository.findByCustomerOrderBySentAtAsc(customer);
                    ChatMessage last = thread.get(thread.size() - 1);
                    // Unread (from the staff point of view) = customer messages nobody on staff has read yet.
                    long unreadFromCustomer = thread.stream()
                            .filter(m -> m.getSenderRole().equals("CUSTOMER") && !m.isRead())
                            .count();
                    return ChatConversationSummaryResponse.builder()
                            .customerId(customer.getId())
                            .customerName(customer.getFullName())
                            .customerEmail(customer.getEmail())
                            .lastMessage(last.getMessage())
                            .lastMessageAt(last.getSentAt())
                            .unreadCount(unreadFromCustomer)
                            .build();
                })
                .sorted(Comparator.comparing(ChatConversationSummaryResponse::getLastMessageAt).reversed())
                .collect(Collectors.toList());
    }

    /** Admin/super-admin viewing one customer's thread. Marks the customer's messages as read. */
    @Transactional
    public List<ChatMessageResponse> getConversation(Long customerId) {
        User customer = userRepository.findById(customerId)
                .orElseThrow(() -> new RuntimeException("Customer not found"));
        List<ChatMessage> messages = chatMessageRepository.findByCustomerOrderBySentAtAsc(customer);

        messages.stream()
                .filter(m -> m.getSenderRole().equals("CUSTOMER") && !m.isRead())
                .forEach(m -> m.setRead(true));

        return messages.stream().map(this::buildResponse).collect(Collectors.toList());
    }

    @Transactional
    public ChatMessageResponse replyAsStaff(String token, Long customerId, String text) {
        User staff = userFromToken(token);
        User customer = userRepository.findById(customerId)
                .orElseThrow(() -> new RuntimeException("Customer not found"));
        return saveMessage(customer, staff, staff.getRole().name(), text);
    }

    // ============ shared ============

    private ChatMessageResponse saveMessage(User customer, User sender, String senderRole, String text) {
        ChatMessage message = new ChatMessage();
        message.setCustomer(customer);
        message.setSender(sender);
        message.setSenderRole(senderRole);
        message.setMessage(text);
        // A message is "read" from its own sender's perspective immediately.
        message.setRead(false);
        message = chatMessageRepository.save(message);
        return buildResponse(message);
    }

    private User userFromToken(String token) {
        String email = jwtService.extractUsername(token);
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    private ChatMessageResponse buildResponse(ChatMessage m) {
        return ChatMessageResponse.builder()
                .id(m.getId())
                .senderName(m.getSender().getFullName())
                .senderRole(m.getSenderRole())
                .message(m.getMessage())
                .sentAt(m.getSentAt())
                .build();
    }
}
