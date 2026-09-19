package com.tarotplatform.service;

import com.tarotplatform.dto.user.ChangePasswordRequest;
import com.tarotplatform.dto.user.UpdateProfileRequest;
import com.tarotplatform.dto.user.UserResponse;

public interface UserService {

    UserResponse getCurrentUser(String email);

    UserResponse updateProfile(String email, UpdateProfileRequest request);

    void changePassword(String email, ChangePasswordRequest request);
}
