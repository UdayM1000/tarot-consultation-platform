package com.tarotplatform.service.impl;

import com.tarotplatform.dto.payment.PaymentOrderResponse;
import com.tarotplatform.dto.payment.PaymentResponse;
import com.tarotplatform.dto.payment.PaymentVerificationRequest;
import com.tarotplatform.entity.AuditLog;
import com.tarotplatform.entity.Booking;
import com.tarotplatform.entity.Notification;
import com.tarotplatform.entity.Payment;
import com.tarotplatform.entity.User;
import com.tarotplatform.enums.BookingStatus;
import com.tarotplatform.enums.NotificationType;
import com.tarotplatform.enums.PaymentStatus;
import com.tarotplatform.enums.Role;
import com.tarotplatform.exception.ForbiddenException;
import com.tarotplatform.exception.InvalidBookingException;
import com.tarotplatform.exception.PaymentException;
import com.tarotplatform.exception.ResourceNotFoundException;
import com.tarotplatform.mapper.PaymentMapper;
import com.tarotplatform.repository.AuditLogRepository;
import com.tarotplatform.repository.BookingRepository;
import com.tarotplatform.repository.NotificationRepository;
import com.tarotplatform.repository.PaymentRepository;
import com.tarotplatform.repository.UserRepository;
import com.tarotplatform.service.PaymentGatewayProvider;
import com.tarotplatform.service.PaymentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class PaymentServiceImpl implements PaymentService {

    private final BookingRepository bookingRepository;
    private final PaymentRepository paymentRepository;
    private final UserRepository userRepository;
    private final NotificationRepository notificationRepository;
    private final AuditLogRepository auditLogRepository;
    private final PaymentGatewayProvider paymentGatewayProvider;
    private final PaymentMapper paymentMapper;

    @Override
    @Transactional
    public PaymentOrderResponse createOrder(Long bookingId, String customerEmail) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found with ID: " + bookingId));

        User customer = userRepository.findByEmail(customerEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Customer account not found"));

        if (!booking.getCustomer().getId().equals(customer.getId()) && !customer.getRoles().contains(Role.ADMIN)) {
            throw new ForbiddenException("You can only initiate payment for your own bookings.");
        }

        if (booking.getStatus() == BookingStatus.CONFIRMED || booking.getStatus() == BookingStatus.COMPLETED) {
            throw new InvalidBookingException("This consultation booking is already confirmed or completed.");
        }

        if (booking.getStatus() == BookingStatus.CANCELLED) {
            throw new InvalidBookingException("Cannot initiate payment for a cancelled booking.");
        }

        // Delegate to gateway provider with server-side locked price
        PaymentOrderResponse orderResponse = paymentGatewayProvider.createOrder(booking);

        Payment payment = Payment.builder()
                .booking(booking)
                .transactionId(orderResponse.getTransactionId())
                .provider(orderResponse.getProvider())
                .amount(booking.getPriceAtBooking())
                .currency(orderResponse.getCurrency())
                .status(PaymentStatus.INITIATED)
                .build();

        paymentRepository.save(payment);

        auditLogRepository.save(AuditLog.builder()
                .userId(customer.getId())
                .action("PAYMENT_ORDER_CREATED")
                .details("Created payment order " + orderResponse.getOrderId() + " for booking " + booking.getBookingReference() + " [Amount: ₹" + booking.getPriceAtBooking() + "]")
                .build());

        return orderResponse;
    }

    @Override
    @Transactional
    public PaymentResponse verifyPayment(PaymentVerificationRequest request, String customerEmail) {
        Payment payment = paymentRepository.findByTransactionId(request.getTransactionId())
                .orElseThrow(() -> new ResourceNotFoundException("Payment transaction not found for ID: " + request.getTransactionId()));

        Booking booking = payment.getBooking();
        User customer = userRepository.findByEmail(customerEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Customer account not found"));

        if (!booking.getCustomer().getId().equals(customer.getId()) && !customer.getRoles().contains(Role.ADMIN)) {
            throw new ForbiddenException("You cannot verify payment for another user's booking.");
        }

        boolean isVerified = paymentGatewayProvider.verifyPayment(request, booking);

        if (isVerified) {
            payment.setStatus(PaymentStatus.SUCCESS);
            booking.setStatus(BookingStatus.CONFIRMED);

            bookingRepository.save(booking);
            Payment updatedPayment = paymentRepository.save(payment);

            notificationRepository.save(Notification.builder()
                    .user(customer)
                    .title("Payment Successful")
                    .message("Payment of ₹" + payment.getAmount() + " confirmed for booking " + booking.getBookingReference() + ".")
                    .type(NotificationType.PAYMENT_SUCCESS)
                    .isRead(false)
                    .build());

            auditLogRepository.save(AuditLog.builder()
                    .userId(customer.getId())
                    .action("PAYMENT_SUCCESS")
                    .details("Verified payment " + payment.getTransactionId() + " of ₹" + payment.getAmount() + " for booking " + booking.getBookingReference())
                    .build());

            log.info("Payment successfully verified for transaction: {}", payment.getTransactionId());
            return paymentMapper.toResponse(updatedPayment);
        } else {
            payment.setStatus(PaymentStatus.FAILED);
            paymentRepository.save(payment);

            auditLogRepository.save(AuditLog.builder()
                    .userId(customer.getId())
                    .action("PAYMENT_FAILED")
                    .details("Payment verification failed for transaction " + payment.getTransactionId())
                    .build());

            throw new PaymentException("Payment verification failed for transaction: " + request.getTransactionId());
        }
    }

    @Override
    @Transactional
    public void handleWebhook(String payload, String signature) {
        paymentGatewayProvider.processWebhook(payload, signature);

        auditLogRepository.save(AuditLog.builder()
                .action("PAYMENT_WEBHOOK_RECEIVED")
                .details("Received webhook payload: " + (payload.length() > 200 ? payload.substring(0, 200) : payload))
                .build());
    }
}
