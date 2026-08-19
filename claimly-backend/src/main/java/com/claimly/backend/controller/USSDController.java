package com.claimly.backend.controller;

import com.claimly.backend.dto.response.USSDInfoResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/ussd")
@CrossOrigin(origins = "*")
public class USSDController {
    
    @GetMapping("/info")
    public ResponseEntity<USSDInfoResponse> getUSSDInfo() {
        USSDInfoResponse response = USSDInfoResponse.builder()
                .ussdCode("*120*252645#")
                .description("Claimly USSD Service")
                .instructions("Dial *120*252645# from any mobile phone to:\n" +
                        "• Check your cover status\n" +
                        "• Submit a claim\n" +
                        "• Track existing claims\n" +
                        "• Update payment method\n\n" +
                        "No internet connection required.")
                .build();
        return ResponseEntity.ok(response);
    }
}