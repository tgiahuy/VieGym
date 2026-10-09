package com.viegym.ai.infrastructure;

import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

@Component
public class HttpAiProviderClient implements AiProviderClient {
    private final RestClient client;
    private final String token;

    public HttpAiProviderClient(
            RestClient.Builder builder,
            @Value("${AI_SERVICE_BASE_URL:http://localhost:8000}") String baseUrl,
            @Value("${AI_SERVICE_TOKEN:dev-secret-token}") String token,
            @Value("${AI_CONNECT_TIMEOUT_MS:3000}") int connectTimeoutMs,
            @Value("${AI_READ_TIMEOUT_MS:20000}") int readTimeoutMs) {
        SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
        requestFactory.setConnectTimeout(connectTimeoutMs);
        requestFactory.setReadTimeout(readTimeoutMs);
        this.client = builder.baseUrl(baseUrl).requestFactory(requestFactory).build();
        this.token = token;
    }

    @Override
    public ProviderResponse generate(ProviderRequest request) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("schemaVersion", "1.0");
        body.put("correlationId", request.correlationId());
        body.put("requestType", request.requestType());
        body.put("promptVersion", request.promptVersion());
        body.put("renderedPrompt", request.renderedPrompt());
        body.put("context", request.context());
        body.put("candidates", request.candidates());
        body.put("messages", request.messages());
        body.put("allowedActions", request.allowedActions());
        try {
            ProviderResponse response =
                    client.post()
                            .uri("/internal/v1/ai/generate")
                            .header("X-Internal-Token", token)
                            .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                            .body(body)
                            .retrieve()
                            .body(ProviderResponse.class);
            if (response == null) {
                throw new ApiException(
                        ApiErrorCode.AI_OUTPUT_INVALID, "AI service returned an empty response");
            }
            return response;
        } catch (ApiException exception) {
            throw exception;
        } catch (RestClientException exception) {
            throw new ApiException(
                    ApiErrorCode.AI_PROVIDER_UNAVAILABLE, "AI service is temporarily unavailable");
        }
    }
}
