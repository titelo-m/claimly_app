package com.claimly.backend.config;

import com.claimly.backend.entity.User;
import com.claimly.backend.entity.enums.UserRole;
import com.claimly.backend.entity.enums.UserStatus;
import com.claimly.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

/**
 * Bootstraps a default SUPER_ADMIN account on first startup, since a brand
 * new database has no admins and normal registration always creates a
 * PENDING_APPROVAL customer. Only runs if no SUPER_ADMIN exists yet.
 *
 * IMPORTANT: change this password after first login (there's no "forgot
 * password" flow for staff accounts yet - use the customer one, or update
 * it directly in the database for now).
 */
@Component
public class DataSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.super-admin.email:superadmin@claimly.co.za}")
    private String superAdminEmail;

    @Value("${app.super-admin.password:SuperAdmin@123}")
    private String superAdminPassword;

    public DataSeeder(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        boolean superAdminExists = userRepository.findAll().stream()
                .anyMatch(u -> u.getRole() == UserRole.SUPER_ADMIN);

        if (superAdminExists) {
            return;
        }

        User superAdmin = new User();
        superAdmin.setEmail(superAdminEmail);
        superAdmin.setPassword(passwordEncoder.encode(superAdminPassword));
        superAdmin.setFullName("Claimly Super Admin");
        superAdmin.setIdNumber("0000000000001");
        superAdmin.setPhoneNumber("0000000001");
        superAdmin.setRole(UserRole.SUPER_ADMIN);
        superAdmin.setStatus(UserStatus.ACTIVE);
        superAdmin.setEmailVerified(true);
        superAdmin.setPhoneVerified(true);
        superAdmin.setDateOfBirth(LocalDate.of(1990, 1, 1));
        superAdmin.setGender("Prefer not to say");
        superAdmin.setEmploymentStatus("Employed");
        superAdmin.setOccupation("System Administrator");

        userRepository.save(superAdmin);

        System.out.println("============================================================");
        System.out.println(" Seeded default Super Admin account:");
        System.out.println("   email:    " + superAdminEmail);
        System.out.println("   password: " + superAdminPassword);
        System.out.println(" Please change this password after your first login.");
        System.out.println("============================================================");
    }
}
