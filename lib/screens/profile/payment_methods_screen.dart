import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/payment_card_model.dart';
import '../../l10n/generated/app_localizations.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final cards = provider.cards;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.ink),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Text(t.paymentTitle, style: AppTheme.serif(26))),
                ],
              ),
            ),
            Expanded(
              child: cards.isEmpty
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.credit_card_off_rounded, size: 48, color: AppColors.mutedLight),
                        const SizedBox(height: 14),
                        Text(t.paymentEmptyTitle, style: AppTheme.serif(20)),
                        const SizedBox(height: 6),
                        Text(t.paymentEmptyBody, style: AppTheme.sans(13, color: AppColors.muted)),
                      ]),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                      itemCount: cards.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _CardTile(
                        card: cards[i],
                        isDefault: cards[i].id == provider.defaultCardId,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: GestureDetector(
                onTap: () => _openAddCard(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 22, offset: const Offset(0, 10))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 7),
                      Text(t.paymentAddCard, style: AppTheme.sans(14, weight: FontWeight.w800, color: const Color(0xFFF6F2E9))),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddCard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AppProvider>(),
        child: const _AddCardSheet(),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  final PaymentCard card;
  final bool isDefault;
  const _CardTile({required this.card, required this.isDefault});

  IconData get _brandIcon {
    switch (card.brand) {
      case 'Visa':
      case 'Mastercard':
      case 'Amex':
        return Icons.credit_card_rounded;
      default:
        return Icons.credit_card_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.read<AppProvider>();
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDefault ? AppColors.primary : AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.09), borderRadius: BorderRadius.circular(13)),
            child: Icon(_brandIcon, color: AppColors.primary, size: 23),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${card.brand} •••• ${card.last4}', style: AppTheme.sans(14, weight: FontWeight.w700)),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(6)),
                        child: Text(t.paymentDefaultBadge,
                            style: AppTheme.sans(9, weight: FontWeight.w800, color: const Color(0xFF1C2317))),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text('${card.holder} · ${t.paymentExpiresLabel(card.expiry)}',
                    style: AppTheme.sans(12, color: AppColors.muted)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.muted, size: 20),
            color: AppColors.background,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (v) {
              if (v == 'default') provider.setDefaultCard(card.id);
              if (v == 'remove') _confirmRemove(context);
            },
            itemBuilder: (_) => [
              if (!isDefault)
                PopupMenuItem(value: 'default', child: Text(t.paymentSetDefault, style: AppTheme.sans(13))),
              PopupMenuItem(value: 'remove', child: Text(t.paymentRemoveCard, style: AppTheme.sans(13, color: AppColors.errorRed))),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmRemove(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.read<AppProvider>();
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t.paymentRemoveTitle, style: AppTheme.serif(20)),
        content: Text(t.paymentRemoveBody(card.brand, card.last4), style: AppTheme.sans(13, color: AppColors.inkLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(t.paymentKeepCard, style: AppTheme.sans(13, color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () {
              provider.removeCard(card.id);
              Navigator.pop(dialogCtx);
              messenger.showSnackBar(SnackBar(
                content: Text(t.paymentCardRemoved, style: AppTheme.sans(13, weight: FontWeight.w600)),
                backgroundColor: AppColors.ink,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ));
            },
            child: Text(t.paymentConfirmRemove, style: AppTheme.sans(13, weight: FontWeight.w700, color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }
}

class _AddCardSheet extends StatefulWidget {
  const _AddCardSheet();

  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _holderCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _holderCtrl.dispose();
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  String? _validate(AppLocalizations t) {
    if (_holderCtrl.text.trim().isEmpty) return t.paymentErrHolder;
    final digits = _numberCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 || digits.length > 19) return t.paymentErrNumber;
    final exp = RegExp(r'^(0[1-9]|1[0-2])\/(\d{2})$').firstMatch(_expiryCtrl.text.trim());
    if (exp == null) return t.paymentErrExpiry;
    final month = int.parse(exp.group(1)!);
    final year = 2000 + int.parse(exp.group(2)!);
    final now = DateTime.now();
    if (DateTime(year, month + 1).isBefore(DateTime(now.year, now.month + 1))) return t.paymentErrExpiry;
    final cvv = _cvvCtrl.text.trim();
    if (cvv.length < 3 || cvv.length > 4 || int.tryParse(cvv) == null) return t.paymentErrCvv;
    return null;
  }

  void _save() {
    final t = AppLocalizations.of(context);
    final err = _validate(t);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    context.read<AppProvider>().addCard(
          holder: _holderCtrl.text.trim(),
          number: _numberCtrl.text.replaceAll(RegExp(r'\D'), ''),
          expiry: _expiryCtrl.text.trim(),
        );
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(
      content: Text(t.paymentCardAdded, style: AppTheme.sans(13, weight: FontWeight.w600)),
      backgroundColor: AppColors.ink,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42, height: 5,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(t.paymentAddCardTitle, style: AppTheme.serif(24)),
            const SizedBox(height: 18),
            Text(t.paymentCardHolder, style: AppTheme.sans(13, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            _Field(controller: _holderCtrl, hint: t.paymentCardHolderHint, icon: Icons.person_outline_rounded),
            const SizedBox(height: 14),
            Text(t.paymentCardNumber, style: AppTheme.sans(13, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            _Field(
              controller: _numberCtrl,
              hint: t.paymentCardNumberHint,
              icon: Icons.credit_card_rounded,
              keyboardType: TextInputType.number,
              formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(19)],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.paymentExpiry, style: AppTheme.sans(13, weight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _Field(
                        controller: _expiryCtrl,
                        hint: t.paymentExpiryHint,
                        icon: Icons.calendar_today_rounded,
                        keyboardType: TextInputType.number,
                        formatters: [_ExpiryFormatter()],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.paymentCvv, style: AppTheme.sans(13, weight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _Field(
                        controller: _cvvCtrl,
                        hint: t.paymentCvvHint,
                        icon: Icons.lock_outline_rounded,
                        keyboardType: TextInputType.number,
                        obscure: true,
                        formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0EE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.errorRed, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_error!, style: AppTheme.sans(12.5, color: AppColors.errorRed))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _save,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(15)),
                alignment: Alignment.center,
                child: Text(t.paymentSaveCard, style: AppTheme.sans(14, weight: FontWeight.w800, color: const Color(0xFFF6F2E9))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length && i < 4; i++) {
      buf.write(digits[i]);
      if (i == 1 && digits.length > 2) buf.write('/');
    }
    final text = buf.toString();
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;

  const _Field({
    required this.controller, required this.hint, required this.icon,
    this.obscure = false, this.keyboardType, this.formatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        inputFormatters: formatters,
        style: AppTheme.sans(14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTheme.sans(14, color: AppColors.mutedLight),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
