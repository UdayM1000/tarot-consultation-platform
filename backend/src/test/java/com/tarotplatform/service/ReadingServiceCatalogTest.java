package com.tarotplatform.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tarotplatform.dto.auth.LoginRequest;
import com.tarotplatform.dto.service.CreateReadingServiceRequest;
import com.tarotplatform.dto.service.ServiceStatusUpdateRequest;
import com.tarotplatform.dto.service.UpdateReadingServiceRequest;
import com.tarotplatform.repository.ReadingServiceRepository;
import com.tarotplatform.repository.ServiceCategoryRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class ReadingServiceCatalogTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private ServiceCategoryRepository categoryRepository;

    @Autowired
    private ReadingServiceRepository readingServiceRepository;

    private String adminToken;
    private String customerToken;

    @BeforeEach
    void setUp() throws Exception {
        LoginRequest adminLogin = LoginRequest.builder()
                .email("admin@tarotplatform.com")
                .password("Password@123")
                .build();

        MvcResult adminResult = mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(adminLogin)))
                .andExpect(status().isOk())
                .andReturn();

        adminToken = objectMapper.readTree(adminResult.getResponse().getContentAsString())
                .get("accessToken").asText();

        LoginRequest customerLogin = LoginRequest.builder()
                .email("customer@tarotplatform.com")
                .password("Password@123")
                .build();

        MvcResult customerResult = mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(customerLogin)))
                .andExpect(status().isOk())
                .andReturn();

        customerToken = objectMapper.readTree(customerResult.getResponse().getContentAsString())
                .get("accessToken").asText();
    }

    @Test
    @DisplayName("Public: should fetch all seeded active reading services")
    void testGetPublicServices() throws Exception {
        mockMvc.perform(get("/api/v1/services"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content").isArray())
                .andExpect(jsonPath("$.totalElements").value(10))
                .andExpect(jsonPath("$.content[0].price").isNumber());
    }

    @Test
    @DisplayName("Public: should fetch service by valid ID")
    void testGetServiceById() throws Exception {
        var service = readingServiceRepository.findBySlug("yes-no-tarot").orElseThrow();

        mockMvc.perform(get("/api/v1/services/" + service.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Yes / No Tarot"))
                .andExpect(jsonPath("$.price").value(50.00))
                .andExpect(jsonPath("$.durationMinutes").value(15))
                .andExpect(jsonPath("$.categoryName").value("TAROT"));
    }

    @Test
    @DisplayName("Public: should fetch service by valid slug")
    void testGetServiceBySlug() throws Exception {
        mockMvc.perform(get("/api/v1/services/slug/tarot-rune-confirmation"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Tarot + Rune Confirmation"))
                .andExpect(jsonPath("$.price").value(150.00));
    }

    @Test
    @DisplayName("Public: should fetch all active categories")
    void testGetCategories() throws Exception {
        mockMvc.perform(get("/api/v1/services/categories"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(3));
    }

    @Test
    @DisplayName("Admin: should create new reading service successfully")
    void testAdminCreateService() throws Exception {
        var category = categoryRepository.findByNameIgnoreCase("TAROT").orElseThrow();

        CreateReadingServiceRequest request = CreateReadingServiceRequest.builder()
                .categoryId(category.getId())
                .name("Celtic Cross In-Depth")
                .slug("celtic-cross-in-depth")
                .description("Traditional 10-card Celtic Cross spread revealing deep life trajectories.")
                .price(new BigDecimal("180.00"))
                .durationMinutes(60)
                .questionRequired(true)
                .cardCountDescription("10 tarot cards compulsory")
                .build();

        mockMvc.perform(post("/api/v1/admin/services")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").isNotEmpty())
                .andExpect(jsonPath("$.slug").value("celtic-cross-in-depth"))
                .andExpect(jsonPath("$.price").value(180.00));

        assertThat(readingServiceRepository.findBySlug("celtic-cross-in-depth")).isPresent();
    }

    @Test
    @DisplayName("Admin: should update service pricing and details")
    void testAdminUpdateService() throws Exception {
        var service = readingServiceRepository.findBySlug("yes-no-tarot").orElseThrow();

        UpdateReadingServiceRequest updateReq = UpdateReadingServiceRequest.builder()
                .categoryId(service.getCategory().getId())
                .name("Yes / No Tarot (Express)")
                .slug("yes-no-tarot")
                .description("Updated description with rapid clarity.")
                .price(new BigDecimal("65.00"))
                .durationMinutes(15)
                .active(true)
                .questionRequired(true)
                .cardCountDescription("3 tarot cards")
                .build();

        mockMvc.perform(put("/api/v1/admin/services/" + service.getId())
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Yes / No Tarot (Express)"))
                .andExpect(jsonPath("$.price").value(65.00));
    }

    @Test
    @DisplayName("Admin: should toggle service status via PATCH")
    void testAdminPatchServiceStatus() throws Exception {
        var service = readingServiceRepository.findBySlug("general-guidance").orElseThrow();

        ServiceStatusUpdateRequest patchReq = new ServiceStatusUpdateRequest(false);

        mockMvc.perform(patch("/api/v1/admin/services/" + service.getId() + "/status")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(patchReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.active").value(false));

        var updated = readingServiceRepository.findById(service.getId()).orElseThrow();
        assertThat(updated.getActive()).isFalse();
    }

    @Test
    @DisplayName("Security: customer must be forbidden from managing services (403)")
    void testCustomerCannotManageServices() throws Exception {
        var category = categoryRepository.findByNameIgnoreCase("TAROT").orElseThrow();

        CreateReadingServiceRequest request = CreateReadingServiceRequest.builder()
                .categoryId(category.getId())
                .name("Illegal Customer Service")
                .slug("illegal-customer-service")
                .description("Should be rejected.")
                .price(new BigDecimal("10.00"))
                .durationMinutes(30)
                .build();

        mockMvc.perform(post("/api/v1/admin/services")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden());
    }
}
