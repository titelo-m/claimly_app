package com.claimly.backend.service;

import com.claimly.backend.dto.request.GoogleLoginRequest;
import com.claimly.backend.dto.request.LoginRequest;
import com.claimly.backend.dto.request.OTPRequest;
import com.claimly.backend.dto.request.RegisterRequest;
import com.claimly.backend.dto.response.AuthResponse;
import com.claimly.backend.dto.response.UserProfileResponse;
import com.claimly.backend.entity.OTP;
import com.claimly.backend.entity.Policy;
import com.claimly.backend.entity.User;
import com.claimly.backend.repository.OTPRepository;
import com.claimly.backend.repository.UserRepository;
import com.claimly.backend.security.JwtService;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.Random;

@Service
public class AuthService {
    
    private final UserRepository userRepository;
    private final OTPRepository otpRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    
    @Autowired
    private JavaMailSender mailSender;
    
    public AuthService(UserRepository userRepository, OTPRepository otpRepository,
                       PasswordEncoder passwordEncoder, JwtService jwtService,
                       AuthenticationManager authenticationManager) {
        this.userRepository = userRepository;
        this.otpRepository = otpRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
    }
    
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        // Validate SA ID (Luhn algorithm)
        if (!isValidSAID(request.getIdNumber())) {
            throw new RuntimeException("Invalid SA ID number");
        }
        
