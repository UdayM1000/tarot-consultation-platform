package com.tarotplatform.service;

import com.tarotplatform.entity.Notification;

public interface NotificationChannel {

    String getChannelName();

    void dispatch(Notification notification);
}
