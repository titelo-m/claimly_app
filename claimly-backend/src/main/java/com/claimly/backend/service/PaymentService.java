package com.claimly.backend.service;

import com.claimly.backend.dto.response.PaymentHistoryResponse;
import com.claimly.backend.entity.User;
import com.claimly.backend.repository.UserRepository;
import com.claimly.backend.security.JwtService;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class PaymentService {
    
    private final UserRepository userRepository;
    private final JwtService jwtService;
    
    public PaymentService(UserRepository userRepository, JwtService jwtService) {
        this.userRepository = userRepository;
        this.jwtService = jwtService;
    }
    
    public List<PaymentHistoryResponse> getPaymentHistory(String token) {
        String email = jwtService.extractUsername(token);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        List<PaymentHistoryResponse> history = new ArrayList<>();
        
        if (user.getPolicy() != null) {
            history.add(PaymentHistoryResponse.builder()
                    .paymentDate(LocalDateTime.now().minusMonths(1))
                    .amount(user.getPolicy().getMonthlyPremium())
                    .status("Paid")
                    .paymentMethod(user.getPolicy().getPaymentMethod())
                    .build());
            
            history.add(PaymentHistoryResponse.builder()
                    .paymentDate(LocalDateTime.now().minusMonths(2))
                    .amount(user.getPolicy().getMonthlyPremium())
                    .status("Paid")
                    .paymentMethod(user.getPolicy().getPaymentMethod())
                    .build());
        }
        
        return history;
    }
}