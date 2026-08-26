package com.viegym.preference.api;

import java.time.OffsetDateTime;
import java.util.List;

public record EquipmentPreferenceResponse(
        List<Long> selectedEquipmentIds,
        List<EquipmentItem> equipment,
        OffsetDateTime equipmentOnboardingCompletedAt) {

    public record EquipmentItem(Long id, String code, String name, boolean selected) {}
}
