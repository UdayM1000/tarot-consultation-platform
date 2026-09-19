package com.tarotplatform.service.impl;

import com.tarotplatform.dto.user.ChangePasswordRequest;
import com.tarotplatform.dto.user.UpdateProfileRequest;
import com.tarotplatform.dto.user.UserResponse;
import com.tarotplatform.entity.AuditLog;
import com.tarotplatform.entity.User;
import com.tarotplatform.exception.ResourceNotFoundException;
import com.tarotplatform.exception.UnauthorizedException;
import com.tarotplatform.mapper.UserMapper;
import com.tarotplatform.repository.AuditLogRepository;
import com.tarotplatform.repository.UserRepository;
import com.tarotplatform.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final AuditLogRepository auditLogRepository;

    @Override
    @Transactional(readOnly = true)
    public UserResponse getCurrentUser(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + email));
        return userMapper.toResponse(user);
    }

    @Override
    @Transactional
    public UserResponse updateProfile(String email, UpdateProfileRequest request) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + email));

        user.setName(request.getName().trim());
        if (request.getPhone() != null) {
            user.setPhone(request.getPhone().trim());
        }
        if (request.getProfileImage() != null) {
            user.setProfileImage(request.getProfileImage().trim());
        }

        User updated = userRepository.save(user);

        auditLogRepository.save(AuditLog.builder()
                .userId(updated.getId())
                .action("USER_PROFILE_UPDATED")
                .details("Updated profile details for " + email)
                .build());

        return userMapper.toResponse(updated);
    }

    @Override
    @Transactional
    public void changePassword(String email, ChangePasswordRequest request) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + email));

        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            throw new UnauthorizedException("Current password provided does not match");
        }

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        auditLogRepository.save(AuditLog.builder()
                .userId(user.getId())
                .action("USER_PASSWORD_CHANGED")
                .details("Password changed for " + email)
                .build());
    }
}
