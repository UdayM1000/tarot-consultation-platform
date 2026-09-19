package com.tarotplatform.repository;

import com.tarotplatform.entity.PlatformPolicy;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PlatformPolicyRepository extends JpaRepository<PlatformPolicy, Long> {

    Optional<PlatformPolicy> findByPolicyKey(String policyKey);

    boolean existsByPolicyKey(String policyKey);
}
