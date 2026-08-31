package com.viegym.auth.application;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

@Component
public class DefaultFacebookIdentityVerifier implements FacebookIdentityVerifier {

    private final RestClient restClient;
    private final String expectedAppId;

    public DefaultFacebookIdentityVerifier(@Value("${FACEBOOK_APP_ID:}") String expectedAppId) {
        this(RestClient.builder().baseUrl("https://graph.facebook.com").build(), expectedAppId);
    }

    public DefaultFacebookIdentityVerifier(RestClient restClient, String expectedAppId) {
        this.restClient = restClient;
        this.expectedAppId = expectedAppId == null ? "" : expectedAppId.trim();
    }

    @Override
    public FacebookIdentity verify(String accessToken) {
        if (accessToken == null || accessToken.isBlank()) {
            throw new ApiException(ApiErrorCode.INVALID_CREDENTIALS, "Invalid Facebook credential");
        }

        try {
            FacebookUserResponse response =
                    restClient
                            .get()
                            .uri(
                                    uriBuilder ->
                                            uriBuilder
                                                    .path("/me")
                                                    .queryParam("fields", "id,name,email")
                                                    .queryParam("access_token", accessToken)
                                                    .build())
                            .accept(MediaType.APPLICATION_JSON)
                            .retrieve()
                            .body(FacebookUserResponse.class);

            if (response == null || response.id() == null || response.id().isBlank()) {
                throw new ApiException(
                        ApiErrorCode.INVALID_CREDENTIALS, "Invalid Facebook credential");
            }

            if (response.email() == null || response.email().isBlank()) {
                throw new ApiException(
                        ApiErrorCode.INVALID_CREDENTIALS,
                        "Facebook account must have an associated email");
            }

            return new FacebookIdentity(response.id(), response.email(), response.name());
        } catch (RestClientException ex) {
            throw new ApiException(ApiErrorCode.INVALID_CREDENTIALS, "Invalid Facebook credential");
        }
    }

    public record FacebookUserResponse(
            @JsonProperty("id") String id,
            @JsonProperty("name") String name,
            @JsonProperty("email") String email) {}
}
