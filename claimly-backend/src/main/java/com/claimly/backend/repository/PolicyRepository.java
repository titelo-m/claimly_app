package com.claimly.backend.repository;

import com.claimly.backend.entity.Policy;
import com.claimly.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PolicyRepository extends JpaRepository<Policy, Long> {
    Optional<Policy> findByUser(User user);
    Optional<Policy> findByPolicyNumber(String policyNumber);
    boolean existsByUser(User user);
}