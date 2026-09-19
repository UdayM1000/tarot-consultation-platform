package com.tarotplatform.service.impl;

import com.tarotplatform.entity.Notification;
import com.tarotplatform.repository.NotificationRepository;
import com.tarotplatform.service.NotificationChannel;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class DatabaseNotificationChannel implements NotificationChannel {

    private final NotificationRepository notificationRepository;

    @Override
    public String getChannelName() {
        return "DATABASE";
    }

    @Override
    public void dispatch(Notification notification) {
        notificationRepository.save(notification);
        log.info("Dispatched notification '{}' to user {}", notification.getTitle(), notification.getUser().getId());
    }
}
