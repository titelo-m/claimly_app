package com.claimly.backend.repository;

import com.claimly.backend.entity.Claim;
import com.claimly.backend.entity.User;
import com.claimly.backend.entity.enums.ClaimStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ClaimRepository extends JpaRepository<Claim, Long> {
    List<Claim> findByUserOrderBySubmittedAtDesc(User user);
    Optional<Claim> findByClaimReference(String claimReference);
    // NOTE: was previously findByStatus(String) - the status column is an enum
    // (ClaimStatus), so a String parameter would never actually match anything.
    List<Claim> findByStatusOrderBySubmittedAtDesc(ClaimStatus status);
    List<Claim> findAllByOrderBySubmittedAtDesc();
}