        // Check if user exists
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already registered");
        }
        if (userRepository.existsByPhoneNumber(request.getPhoneNumber())) {
            throw new RuntimeException("Phone number already registered");
        }
        if (userRepository.existsByIdNumber(request.getIdNumber())) {
            throw new RuntimeException("ID number already registered");
        }
        
        // Create user
        User user = new User();
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setFullName(request.getFullName());
        user.setIdNumber(request.getIdNumber());
        user.setPhoneNumber(request.getPhoneNumber());

        try {
            user.setDateOfBirth(java.time.LocalDate.parse(request.getDateOfBirth()));
        } catch (Exception e) {
            throw new RuntimeException("Please enter a valid date of birth");
        }
        user.setGender(request.getGender());
        user.setEmploymentStatus(request.getEmploymentStatus());
        user.setOccupation(request.getOccupation());
        user.setMonthlyIncome(request.getMonthlyIncome());
        user.setNextOfKinName(request.getNextOfKinName());
        user.setNextOfKinPhone(request.getNextOfKinPhone());
        // New accounts wait for an admin/super-admin to approve them before
        // they can select cover. See PolicyService.selectCover().
        user.setStatus(com.claimly.backend.entity.enums.UserStatus.PENDING_APPROVAL);
        
        user = userRepository.save(user);
        
        // Generate JWT token
        UserDetails userDetails = new org.springframework.security.core.userdetails.User(
                user.getEmail(),
                user.getPassword(),
                Collections.emptyList()
        );
        String token = jwtService.generateToken(userDetails);
        
        return buildAuthResponse(user, token);
    }
    
    public AuthResponse login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );
        
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (user.getStatus() == com.claimly.backend.entity.enums.UserStatus.SUSPENDED) {
            throw new RuntimeException("Your account has been suspended. Please contact support.");
        }
        
        UserDetails userDetails = new org.springframework.security.core.userdetails.User(
                user.getEmail(),
                user.getPassword(),
                Collections.emptyList()
        );
        String token = jwtService.generateToken(userDetails);
        
        return buildAuthResponse(user, token);
    }
    
    public AuthResponse googleLogin(GoogleLoginRequest request) {
        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(), new GsonFactory())
                    .setAudience(Collections.singletonList("YOUR_GOOGLE_CLIENT_ID"))
                    .build();
            
            GoogleIdToken idToken = verifier.verify(request.getIdToken());
            if (idToken == null) {
                throw new RuntimeException("Invalid Google ID token");
            }
            
            GoogleIdToken.Payload payload = idToken.getPayload();
            String email = payload.getEmail();
            String fullName = (String) payload.get("name");
            
            User user = userRepository.findByEmail(email).orElseGet(() -> {
                User newUser = new User();
                newUser.setEmail(email);
                newUser.setFullName(fullName);
                newUser.setPassword(passwordEncoder.encode("google_" + System.currentTimeMillis()));
                newUser.setIdNumber("0000000000000");
                newUser.setPhoneNumber("0000000000");
                newUser.setStatus(com.claimly.backend.entity.enums.UserStatus.PENDING_APPROVAL);
                return userRepository.save(newUser);
            });
            
            UserDetails userDetails = new org.springframework.security.core.userdetails.User(
                    user.getEmail(),
                    user.getPassword(),
                    Collections.emptyList()
            );
            String token = jwtService.generateToken(userDetails);
            
            return buildAuthResponse(user, token);
        } catch (Exception e) {
            throw new RuntimeException("Google authentication failed: " + e.getMessage());
        }
    }
    
    public void sendOTP(String phoneNumber) {
        User user = userRepository.findByPhoneNumber(phoneNumber)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        String otpCode = String.format("%06d", new Random().nextInt(999999));
        
        OTP otp = new OTP();
        otp.setUser(user);
        otp.setOtpCode(otpCode);
        otp.setPurpose("VERIFICATION");
        otp.setExpiresAt(LocalDateTime.now().plusMinutes(5));
        
        otpRepository.save(otp);
        
        // TODO: Send SMS via Twilio/AfricasTalking
        System.out.println("SMS OTP for " + phoneNumber + ": " + otpCode);
    }
    
    public void sendEmailOTP(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        String otpCode = String.format("%06d", new Random().nextInt(999999));
        
        OTP otp = new OTP();
        otp.setUser(user);
        otp.setOtpCode(otpCode);
        otp.setPurpose("EMAIL_VERIFICATION");
        otp.setExpiresAt(LocalDateTime.now().plusMinutes(5));
        
        otpRepository.save(otp);
        
        // Send email
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(email);
            message.setSubject("Claimly - Email Verification Code");
            message.setText(
                "Hello " + user.getFullName() + ",\n\n" +
                "Your Claimly verification code is: " + otpCode + "\n\n" +
                "This code expires in 5 minutes.\n\n" +
                "If you didn't request this code, please ignore this email.\n\n" +
                "Thank you,\n" +
                "The Claimly Team"
            );
            mailSender.send(message);
            System.out.println("Email OTP sent successfully to: " + email);
        } catch (Exception e) {
            System.out.println("Failed to send email: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    public boolean verifyOTP(OTPRequest request) {
        boolean isEmailMethod = "email".equalsIgnoreCase(request.getMethod());

        User user;
        if (isEmailMethod) {
            if (request.getEmail() == null || request.getEmail().isBlank()) {
                throw new RuntimeException("Email is required for email verification");
            }
            user = userRepository.findByEmail(request.getEmail())
                    .orElseThrow(() -> new RuntimeException("User not found"));
        } else {
            if (request.getPhoneNumber() == null || request.getPhoneNumber().isBlank()) {
                throw new RuntimeException("Phone number is required for phone verification");
            }
            user = userRepository.findByPhoneNumber(request.getPhoneNumber())
                    .orElseThrow(() -> new RuntimeException("User not found"));
        }

        OTP otp = otpRepository.findByUserAndOtpCodeAndUsedFalse(user, request.getOtpCode())
                .orElseThrow(() -> new RuntimeException("Invalid OTP"));
        
        if (otp.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("OTP has expired");
        }
        
        otp.setUsed(true);
        otpRepository.save(otp);
        
        if (isEmailMethod) {
            user.setEmailVerified(true);
        } else {
            user.setPhoneVerified(true);
        }
        userRepository.save(user);
        
        return true;
    }
    
    public UserProfileResponse getCurrentUser(String token) {
        String email = jwtService.extractUsername(token);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return buildProfileResponse(user);
    }
    
    private AuthResponse buildAuthResponse(User user, String token) {
        Policy policy = user.getPolicy();
        return AuthResponse.builder()
                .token(token)
                .email(user.getEmail())
                .fullName(user.getFullName())
                .phoneNumber(user.getPhoneNumber())
                .role(user.getRole().name())
                .status(user.getStatus().name())
                .hasCover(policy != null)
                .productType(policy != null ? policy.getProductType() : null)
                .tier(policy != null ? policy.getTier() : null)
                .paymentMethod(policy != null ? policy.getPaymentMethod() : null)
                .profilePictureUrl(user.getProfilePictureUrl())
                .build();
    }
    
    private UserProfileResponse buildProfileResponse(User user) {
        Policy policy = user.getPolicy();
        return UserProfileResponse.builder()
                .fullName(user.getFullName())
                .idNumber(user.getIdNumber())
                .phoneNumber(user.getPhoneNumber())
                .email(user.getEmail())
                .role(user.getRole().name())
                .status(user.getStatus().name())
                .dateOfBirth(user.getDateOfBirth())
                .gender(user.getGender())
                .employmentStatus(user.getEmploymentStatus())
                .occupation(user.getOccupation())
                .monthlyIncome(user.getMonthlyIncome())
                .nextOfKinName(user.getNextOfKinName())
                .nextOfKinPhone(user.getNextOfKinPhone())
                .profilePictureUrl(user.getProfilePictureUrl())
                .hasCover(policy != null)
                .productType(policy != null ? policy.getProductType() : null)
                .tier(policy != null ? policy.getTier() : null)
                .paymentMethod(policy != null ? policy.getPaymentMethod() : null)
                .monthlyPremium(policy != null ? policy.getMonthlyPremium() : null)
                .benefitAmount(policy != null ? policy.getBenefitAmount() : null)
                .benefitDetails(policy != null ? policy.getBenefitDetails() : null)
                .nextDebitDate(policy != null ? policy.getNextDebitDate() : null)
                .waitingPeriodEnds(policy != null ? policy.getWaitingPeriodEnds() : null)
                .build();
    }
    
    private boolean isValidSAID(String idNumber) {
        if (idNumber == null || idNumber.length() != 13) return false;
        if (!idNumber.matches("^[0-9]+$")) return false;
        
        int sum = 0;
        boolean alternate = false;
        
        for (int i = idNumber.length() - 1; i >= 0; i--) {
            int n = Character.getNumericValue(idNumber.charAt(i));
            if (alternate) {
                n *= 2;
                if (n > 9) {
                    n = (n % 10) + 1;
                }
            }
            sum += n;
            alternate = !alternate;
        }
        
        return sum % 10 == 0;
    }
}