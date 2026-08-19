package com.claimly.backend.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

/**
 * All outbound Claimly emails, styled to actually look like a real
 * insurer rather than a plain-text debug message. Every failure here is
 * swallowed and logged rather than thrown - a flaky email server should
 * never block registration, OTP, or account approval.
 */
@Service
public class EmailService {

    private final JavaMailSender mailSender;

    private static final String BRAND_GREEN = "#49D86A";
    private static final String BRAND_DARK = "#081814";
    private static final String BRAND_CARD = "#0D2A22";

    public EmailService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    public void sendOtpEmail(String toEmail, String fullName, String otpCode) {
        String subject = "Your Claimly verification code";
        String body = wrapper(
                "Verify your email",
                "Hi " + escape(firstName(fullName)) + ",",
                "Enter this code in the Claimly app to verify your email address:",
                otpBlock(otpCode) +
                        paragraph("This code expires in <strong>5 minutes</strong>. If you didn't request it, you can safely ignore this email.")
        );
        send(toEmail, subject, body);
    }

    public void sendAccountApprovedEmail(String toEmail, String fullName) {
        String subject = "Your Claimly account has been approved";
        String body = wrapper(
                "You're approved!",
                "Hi " + escape(firstName(fullName)) + ",",
                "Good news - your Claimly account has been reviewed and approved. You can now log in and choose your cover.",
                calloutBlock("&#10003; Account approved", "You can select a plan and activate your policy right away.") +
                        paragraph("If you have any questions, our team is here to help via the in-app support link.")
        );
        send(toEmail, subject, body);
    }

    public void sendAccountSuspendedEmail(String toEmail, String fullName) {
        String subject = "Your Claimly account has been suspended";
        String body = wrapper(
                "Account suspended",
                "Hi " + escape(firstName(fullName)) + ",",
                "Your Claimly account has been suspended and you will not be able to log in until this is resolved.",
                paragraph("If you believe this is a mistake, please contact our support team.")
        );
        send(toEmail, subject, body);
    }

    public void sendPromotedToAdminEmail(String toEmail, String fullName) {
        String subject = "You've been made a Claimly Admin";
        String body = wrapper(
                "You're now an Admin",
                "Hi " + escape(firstName(fullName)) + ",",
                "Your Claimly account has been given Admin access. You can now review new registrations and manage customer accounts.",
                calloutBlock("&#9733; Admin access granted", "Log in to see the Admin dashboard.") +
                        paragraph("If you weren't expecting this, please contact a Super Admin.")
        );
        send(toEmail, subject, body);
    }

    public void sendDemotedToCustomerEmail(String toEmail, String fullName) {
        String subject = "Your Claimly account access has changed";
        String body = wrapper(
                "Account access changed",
                "Hi " + escape(firstName(fullName)) + ",",
                "Your Claimly account has been changed from Admin back to a standard Customer account. You no longer have access to the Admin dashboard.",
                paragraph("You can still log in and use Claimly as a customer as normal. If you believe this is a mistake, please contact a Super Admin.")
        );
        send(toEmail, subject, body);
    }

    public void sendCoverSubmittedEmail(String toEmail, String fullName, String productType, String tier) {
        String subject = "We've received your cover selection";
        String body = wrapper(
                "Cover submitted",
                "Hi " + escape(firstName(fullName)) + ",",
                "Thanks for choosing your cover. It's now awaiting approval from our team before it becomes active.",
                calloutBlock("&#8987; Pending approval", escape(productType) + " - " + escape(tier) + " tier") +
                        paragraph("We'll email you as soon as it's approved - usually within 1 business day.")
        );
        send(toEmail, subject, body);
    }

    public void sendCoverApprovedEmail(String toEmail, String fullName, String productType, String tier, String policyNumber) {
        String subject = "Your cover is now active";
        String body = wrapper(
                "You're covered!",
                "Hi " + escape(firstName(fullName)) + ",",
                "Great news - your cover has been approved and is now active.",
                calloutBlock("&#10003; " + escape(productType) + " - " + escape(tier) + " tier",
                        "Policy number: " + escape(policyNumber)) +
                        paragraph("You can view your full policy details any time in the Claimly app.")
        );
        send(toEmail, subject, body);
    }

