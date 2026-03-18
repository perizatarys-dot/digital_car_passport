import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_surfaces.dart';
import '../../theme/app_text_styles.dart';

enum PaymentMethod { kaspi, halyk, forte, card }

Future<void> showPaymentCheckoutSheet(
  BuildContext context, {
  required String title,
  required String amountLabel,
  required String description,
  String ctaLabel = 'Confirm payment',
  VoidCallback? onSuccess,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: context.appCardColor,
    builder: (_) => _PaymentCheckoutSheet(
      title: title,
      amountLabel: amountLabel,
      description: description,
      ctaLabel: ctaLabel,
      onSuccess: onSuccess,
    ),
  );
}

class _PaymentCheckoutSheet extends StatefulWidget {
  final String title;
  final String amountLabel;
  final String description;
  final String ctaLabel;
  final VoidCallback? onSuccess;

  const _PaymentCheckoutSheet({
    required this.title,
    required this.amountLabel,
    required this.description,
    required this.ctaLabel,
    this.onSuccess,
  });

  @override
  State<_PaymentCheckoutSheet> createState() => _PaymentCheckoutSheetState();
}

class _PaymentCheckoutSheetState extends State<_PaymentCheckoutSheet> {
  final _holderController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  PaymentMethod _method = PaymentMethod.kaspi;
  bool _submitting = false;

  @override
  void dispose() {
    _holderController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  bool get _isCardValid {
    final digits = _numberController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final expiryDigits = _expiryController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final cvvDigits = _cvvController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return _holderController.text.trim().isNotEmpty &&
        digits.length == 16 &&
        expiryDigits.length == 4 &&
        cvvDigits.length >= 3;
  }

  Future<void> _submit() async {
    if (!_isCardValid || _submitting) return;

    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;

    Navigator.of(context).pop();
    widget.onSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final methods = [
      (
        PaymentMethod.kaspi,
        'Kaspi Bank',
        'Fast checkout for Kaspi buyers in Kazakhstan',
        const Color(0xFFE84C63),
        Icons.account_balance_wallet_outlined,
      ),
      (
        PaymentMethod.halyk,
        'Halyk Bank',
        'Card payment with Halyk consumer and business cards',
        const Color(0xFF00A86B),
        Icons.account_balance_outlined,
      ),
      (
        PaymentMethod.forte,
        'ForteBank',
        'Business and retail payments for subscriptions',
        const Color(0xFFF5A623),
        Icons.apartment_rounded,
      ),
      (
        PaymentMethod.card,
        'Visa / Mastercard',
        'Manual card entry for any supported bank card',
        AppColors.blueAccent,
        Icons.credit_card_outlined,
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg + bottomInset,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: AppTextStyles.h4),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.description,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: context.appSecondaryTextColor,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.appCardAltColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.appBorderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.blueAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.blueAccent,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount due',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.appSecondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.amountLabel,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: context.appPrimaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Choose payment method', style: AppTextStyles.h4),
              const SizedBox(height: AppSpacing.sm),
              ...methods.map(
                (method) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: InkWell(
                    onTap: () => setState(() => _method = method.$1),
                    borderRadius: BorderRadius.circular(20),
                    child: Ink(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: _method == method.$1
                            ? method.$4.withValues(alpha: 0.10)
                            : context.appCardAltColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _method == method.$1
                              ? method.$4
                              : context.appBorderColor,
                          width: _method == method.$1 ? 1.4 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: method.$4.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(method.$5, color: method.$4),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  method.$2,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: context.appPrimaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  method.$3,
                                  style: TextStyle(
                                    fontSize: 11,
                                    height: 1.4,
                                    color: context.appSecondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _method == method.$1
                                  ? method.$4
                                  : Colors.transparent,
                              border: Border.all(
                                color: _method == method.$1
                                    ? method.$4
                                    : context.appBorderColor,
                                width: 2,
                              ),
                            ),
                            child: _method == method.$1
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 15,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Enter bank card details', style: AppTextStyles.h4),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _holderController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Cardholder name',
                  hintText: 'AMIR BEKOVICH',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _numberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: '${_bankLabel(_method)} card number',
                  hintText: '1234 5678 9012 3456',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _ExpiryDateFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Expiry date',
                        hintText: '12/28',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Mock checkout only. No real banking data is sent anywhere.',
                style: TextStyle(
                  fontSize: 11,
                  color: context.appHintTextColor,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: _isCardValid ? _submit : null,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.lock_open_rounded),
                label: Text(_submitting ? 'Processing...' : widget.ctaLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _bankLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.kaspi:
        return 'Kaspi';
      case PaymentMethod.halyk:
        return 'Halyk';
      case PaymentMethod.forte:
        return 'Forte';
      case PaymentMethod.card:
        return 'Bank';
    }
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
