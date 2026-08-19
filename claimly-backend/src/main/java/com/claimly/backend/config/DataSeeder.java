package com.claimly.backend.config;

import com.claimly.backend.entity.*;
import com.claimly.backend.entity.enums.*;
import com.claimly.backend.repository.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Bootstraps a default SUPER_ADMIN account on first startup (a brand new
 * database has no admins and normal registration always creates a
 * PENDING_APPROVAL customer), and - separately - 50 demo customers with
 * varied statuses, covers, payments, and claims, purely so the admin
 * dashboards have something realistic to look at while testing.
 *
 * IMPORTANT: change the super admin password after first login. The demo
 * customers are all password "1234qwer" - this is throwaway test data,
 * never seed anything like this against a real production database.
 */
@Component
public class DataSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PolicyRepository policyRepository;
    private final PaymentRecordRepository paymentRecordRepository;
    private final ClaimRepository claimRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.super-admin.email:superadmin@claimly.co.za}")
    private String superAdminEmail;

    @Value("${app.super-admin.password:SuperAdmin@123}")
    private String superAdminPassword;

    private static final String DEMO_PASSWORD = "1234qwer";

    private static final String[] FIRST_NAMES = {
        "Thabo", "Nomvula", "Sipho", "Zanele", "Mandla", "Precious", "Bongani", "Nokuthula",
        "Themba", "Ayanda", "Lindiwe", "Sabelo", "Nomsa", "Kagiso", "Refilwe", "Karabo",
        "Lesedi", "Palesa", "Tumelo", "Bafana", "Zodwa", "Sizani", "Mpho", "Nkosana",
        "Thandiwe", "Gugu", "Sifiso", "Nolwazi", "Andile", "Busisiwe", "Vuyo", "Nomfundo",
        "Sibusiso", "Zinhle", "Mzwandile", "Ntombi", "Khaya", "Lerato", "Sanele", "Nonhlanhla",
        "Thulani", "Ntokozo", "Bulelwa", "Siyabonga", "Nombuso", "Wandile", "Fikile",
        "Sibongile", "Mthunzi", "Zoleka"
    };

    private static final String[] LAST_NAMES = {
        "Nkosi", "Dlamini", "Mokoena", "Khumalo", "Zulu", "Ndlovu", "Mahlangu", "Sithole",
        "Mabaso", "Mnguni", "Radebe", "Mthembu", "Cele", "Buthelezi", "Ngcobo", "Mbatha",
        "Shabalala", "Zwane", "Skhosana", "Maseko", "Mahlalela", "Nxumalo", "Gumede",
        "Hlongwane", "Motaung", "Tshabalala", "Molefe", "Sekhukhune", "Mabena", "Kunene",
        "Mavuso", "Vilakazi", "Msomi", "Zungu", "Qwabe", "Mkhize", "Sibiya", "Xulu",
        "Majola", "Ngwenya", "Dube", "Mahlaba", "Nyathi", "Baloyi", "Chauke", "Maluleke",
        "Rikhotso", "Ngobeni", "Mnisi", "Sithebe"
    };

    private static final String[] OCCUPATIONS = {
        "Domestic worker", "Security guard", "Retail assistant", "Taxi driver", "Street vendor",
        "Construction worker", "Cleaner", "Waiter", "Delivery driver", "Farm worker",
        "Hairdresser", "Mechanic", "Nurse aide", "Teacher assistant", "Warehouse worker"
    };

    private static final String[] EMPLOYMENT_STATUSES = {
        "Employed", "Self-employed", "Informal / Piece work", "Unemployed"
    };

    public DataSeeder(UserRepository userRepository,
                       PolicyRepository policyRepository,
                       PaymentRecordRepository paymentRecordRepository,
                       ClaimRepository claimRepository,
                       ChatMessageRepository chatMessageRepository,
                       PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.policyRepository = policyRepository;
        this.paymentRecordRepository = paymentRecordRepository;
        this.claimRepository = claimRepository;
        this.chatMessageRepository = chatMessageRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional
    public void run(String... args) {
        seedSuperAdminIfMissing();
        seedDemoCustomersIfMissing();
    }

    private void seedSuperAdminIfMissing() {
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

    private void seedDemoCustomersIfMissing() {
        if (userRepository.findByEmail("demo01@claimly.test").isPresent()) {
            return; // already seeded - don't duplicate on every restart
        }

        String encodedDemoPassword = passwordEncoder.encode(DEMO_PASSWORD);
        String encodedPolicyNumberPrefix = "POL-DEMO-";

        for (int i = 1; i <= 50; i++) {
            String fullName = FIRST_NAMES[i - 1] + " " + LAST_NAMES[i - 1];
            String email = String.format("demo%02d@claimly.test", i);
            String phone = String.format("082%07d", 1000000 + i);
            String idNumber = String.format("%013d", 9000000000000L + i);

            User user = new User();
            user.setFullName(fullName);
            user.setEmail(email);
            user.setPassword(encodedDemoPassword);
            user.setPhoneNumber(phone);
            user.setIdNumber(idNumber);
            user.setRole(UserRole.CUSTOMER);
            user.setEmailVerified(true);
            user.setPhoneVerified(true);
            user.setDateOfBirth(LocalDate.of(1970 + (i % 35), 1 + (i % 12), 1 + (i % 27)));
            user.setGender(i % 2 == 0 ? "Male" : "Female");
            user.setEmploymentStatus(EMPLOYMENT_STATUSES[i % EMPLOYMENT_STATUSES.length]);
            user.setOccupation(OCCUPATIONS[i % OCCUPATIONS.length]);
            user.setMonthlyIncome(BigDecimal.valueOf(2500 + (i % 10) * 500));
            user.setNextOfKinName(LAST_NAMES[(i + 7) % LAST_NAMES.length] + " family member");
            user.setNextOfKinPhone(String.format("083%07d", 2000000 + i));

            // ---- Distribution across 50 demo customers ----
            if (i <= 12) {
                // 1-12: pending approval, nothing else set up yet
                user.setStatus(UserStatus.PENDING_APPROVAL);
                userRepository.save(user);
            } else if (i <= 15) {
                // 13-15: account suspended
                user.setStatus(UserStatus.SUSPENDED);
                userRepository.save(user);
            } else if (i <= 25) {
                // 16-25: active account, no cover yet
                user.setStatus(UserStatus.ACTIVE);
                userRepository.save(user);
            } else if (i <= 30) {
                // 26-30: active account, cover submitted, awaiting approval
                user.setStatus(UserStatus.ACTIVE);
                user = userRepository.save(user);
                Policy policy = buildPolicy(user, i, PolicyStatus.PENDING, encodedPolicyNumberPrefix);
                policy = policyRepository.save(policy);
                user.setPolicy(policy);
                userRepository.save(user);
            } else if (i <= 42) {
                // 31-42: active account, cover active, payment in good standing
                user.setStatus(UserStatus.ACTIVE);
                user = userRepository.save(user);
                Policy policy = buildPolicy(user, i, PolicyStatus.ACTIVE, encodedPolicyNumberPrefix);
                policy.setNextDebitDate(LocalDateTime.now().plusDays(10 + (i % 15)));
                policy = policyRepository.save(policy);
                user.setPolicy(policy);
                userRepository.save(user);

                PaymentRecord record = new PaymentRecord();
                record.setPolicy(policy);
                record.setBillingPeriodStart(LocalDateTime.now().minusDays(20));
                record.setDueDate(policy.getNextDebitDate());
                record.setAmountDue(policy.getMonthlyPremium());
                paymentRecordRepository.save(record);

                // Sprinkle a few claims among this group for the Claims tab
                if (i == 32) seedClaim(user, policy, "Illness", ClaimStatus.SUBMITTED, null, null);
                if (i == 34) seedClaim(user, policy, "Injury / Accident", ClaimStatus.SUBMITTED, null, null);
                if (i == 36) seedClaim(user, policy, "Retrenchment", ClaimStatus.APPROVED, null, null);
                if (i == 38) seedClaim(user, policy, "Illness", ClaimStatus.APPROVED, null, null);
                if (i == 39) seedClaim(user, policy, "Injury / Accident", ClaimStatus.DECLINED,
                        "Incident occurred outside the policy's waiting period", null);
                if (i == 40) seedClaim(user, policy, "Illness", ClaimStatus.PAID,
                        null, policy.getBenefitAmount());
            } else if (i <= 47) {
                // 43-47: cover lapsed - overdue payment with penalty (fills the Payments "Overdue" tab)
                user.setStatus(UserStatus.ACTIVE);
                user = userRepository.save(user);
                Policy policy = buildPolicy(user, i, PolicyStatus.LAPSED, encodedPolicyNumberPrefix);
                policy.setNextDebitDate(LocalDateTime.now().minusDays(3));
                policy = policyRepository.save(policy);
                user.setPolicy(policy);
                userRepository.save(user);

                PaymentRecord record = new PaymentRecord();
                record.setPolicy(policy);
                record.setBillingPeriodStart(LocalDateTime.now().minusDays(33));
                record.setDueDate(policy.getNextDebitDate());
                record.setAmountDue(policy.getMonthlyPremium());
                record.setStatus(PaymentRecordStatus.OVERDUE);
                record.setPenaltyAmount(BigDecimal.valueOf(20));
                paymentRecordRepository.save(record);
            } else {
                // 48-50: long-standing customers with a paid history + current open bill
                user.setStatus(UserStatus.ACTIVE);
                user = userRepository.save(user);
                Policy policy = buildPolicy(user, i, PolicyStatus.ACTIVE, encodedPolicyNumberPrefix);
                policy.setNextDebitDate(LocalDateTime.now().plusDays(18));
                policy = policyRepository.save(policy);
                user.setPolicy(policy);
                userRepository.save(user);

                PaymentRecord paidRecord = new PaymentRecord();
                paidRecord.setPolicy(policy);
                paidRecord.setBillingPeriodStart(LocalDateTime.now().minusMonths(1).minusDays(20));
                paidRecord.setDueDate(LocalDateTime.now().minusDays(12));
                paidRecord.setAmountDue(policy.getMonthlyPremium());
                paidRecord.setStatus(PaymentRecordStatus.PAID);
                paidRecord.setPaidAt(LocalDateTime.now().minusDays(13));
                paidRecord.setPaymentMethod("EFT");
                paidRecord.setRecordedBy("Claimly Super Admin");
                paymentRecordRepository.save(paidRecord);

                PaymentRecord currentRecord = new PaymentRecord();
                currentRecord.setPolicy(policy);
                currentRecord.setBillingPeriodStart(LocalDateTime.now().minusDays(20));
                currentRecord.setDueDate(policy.getNextDebitDate());
                currentRecord.setAmountDue(policy.getMonthlyPremium());
                paymentRecordRepository.save(currentRecord);

                if (i == 49) seedClaim(user, policy, "Retrenchment", ClaimStatus.PAID, null, policy.getBenefitAmount());
            }

            // A handful of demo chat threads so the Chat tab isn't empty
            if (i == 17 || i == 22 || i == 33 || i == 45) {
                ChatMessage msg = new ChatMessage();
                msg.setCustomer(user);
                msg.setSender(user);
                msg.setSenderRole("CUSTOMER");
                msg.setMessage("Hi, I just wanted to check on the status of my account. Thanks!");
                chatMessageRepository.save(msg);
            }
        }

        System.out.println("============================================================");
        System.out.println(" Seeded 50 demo customers (all password: " + DEMO_PASSWORD + ")");
        System.out.println("   e.g. demo01@claimly.test ... demo50@claimly.test");
        System.out.println(" This is throwaway test data - do not use in production.");
        System.out.println("============================================================");
    }

    private Policy buildPolicy(User user, int i, PolicyStatus status, String policyNumberPrefix) {
        boolean incomeProtection = i % 2 == 0;
        String productType = incomeProtection ? "Income Protection" : "Excess Fee Cover";
        String[] tiers = {"BRONZE", "SILVER", "GOLD"};
        String tier = tiers[i % 3];

        BigDecimal premium;
        BigDecimal benefit;
        String benefitDetails;

        if (incomeProtection) {
            switch (tier) {
                case "SILVER":
                    premium = BigDecimal.valueOf(189); benefit = BigDecimal.valueOf(5000);
                    benefitDetails = "Up to 6 monthly payouts"; break;
                case "GOLD":
                    premium = BigDecimal.valueOf(329); benefit = BigDecimal.valueOf(9000);
                    benefitDetails = "Up to 9 monthly payouts"; break;
                default:
                    premium = BigDecimal.valueOf(99); benefit = BigDecimal.valueOf(2500);
                    benefitDetails = "Up to 3 monthly payouts";
            }
        } else {
            switch (tier) {
                case "SILVER":
                    premium = BigDecimal.valueOf(149); benefit = BigDecimal.valueOf(7500);
                    benefitDetails = "2 excess payouts per 12 months"; break;
                case "GOLD":
                    premium = BigDecimal.valueOf(259); benefit = BigDecimal.valueOf(15000);
                    benefitDetails = "Unlimited excess payouts per 12 months"; break;
                default:
                    premium = BigDecimal.valueOf(79); benefit = BigDecimal.valueOf(3500);
                    benefitDetails = "1 excess payout per 12 months";
            }
        }

        Policy policy = new Policy();
        policy.setUser(user);
        policy.setProductType(productType);
        policy.setTier(tier);
        policy.setMonthlyPremium(premium);
        policy.setBenefitAmount(benefit);
        policy.setBenefitDetails(benefitDetails);
        policy.setPaymentMethod("EFT");
        policy.setPolicyNumber(policyNumberPrefix + i);
        policy.setStartDate(LocalDateTime.now().minusMonths(1 + (i % 6)));
        policy.setWaitingPeriodEnds(LocalDateTime.now().plusMonths(9));
        policy.setStatus(status);
        return policy;
    }

    private void seedClaim(User user, Policy policy, String claimType, ClaimStatus status,
                            String declineReason, BigDecimal payoutAmount) {
        Claim claim = new Claim();
        claim.setUser(user);
        claim.setPolicy(policy);
        claim.setClaimType(claimType);
        claim.setDescription("Demo claim for testing - " + claimType.toLowerCase() + ".");
        claim.setStatus(status);

        if (status == ClaimStatus.APPROVED || status == ClaimStatus.PAID) {
            claim.setApprovedAt(LocalDateTime.now().minusDays(2));
            claim.setReviewedAt(LocalDateTime.now().minusDays(2));
        }
        if (status == ClaimStatus.DECLINED) {
            claim.setDeclineReason(declineReason);
            claim.setReviewedAt(LocalDateTime.now().minusDays(1));
        }
        if (status == ClaimStatus.PAID) {
            claim.setPaidAt(LocalDateTime.now().minusDays(1));
            claim.setPayoutAmount(payoutAmount);
            claim.setPayoutReference("PAYREF-DEMO-" + user.getId());
        }

        claimRepository.save(claim);
    }
}
