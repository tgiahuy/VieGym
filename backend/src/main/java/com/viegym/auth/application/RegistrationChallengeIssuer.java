package com.viegym.auth.application;

import com.viegym.auth.api.RegisterChallengeResponse;
import com.viegym.identity.User;

public interface RegistrationChallengeIssuer {

    RegisterChallengeResponse issue(User user);
}
