package com.viegym.ai.application;

import java.text.Normalizer;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;

/**
 * Hard backend filter for allergies and disliked foods. Preferences are free Vietnamese text ("Hải
 * sản", "dau phong") while foods carry no allergen tags, so matching is done on whole words of the
 * food name. Accented keywords match the accented name (so "cá" never matches "cà chua");
 * unaccented keywords match the unaccented search name. Allergy groups expand to their common
 * ingredients.
 */
final class FoodExclusionMatcher {
    private static final Pattern MARKS = Pattern.compile("\\p{M}+");
    private static final Pattern NON_WORD = Pattern.compile("[^\\p{L}\\p{Nd}]+");

    /** Keyed by the unaccented group name; values are accented ingredient words. */
    private static final Map<String, List<String>> ALLERGY_GROUPS =
            Map.ofEntries(
                    Map.entry(
                            "hai san",
                            List.of(
                                    "hải sản",
                                    "tôm",
                                    "cua",
                                    "ghẹ",
                                    "mực",
                                    "bạch tuộc",
                                    "nghêu",
                                    "sò",
                                    "ốc",
                                    "hàu",
                                    "hến",
                                    "cá")),
                    Map.entry("seafood", List.of("hải sản", "tôm", "cua", "ghẹ", "mực", "cá")),
                    Map.entry("tom", List.of("tôm")),
                    Map.entry("cua", List.of("cua", "ghẹ")),
                    Map.entry("ca", List.of("cá")),
                    Map.entry("dau phong", List.of("đậu phộng", "lạc")),
                    Map.entry("lac", List.of("đậu phộng", "lạc")),
                    Map.entry("peanut", List.of("đậu phộng", "lạc")),
                    Map.entry("sua", List.of("sữa", "phô mai", "sữa chua", "whey", "kem")),
                    Map.entry("sua bo", List.of("sữa", "phô mai", "sữa chua", "whey", "kem")),
                    Map.entry("lactose", List.of("sữa", "phô mai", "sữa chua", "whey", "kem")),
                    Map.entry("trung", List.of("trứng")),
                    Map.entry("egg", List.of("trứng")),
                    Map.entry("dau nanh", List.of("đậu nành", "đậu hũ", "đậu phụ", "tàu hũ")),
                    Map.entry("gluten", List.of("bánh mì", "mì", "bánh bao")),
                    Map.entry("lua mi", List.of("bánh mì", "mì", "bánh bao")));

    private final Set<String> accented = new LinkedHashSet<>();
    private final Set<String> unaccented = new LinkedHashSet<>();

    FoodExclusionMatcher(List<String> allergies, List<String> dislikedFoods) {
        for (String allergy : allergies) {
            if (allergy == null) continue;
            String keyword = words(allergy);
            List<String> group = ALLERGY_GROUPS.get(unaccent(keyword));
            if (group == null) {
                add(allergy);
                continue;
            }
            // Known group: use its accented words; an unaccented "ca" would also hit "cà chua".
            group.forEach(this::add);
            if (!unaccent(keyword).equals(keyword)) add(allergy);
        }
        dislikedFoods.forEach(this::add);
    }

    boolean isEmpty() {
        return accented.isEmpty() && unaccented.isEmpty();
    }

    boolean excludes(String foodName, String searchName) {
        String name = " " + words(foodName) + " ";
        String search = " " + unaccent(words(searchName == null ? foodName : searchName)) + " ";
        for (String keyword : accented) {
            if (name.contains(" " + keyword + " ")) return true;
        }
        for (String keyword : unaccented) {
            if (search.contains(" " + keyword + " ")) return true;
        }
        return false;
    }

    private void add(String raw) {
        if (raw == null) return;
        String keyword = words(raw);
        if (keyword.isEmpty()) return;
        String plain = unaccent(keyword);
        if (plain.equals(keyword)) {
            unaccented.add(plain);
        } else {
            accented.add(keyword);
        }
    }

    static String words(String value) {
        String composed = Normalizer.normalize(value, Normalizer.Form.NFC);
        return NON_WORD.matcher(composed.toLowerCase(Locale.ROOT)).replaceAll(" ").trim();
    }

    static String unaccent(String value) {
        String decomposed = Normalizer.normalize(value.replace('đ', 'd'), Normalizer.Form.NFD);
        return MARKS.matcher(decomposed).replaceAll("");
    }
}
