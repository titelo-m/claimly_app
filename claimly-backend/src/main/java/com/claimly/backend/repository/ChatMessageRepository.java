package com.claimly.backend.repository;

import com.claimly.backend.entity.ChatMessage;
import com.claimly.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {
    List<ChatMessage> findByCustomerOrderBySentAtAsc(User customer);

    @Query("SELECT DISTINCT m.customer FROM ChatMessage m")
    List<User> findDistinctCustomers();

    long countByCustomerAndSenderRoleNotAndIsReadFalse(User customer, String senderRole);
}
