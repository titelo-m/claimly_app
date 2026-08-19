package com.claimly.backend.repository;

import com.claimly.backend.entity.OTP;
import com.claimly.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface OTPRepository extends JpaRepository<OTP, Long> {
    Optional<OTP> findByUserAndOtpCodeAndUsedFalse(User user, String otpCode);
    void deleteByUserAndUsedTrue(User user);
}