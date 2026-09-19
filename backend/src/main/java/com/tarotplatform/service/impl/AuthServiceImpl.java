package com.tarotplatform.service.impl;

import com.tarotplatform.dto.auth.AuthResponse;
import com.tarotplatform.dto.auth.LoginRequest;
import com.tarotplatform.dto.auth.RefreshTokenRequest;
import com.tarotplatform.dto.auth.RegisterRequest;
import com.tarotplatform.dto.user.UserResponse;
import com.tarotplatform.entity.AuditLog;
import com.tarotplatform.entity.User;
import com.tarotplatform.enums.Role;
import com.tarotplatform.exception.UnauthorizedException;
import com.tarotplatform.mapper.UserMapper;
import com.tarotplatform.repository.AuditLogRepository;
import com.tarotplatform.repository.UserRepository;
import com.tarotplatform.security.JwtTokenProvider;
import com.tarotplatform.service.AuthService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider tokenProvider;
    private final UserMapper userMapper;
    private final AuditLogRepository auditLogRepository;

    @Override
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        String email = request.getEmail().trim().toLowerCase();

        if (userRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("An account with email " + email + " already exists");
        }

        User user = User.builder()
                .name(request.getName().trim())
                .email(email)
                .phone(request.getPhone() != null ? request.getPhone().trim() : null)
                .password(passwordEncoder.encode(request.getPassword()))
                .isActive(true)
                .roles(new HashSet<>(Set.of(Role.CUSTOMER)))
                .build();

        User savedUser = userRepository.save(user);

        auditLogRepository.save(AuditLog.builder()
                .userId(savedUser.getId())
                .action("USER_REGISTERED")
                .details("Registered account with email: " + savedUser.getEmail())
                .build());

        List<String> roleNames = savedUser.getRoles().stream()
                .map(r -> "ROLE_" + r.name())
                .toList();

        String accessToken = tokenProvider.generateAccessToken(savedUser.getEmail(), savedUser.getId(), roleNames);
        String refreshToken = tokenProvider.generateRefreshToken(savedUser.getEmail(), savedUser.getId());

        UserResponse userResponse = userMapper.toResponse(savedUser);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(tokenProvider.getExpirationMs())
                .user(userResponse)
                .build();
    }

    @Override
    @Transactional
    public AuthResponse login(LoginRequest request) {
        String email = request.getEmail().trim().toLowerCase();

        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(email, request.getPassword())
        );

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UnauthorizedException("User not found"));

        if (!Boolean.TRUE.equals(user.getIsActive())) {
            throw new UnauthorizedException("User account is inactive. Please contact support.");
        }

        String accessToken = tokenProvider.generateAccessToken(authentication);
        String refreshToken = tokenProvider.generateRefreshToken(user.getEmail(), user.getId());

        auditLogRepository.save(AuditLog.builder()
                .userId(user.getId())
                .action("USER_LOGIN")
                .details("User successfully logged in: " + user.getEmail())
                .build());

        UserResponse userResponse = userMapper.toResponse(user);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(tokenProvider.getExpirationMs())
                .user(userResponse)
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public AuthResponse refreshToken(RefreshTokenRequest request) {
        String refreshToken = request.getRefreshToken();

        if (!tokenProvider.validateToken(refreshToken)) {
            throw new UnauthorizedException("Invalid or expired refresh token");
        }

        String tokenType = tokenProvider.getTokenType(refreshToken);
        if (!"REFRESH".equals(tokenType)) {
            throw new UnauthorizedException("Token is not a valid refresh token");
        }

        String email = tokenProvider.getUsernameFromToken(refreshToken);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UnauthorizedException("User not found for refresh token"));

        if (!Boolean.TRUE.equals(user.getIsActive())) {
            throw new UnauthorizedException("User account is deactivated");
        }

        List<String> roleNames = user.getRoles().stream()
                .map(r -> "ROLE_" + r.name())
                .toList();

        String newAccessToken = tokenProvider.generateAccessToken(user.getEmail(), user.getId(), roleNames);
        String newRefreshToken = tokenProvider.generateRefreshToken(user.getEmail(), user.getId());

        return AuthResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .tokenType("Bearer")
                .expiresIn(tokenProvider.getExpirationMs())
                .user(userMapper.toResponse(user))
                .build();
    }

    @Override
    @Transactional
    public void logout(String email) {
        userRepository.findByEmail(email).ifPresent(user -> {
            auditLogRepository.save(AuditLog.builder()
                    .userId(user.getId())
                    .action("USER_LOGOUT")
                    .details("User logged out: " + email)
                    .build());
        });
    }
}
