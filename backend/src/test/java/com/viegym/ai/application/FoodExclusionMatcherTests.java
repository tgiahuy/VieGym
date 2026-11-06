package com.viegym.ai.application;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import org.junit.jupiter.api.Test;

class FoodExclusionMatcherTests {
    @Test
    void seafoodGroupExcludesFishAndShellfishButNotEggplantOrTomato() {
        FoodExclusionMatcher matcher = new FoodExclusionMatcher(List.of("Hải sản"), List.of());

        assertThat(matcher.excludes("Cá thu sốt cà", "ca thu sot ca")).isTrue();
        assertThat(matcher.excludes("Tôm hấp", "tom hap")).isTrue();
        assertThat(matcher.excludes("Mực xào", "muc xao")).isTrue();
        assertThat(matcher.excludes("Canh cà chua trứng", "canh ca chua trung")).isFalse();
        assertThat(matcher.excludes("Cà tím nướng", "ca tim nuong")).isFalse();
        assertThat(matcher.excludes("Ức gà luộc", "uc ga luoc")).isFalse();
    }

    @Test
    void unaccentedInputStillMapsToTheAllergyGroup() {
        FoodExclusionMatcher matcher = new FoodExclusionMatcher(List.of("dau phong"), List.of());

        assertThat(matcher.excludes("Xôi đậu phộng", "xoi dau phong")).isTrue();
        assertThat(matcher.excludes("Kẹo lạc", "keo lac")).isTrue();
        assertThat(matcher.excludes("Đậu hũ sốt cà", "dau hu sot ca")).isFalse();
    }

    @Test
    void dislikedFoodsMatchWholeWordsOnly() {
        FoodExclusionMatcher matcher = new FoodExclusionMatcher(List.of(), List.of("bò"));

        assertThat(matcher.excludes("Phở bò tái", "pho bo tai")).isTrue();
        assertThat(matcher.excludes("Bánh bò", "banh bo")).isTrue();
        assertThat(matcher.excludes("Bơ", "bo")).isFalse();
    }

    @Test
    void emptyPreferencesExcludeNothing() {
        FoodExclusionMatcher matcher = new FoodExclusionMatcher(List.of(), List.of());

        assertThat(matcher.isEmpty()).isTrue();
        assertThat(matcher.excludes("Tôm hấp", "tom hap")).isFalse();
    }
}
