package com.tarotplatform.util;

import java.time.Year;
import java.util.concurrent.atomic.AtomicLong;

public final class BookingReferenceGenerator {

    private static final AtomicLong SEQUENCE = new AtomicLong(System.currentTimeMillis() % 1000000);

    private BookingReferenceGenerator() {
    }

    public static String generateReference() {
        int year = Year.now().getValue();
        long seq = SEQUENCE.incrementAndGet() % 1000000;
        return String.format("TR-%d-%06d", year, Math.abs(seq));
    }
}
