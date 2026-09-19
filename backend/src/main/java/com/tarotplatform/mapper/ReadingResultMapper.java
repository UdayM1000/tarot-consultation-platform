package com.tarotplatform.mapper;

import com.tarotplatform.dto.reading.ReadingResultResponse;
import com.tarotplatform.dto.reading.RuneDto;
import com.tarotplatform.dto.reading.TarotCardDto;
import com.tarotplatform.entity.ReadingResult;
import com.tarotplatform.entity.RuneReading;
import com.tarotplatform.entity.TarotCardReading;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Component
public class ReadingResultMapper {

    public ReadingResultResponse toResponse(ReadingResult result) {
        if (result == null) {
            return null;
        }

        List<TarotCardDto> cards = result.getTarotCards() != null ? result.getTarotCards().stream()
                .map(this::toCardDto)
                .toList() : new ArrayList<>();

        List<RuneDto> runes = result.getRuneReadings() != null ? result.getRuneReadings().stream()
                .map(this::toRuneDto)
                .toList() : new ArrayList<>();

        return ReadingResultResponse.builder()
                .id(result.getId())
                .bookingId(result.getBooking() != null ? result.getBooking().getId() : null)
                .bookingReference(result.getBooking() != null ? result.getBooking().getBookingReference() : null)
                .customerId(result.getBooking() != null && result.getBooking().getCustomer() != null ? result.getBooking().getCustomer().getId() : null)
                .customerName(result.getBooking() != null && result.getBooking().getCustomer() != null ? result.getBooking().getCustomer().getName() : null)
                .customerEmail(result.getBooking() != null && result.getBooking().getCustomer() != null ? result.getBooking().getCustomer().getEmail() : null)
                .serviceName(result.getBooking() != null && result.getBooking().getReadingService() != null ? result.getBooking().getReadingService().getName() : null)
                .summary(result.getSummary())
                .advice(result.getAdvice())
                .outcome(result.getOutcome())
                .additionalNotes(result.getAdditionalNotes())
                .tarotCards(cards)
                .runeReadings(runes)
                .createdAt(result.getCreatedAt())
                .updatedAt(result.getUpdatedAt())
                .build();
    }

    public TarotCardDto toCardDto(TarotCardReading card) {
        if (card == null) {
            return null;
        }
        return TarotCardDto.builder()
                .id(card.getId())
                .cardName(card.getCardName())
                .position(card.getPosition())
                .interpretation(card.getInterpretation())
                .build();
    }

    public RuneDto toRuneDto(RuneReading rune) {
        if (rune == null) {
            return null;
        }
        return RuneDto.builder()
                .id(rune.getId())
                .runeName(rune.getRuneName())
                .position(rune.getPosition())
                .interpretation(rune.getInterpretation())
                .build();
    }
}
