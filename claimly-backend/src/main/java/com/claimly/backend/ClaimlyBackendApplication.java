package com.claimly.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class ClaimlyBackendApplication {
    public static void main(String[] args) {
        SpringApplication.run(ClaimlyBackendApplication.class, args);
    }
}