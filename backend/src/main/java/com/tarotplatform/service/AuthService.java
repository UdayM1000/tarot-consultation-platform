package com.tarotplatform.service;

import com.tarotplatform.dto.auth.AuthResponse;
import com.tarotplatform.dto.auth.LoginRequest;
import com.tarotplatform.dto.auth.RefreshTokenRequest;
import com.tarotplatform.dto.auth.RegisterRequest;

public interface AuthService {

    AuthResponse register(RegisterRequest request);

    AuthResponse login(LoginRequest request);

    AuthResponse refreshToken(RefreshTokenRequest request);

    void logout(String email);
}
