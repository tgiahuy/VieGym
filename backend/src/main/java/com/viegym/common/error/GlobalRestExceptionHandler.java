package com.viegym.common.error;

import com.viegym.common.api.ApiErrorResponse;
import com.viegym.common.api.FieldViolation;
import com.viegym.observability.CorrelationId;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.ConstraintViolationException;
import java.util.List;
import java.util.Locale;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.servlet.resource.NoResourceFoundException;

@RestControllerAdvice
public class GlobalRestExceptionHandler {

    private static final Logger LOGGER = LoggerFactory.getLogger(GlobalRestExceptionHandler.class);
    private static final String VALIDATION_MESSAGE = "Request data is invalid";

    @ExceptionHandler(MethodArgumentNotValidException.class)
    ResponseEntity<ApiErrorResponse> handleBodyValidation(
            MethodArgumentNotValidException exception) {
        List<FieldViolation> violations =
                exception.getBindingResult().getFieldErrors().stream()
                        .map(this::toViolation)
                        .toList();
        return error(ApiErrorCode.VALIDATION_ERROR, VALIDATION_MESSAGE, violations);
    }

    @ExceptionHandler(ConstraintViolationException.class)
    ResponseEntity<ApiErrorResponse> handleConstraintViolation(
            ConstraintViolationException exception) {
        List<FieldViolation> violations =
                exception.getConstraintViolations().stream().map(this::toViolation).toList();
        return error(ApiErrorCode.VALIDATION_ERROR, VALIDATION_MESSAGE, violations);
    }

    @ExceptionHandler(MissingServletRequestParameterException.class)
    ResponseEntity<ApiErrorResponse> handleMissingParameter(
            MissingServletRequestParameterException exception) {
        FieldViolation violation =
                new FieldViolation(
                        exception.getParameterName(), "REQUIRED", "Required parameter is missing");
        return error(ApiErrorCode.VALIDATION_ERROR, VALIDATION_MESSAGE, List.of(violation));
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    ResponseEntity<ApiErrorResponse> handleUnreadableBody(
            HttpMessageNotReadableException exception) {
        FieldViolation violation =
                new FieldViolation("request", "MALFORMED", "Request body is malformed");
        return error(ApiErrorCode.VALIDATION_ERROR, VALIDATION_MESSAGE, List.of(violation));
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    ResponseEntity<ApiErrorResponse> handleTypeMismatch(
            MethodArgumentTypeMismatchException exception) {
        FieldViolation violation =
                new FieldViolation(
                        exception.getName(), "TYPE_MISMATCH", "Parameter type is invalid");
        return error(ApiErrorCode.VALIDATION_ERROR, VALIDATION_MESSAGE, List.of(violation));
    }

    @ExceptionHandler(NoResourceFoundException.class)
    ResponseEntity<ApiErrorResponse> handleNotFound(NoResourceFoundException exception) {
        return error(ApiErrorCode.RESOURCE_NOT_FOUND, "Resource not found", List.of());
    }

    @ExceptionHandler(ApiValidationException.class)
    ResponseEntity<ApiErrorResponse> handleApiValidationException(
            ApiValidationException exception) {
        return error(ApiErrorCode.VALIDATION_ERROR, VALIDATION_MESSAGE, exception.violations());
    }

    @ExceptionHandler(ApiException.class)
    ResponseEntity<ApiErrorResponse> handleApiException(ApiException exception) {
        return error(exception.code(), exception.getMessage(), List.of());
    }

    @ExceptionHandler(Exception.class)
    ResponseEntity<ApiErrorResponse> handleUnexpected(Exception exception) {
        LOGGER.error(
                "event=request.failed result=FAILED errorCode={} errorType={}",
                ApiErrorCode.INTERNAL_ERROR,
                exception.getClass().getSimpleName());
        return error(ApiErrorCode.INTERNAL_ERROR, "An unexpected error occurred", List.of());
    }

    private ResponseEntity<ApiErrorResponse> error(
            ApiErrorCode code, String message, List<FieldViolation> violations) {
        ApiErrorResponse body =
                ApiErrorResponse.of(
                        code.name(), message, violations, CorrelationId.currentOrCreate());
        return ResponseEntity.status(code.httpStatus()).body(body);
    }

    private FieldViolation toViolation(FieldError error) {
        return new FieldViolation(
                error.getField(),
                normalizeValidationCode(error.getCode()),
                error.getDefaultMessage());
    }

    private FieldViolation toViolation(ConstraintViolation<?> violation) {
        String path = violation.getPropertyPath().toString();
        String field = path.substring(path.lastIndexOf('.') + 1);
        return new FieldViolation(
                field,
                normalizeValidationCode(
                        violation
                                .getConstraintDescriptor()
                                .getAnnotation()
                                .annotationType()
                                .getSimpleName()),
                violation.getMessage());
    }

    private String normalizeValidationCode(String value) {
        if (value == null) {
            return "INVALID";
        }
        return value.replaceAll("([a-z])([A-Z])", "$1_$2").toUpperCase(Locale.ROOT);
    }
}