    public void sendClaimDecisionEmail(String toEmail, String fullName, String claimReference, boolean approved, String declineReason) {
        String subject = approved ? "Your claim has been approved" : "Update on your claim";
        String body;
        if (approved) {
            body = wrapper(
                    "Claim approved",
                    "Hi " + escape(firstName(fullName)) + ",",
                    "Your claim has been reviewed and approved.",
                    calloutBlock("&#10003; Claim " + escape(claimReference) + " approved", "Payout details will follow separately.") +
                            paragraph("Thank you for your patience while we reviewed your claim.")
            );
        } else {
            body = wrapper(
                    "Claim update",
                    "Hi " + escape(firstName(fullName)) + ",",
                    "Your claim has been reviewed and was not approved this time.",
                    calloutBlock("Claim " + escape(claimReference) + " declined",
                            declineReason != null && !declineReason.isBlank() ? escape(declineReason) : "Please contact support for more detail.") +
                            paragraph("If you have supporting documents you'd like to add, you can resubmit or reach out via the in-app support link.")
            );
        }
        send(toEmail, subject, body);
    }

    public void sendClaimPaidEmail(String toEmail, String fullName, String claimReference, String payoutAmount, String payoutReference) {
        String subject = "Your claim payout has been made";
        String body = wrapper(
                "Payout sent",
                "Hi " + escape(firstName(fullName)) + ",",
                "Your approved claim has now been paid out.",
                calloutBlock("&#10003; R" + escape(payoutAmount) + " paid",
                        "Claim " + escape(claimReference) + " - Reference: " + escape(payoutReference)) +
                        paragraph("Please allow up to 2 business days for the funds to reflect, depending on your bank or payment provider.")
        );
        send(toEmail, subject, body);
    }

    public void sendPaymentReminderEmail(String toEmail, String fullName, String amount, String dueDate) {
        String subject = "Your Claimly payment is due soon";
        String body = wrapper(
                "Payment reminder",
                "Hi " + escape(firstName(fullName)) + ",",
                "Your next Claimly premium is coming up.",
                calloutBlock("R" + escape(amount) + " due", "Due date: " + escape(dueDate)) +
                        paragraph("Please make your payment before the due date to keep your cover active and avoid a late payment penalty.")
        );
        send(toEmail, subject, body);
    }

    public void sendPaymentOverdueSuspendedEmail(String toEmail, String fullName, String amountWithPenalty) {
        String subject = "Your Claimly cover has been suspended";
        String body = wrapper(
                "Cover suspended - payment overdue",
                "Hi " + escape(firstName(fullName)) + ",",
                "We didn't receive your premium payment by the due date, so your cover has been suspended. A late payment penalty has been added.",
                calloutBlock("R" + escape(amountWithPenalty) + " now due", "Includes a R20 late payment penalty") +
                        paragraph("Your cover - and your ability to submit claims - will be reactivated as soon as your payment is received and confirmed.")
        );
        send(toEmail, subject, body);
    }

    public void sendPaymentReceivedEmail(String toEmail, String fullName, String amount) {
        String subject = "Payment received - your cover is active";
        String body = wrapper(
                "Payment received",
                "Hi " + escape(firstName(fullName)) + ",",
                "Thanks - we've received your payment and your cover is active.",
                calloutBlock("&#10003; R" + escape(amount) + " received", "Your account is now up to date.") +
                        paragraph("Your next payment will be due in one month.")
        );
        send(toEmail, subject, body);
    }

    public void sendProofOfPaymentSubmittedEmail(String toEmail, String fullName) {
        String subject = "We've received your proof of payment";
        String body = wrapper(
                "Proof of payment received",
                "Hi " + escape(firstName(fullName)) + ",",
                "Thanks for uploading your proof of payment. Our team will review it shortly.",
                paragraph("We'll email you as soon as it's been checked - usually within 1 business day.")
        );
        send(toEmail, subject, body);
    }

