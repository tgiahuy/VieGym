package com.viegym.ai.application;

import java.util.List;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AiPromptConfigurationService {
    private final JdbcTemplate jdbc;

    public AiPromptConfigurationService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Transactional(readOnly = true)
    public ResolvedPrompt resolve(String useCase, String fallbackVersion, String fallbackContent) {
        List<ResolvedPrompt> prompts =
                jdbc.query(
                        "select v.version_label, v.content from ai_prompt_templates t "
                                + "join ai_prompt_versions v on v.id=t.active_version_id where t.use_case=? "
                                + "order by v.published_at desc, v.id desc limit 1",
                        (rs, row) ->
                                new ResolvedPrompt(
                                        rs.getString("version_label"), rs.getString("content")),
                        useCase);
        ResolvedPrompt base =
                prompts.isEmpty()
                        ? new ResolvedPrompt(fallbackVersion, fallbackContent)
                        : prompts.getFirst();
        List<String> rules =
                jdbc.queryForList(
                        "select code || ': ' || description || ' Required action: ' || action "
                                + "from ai_safety_rules where is_active=true order by code",
                        String.class);
        if (rules.isEmpty()) return base;
        return new ResolvedPrompt(
                base.version(),
                base.content() + "\n\nACTIVE SAFETY RULES (mandatory):\n- " + String.join("\n- ", rules));
    }

    public record ResolvedPrompt(String version, String content) {}
}
