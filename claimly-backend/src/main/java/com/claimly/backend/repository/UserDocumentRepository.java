package com.claimly.backend.repository;

import com.claimly.backend.entity.User;
import com.claimly.backend.entity.UserDocument;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserDocumentRepository extends JpaRepository<UserDocument, Long> {
    List<UserDocument> findByUserOrderByUploadedAtDesc(User user);
}
