package com.viegym.otp;

import com.viegym.identity.OtpPurpose;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

/**
 * Fake OTP sender for local development and automated testing.
 *
 * <p>Instead of delivering a code over the network this implementation:
 *
 * <ul>
 *   <li>Logs only non-sensitive delivery metadata; the code and destination are never logged.
 *   <li>Keeps the last code per destination in memory so integration tests can assert on it.
 * </ul>
 *
 * <p>Activated when {@code otp.provider=fake} <em>or</em> when the property is absent ({@code
 * matchIfMissing = true}), making it the safe default for local and test environments. Set {@code
 * otp.provider=email} (or another production value) to disable it in production.
 */
@Component
@ConditionalOnProperty(name = "otp.provider", havingValue = "fake", matchIfMissing = true)
public class FakeOtpSender implements OtpSender {

    private static final Logger log = LoggerFactory.getLogger(FakeOtpSender.class);

    private final ConcurrentHashMap<String, String> lastCodeByDestination =
            new ConcurrentHashMap<>();

    @Override
    public void send(String destination, OtpPurpose purpose, String plainCode) {
        lastCodeByDestination.put(destination, plainCode);
        log.info("event=otp.fake-delivery purpose={} result=CAPTURED", purpose);
    }

    /**
     * Returns the last OTP code sent to {@code destination}, if any. Useful for assertions in
     * integration tests.
     */
    public Optional<String> lastCodeFor(String destination) {
        return Optional.ofNullable(lastCodeByDestination.get(destination));
    }

    /** Clears all captured codes. Call this in test teardown to avoid cross-test pollution. */
    public void clear() {
        lastCodeByDestination.clear();
    }
}
