package com.claimly.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChatSendRequest {
    @NotBlank(message = "Message can't be empty")
    @Size(max = 2000, message = "Message is too long")
    private String message;
}
