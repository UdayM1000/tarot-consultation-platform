package com.tarotplatform.service;

import com.tarotplatform.dto.user.NotificationResponse;
import com.tarotplatform.entity.Notification;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface NotificationService {

    void notifyUser(Notification notification);

    Page<NotificationResponse> getUserNotifications(String email, Pageable pageable);

    void markAsRead(Long notificationId, String email);

    long getUnreadCount(String email);
}