    public void sendProofOfPaymentRejectedEmail(String toEmail, String fullName, String reason) {
        String subject = "We couldn't confirm your proof of payment";
        String body = wrapper(
                "Proof of payment not accepted",
                "Hi " + escape(firstName(fullName)) + ",",
                "We reviewed the proof of payment you uploaded, but we weren't able to confirm it.",
                calloutBlock("Reason", reason != null && !reason.isBlank() ? escape(reason) : "Please contact support for more detail.") +
                        paragraph("Please upload a clearer proof of payment, or a new one if the original payment didn't go through, and we'll take another look.")
        );
        send(toEmail, subject, body);
    }

    private void send(String toEmail, String subject, String htmlBody) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, false, "UTF-8");
            helper.setTo(toEmail);
            helper.setSubject(subject);
            helper.setText(htmlBody, true);
            mailSender.send(message);
            System.out.println("Email sent to " + toEmail + ": " + subject);
        } catch (MessagingException | RuntimeException e) {
            System.out.println("Failed to send email to " + toEmail + ": " + e.getMessage());
        }
    }

    // ============ Small HTML template helpers ============

    private String wrapper(String heading, String greeting, String intro, String bodyHtml) {
        return "<!DOCTYPE html>" +
                "<html><body style=\"margin:0;padding:0;background-color:#f2f4f3;font-family:Arial,Helvetica,sans-serif;\">" +
                "<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"background-color:#f2f4f3;padding:32px 0;\">" +
                "<tr><td align=\"center\">" +
                "<table role=\"presentation\" width=\"480\" cellpadding=\"0\" cellspacing=\"0\" style=\"background-color:#ffffff;border-radius:16px;overflow:hidden;\">" +
                "<tr><td style=\"background-color:" + BRAND_DARK + ";padding:28px 32px;\">" +
                "<span style=\"color:#ffffff;font-size:20px;font-weight:bold;\">Claim<span style=\"color:" + BRAND_GREEN + ";\">ly</span></span>" +
                "</td></tr>" +
                "<tr><td style=\"padding:32px;\">" +
                "<h1 style=\"margin:0 0 16px 0;color:#111827;font-size:22px;\">" + escape(heading) + "</h1>" +
                "<p style=\"margin:0 0 8px 0;color:#374151;font-size:15px;\">" + escape(greeting) + "</p>" +
                "<p style=\"margin:0 0 20px 0;color:#374151;font-size:15px;line-height:1.5;\">" + escape(intro) + "</p>" +
                bodyHtml +
                "</td></tr>" +
                "<tr><td style=\"background-color:#f9fafb;padding:20px 32px;\">" +
                "<p style=\"margin:0;color:#9ca3af;font-size:12px;\">Claimly &middot; Income Protection &amp; Excess Fee Cover for every South African worker.</p>" +
                "</td></tr>" +
                "</table>" +
                "</td></tr>" +
                "</table>" +
                "</body></html>";
    }

    private String otpBlock(String otpCode) {
        StringBuilder digits = new StringBuilder();
        for (char c : otpCode.toCharArray()) {
            digits.append("<span style=\"display:inline-block;width:38px;height:48px;line-height:48px;margin:0 4px;background-color:" + BRAND_CARD + ";color:#ffffff;font-size:24px;font-weight:bold;border-radius:8px;text-align:center;\">")
                    .append(c)
                    .append("</span>");
        }
        return "<div style=\"text-align:center;margin:24px 0;\">" + digits + "</div>";
    }

    private String calloutBlock(String title, String subtitle) {
        return "<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"margin:8px 0 20px 0;\">" +
                "<tr><td style=\"background-color:#ecfdf3;border:1px solid " + BRAND_GREEN + ";border-radius:12px;padding:16px 20px;\">" +
                "<p style=\"margin:0 0 4px 0;color:#0f5132;font-size:16px;font-weight:bold;\">" + title + "</p>" +
                "<p style=\"margin:0;color:#0f5132;font-size:13px;\">" + escape(subtitle) + "</p>" +
                "</td></tr></table>";
    }

    private String paragraph(String htmlSafeText) {
        return "<p style=\"margin:0;color:#6b7280;font-size:13px;line-height:1.6;\">" + htmlSafeText + "</p>";
    }

    private String firstName(String fullName) {
        if (fullName == null || fullName.isBlank()) return "there";
        return fullName.trim().split("\\s+")[0];
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }
}
