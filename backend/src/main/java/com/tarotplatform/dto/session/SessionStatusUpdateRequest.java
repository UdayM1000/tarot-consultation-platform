package com.tarotplatform.dto.session;

import com.tarotplatform.enums.SessionStatus;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SessionStatusUpdateRequest {

    @NotNull(message = "Session status is required")
    private SessionStatus status;
}
