import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../l10n/generated/app_localizations.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _messageCtrl = TextEditingController();
  int? _openFaq;

  static const _supportEmail = 'support@umrahapp.com';
  static const _supportPhone = '+964 750 000 0000';

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  void _copy(String value) {
    final t = AppLocalizations.of(context);
    Clipboard.setData(ClipboardData(text: value));
    showAppSnack(context, t.helpCopiedToClipboard(value));
  }

  bool _sending = false;

  Future<void> _sendMessage() async {
    if (_sending) return;
    final t = AppLocalizations.of(context);
    final message = _messageCtrl.text.trim();
    if (message.isEmpty) {
      showAppSnack(context, t.helpMessageEmpty, isError: true);
      return;
    }
    setState(() => _sending = true);
    final ok = await context.read<AppProvider>().sendSupportMessage(message);
    if (!mounted) return;
    setState(() => _sending = false);
    if (!ok) {
      showAppSnack(context, t.helpMessageFailed, isError: true);
      return;
    }
    _messageCtrl.clear();
    FocusScope.of(context).unfocus();
    showAppSnack(context, t.helpMessageSent);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final faqs = [
      (t.helpFaq1Q, t.helpFaq1A),
      (t.helpFaq2Q, t.helpFaq2A),
      (t.helpFaq3Q, t.helpFaq3A),
      (t.helpFaq4Q, t.helpFaq4A),
      (t.helpFaq5Q, t.helpFaq5A),
    ];

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
                  Expanded(child: Text(t.helpTitle, style: AppTheme.serif(26))),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Text(t.helpFaqHeader,
                      style: AppTheme.sans(12, weight: FontWeight.w700, color: AppColors.muted)),
                  const SizedBox(height: 10),
                  ...List.generate(faqs.length, (i) {
                    final (q, a) = faqs[i];
                    final open = _openFaq == i;
                    return Padding(
                      padding: EdgeInsets.only(bottom: i < faqs.length - 1 ? 10 : 0),
                      child: GestureDetector(
                        onTap: () => setState(() => _openFaq = open ? null : i),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: open ? AppColors.primary.withOpacity(0.35) : AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(q, style: AppTheme.sans(13.5, weight: FontWeight.w700))),
                                  Icon(
                                    open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.primary, size: 22,
                                  ),
                                ],
                              ),
                              if (open) ...[
                                const SizedBox(height: 8),
                                Text(a, style: AppTheme.sans(12.5, color: const Color(0xFF62706A)).copyWith(height: 1.6)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 22),
                  Text(t.helpContactHeader,
                      style: AppTheme.sans(12, weight: FontWeight.w700, color: AppColors.muted)),
                  const SizedBox(height: 10),
                  _ContactTile(
                    icon: Icons.email_outlined,
                    label: t.helpContactEmail,
                    value: _supportEmail,
                    onTap: () => _copy(_supportEmail),
                  ),
                  const SizedBox(height: 10),
                  _ContactTile(
                    icon: Icons.phone_outlined,
                    label: t.helpContactPhone,
                    value: _supportPhone,
                    onTap: () => _copy(_supportPhone),
                  ),
                  const SizedBox(height: 22),
                  Text(t.helpMessageHeader,
                      style: AppTheme.sans(12, weight: FontWeight.w700, color: AppColors.muted)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: TextField(
                      controller: _messageCtrl,
                      maxLines: 4,
                      style: AppTheme.sans(14),
                      decoration: InputDecoration(
                        hintText: t.helpMessageHint,
                        hintStyle: AppTheme.sans(13.5, color: AppColors.mutedLight),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _sending ? null : _sendMessage,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(15)),
                      alignment: Alignment.center,
                      child: _sending
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Text(t.helpMessageSend,
                              style: AppTheme.sans(14, weight: FontWeight.w800, color: const Color(0xFFF6F2E9))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  const _ContactTile({required this.icon, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTheme.sans(13.5, weight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(value, style: AppTheme.sans(12, color: AppColors.muted)),
                ],
              ),
            ),
            const Icon(Icons.copy_rounded, color: Color(0xFFC1C8BF), size: 17),
          ],
        ),
      ),
    );
  }
}
