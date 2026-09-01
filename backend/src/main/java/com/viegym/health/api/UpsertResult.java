package com.viegym.health.api;

public record UpsertResult<T>(T data, boolean created) {}
