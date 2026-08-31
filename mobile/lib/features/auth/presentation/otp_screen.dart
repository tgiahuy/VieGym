import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/auth_header.dart';
import '../application/auth_controller.dart';
import '../domain/auth_state.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({
    super.key,
    this.email,
    this.purpose = OtpPurpose.register,
  });

  final String? email;
  final OtpPurpose purpose;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _cooldownSeconds = 60;

  @override
  void initState() {
    super.initState();
    _startCooldownTimer();
  }

  void _startCooldownTimer() {
    _timer?.cancel();
    setState(() {
      _cooldownSeconds = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_cooldownSeconds > 0) {
        setState(() {
          _cooldownSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  String get _effectiveEmail {
    final authState = ref.read(authProvider);
    return widget.email ?? authState.pendingEmail ?? 'user@viegym.vn';
  }

  OtpPurpose get _effectivePurpose {
    final authState = ref.read(authProvider);
    return widget.email != null ? widget.purpose : authState.pendingPurpose;
  }

  Future<void> _verifyOtp() async {
    final code = _otpCode;
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ 6 chữ số OTP.')),
      );
      return;
    }

    final success = await ref
        .read(authProvider.notifier)
        .verifyOtp(code, purpose: _effectivePurpose);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xác thực thành công!')),
        );
        if (_effectivePurpose == OtpPurpose.register) {
          context.go('/onboarding/health');
        } else if (_effectivePurpose == OtpPurpose.passwordReset) {
          context.push('/reset-password', extra: {'email': _effectiveEmail});
        } else {
          context.go('/login');
        }
      } else {
        final error = ref.read(authProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Xác thực thất bại')),
        );
      }
    }
  }

  Future<void> _handleResend() async {
    if (_cooldownSeconds > 0) return;

    final success = await ref
        .read(authProvider.notifier)
        .resendOtp(email: _effectiveEmail, purpose: _effectivePurpose);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã gửi lại mã OTP tới ${AuthState.maskEmail(_effectiveEmail)}',
          ),
        ),
      );
      _startCooldownTimer();
    }
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOtp();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final colors = Theme.of(context).colorScheme;
    final purpose = _effectivePurpose;
    final maskedEmail = AuthState.maskEmail(_effectiveEmail);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                title: purpose.displayName,
                subtitle: '${purpose.subtitle}\n$maskedEmail',
                icon: Icons.shield_outlined,
                onBack: () => context.pop(),
              ),
              const SizedBox(height: 36),

              // OTP 6-digit inputs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 58,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: colors.primary,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: colors.surfaceContainer,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: colors.outlineVariant.withValues(alpha: 0.6),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: colors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) => _onDigitChanged(index, value),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),

              Text(
                '(Mẹo: Nhập 123456 hoặc 6 số bất kỳ để tiếp tục)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 30),

              // Submit Button
              FilledButton(
                onPressed: authState.isLoading ? null : _verifyOtp,
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Xác nhận mã OTP',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
              const SizedBox(height: 18),

              // Resend Action with Cooldown Timer
              Center(
                child: TextButton.icon(
                  onPressed: _cooldownSeconds == 0 ? _handleResend : null,
                  icon: Icon(
                    Icons.replay_rounded,
                    size: 16,
                    color: _cooldownSeconds == 0
                        ? colors.primary
                        : colors.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  label: Text(
                    _cooldownSeconds > 0
                        ? 'Gửi lại mã sau (${_cooldownSeconds}s)'
                        : 'Chưa nhận được mã? Gửi lại',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _cooldownSeconds == 0
                          ? colors.primary
                          : colors.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
