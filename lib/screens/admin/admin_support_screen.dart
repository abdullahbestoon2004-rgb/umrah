import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/support_message_model.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/dashboard/dashboard_scaffold.dart';
import '../../widgets/dashboard/empty_state.dart';
import '../../l10n/generated/app_localizations.dart';

/// Full-screen support inbox, reached from the admin More menu. Tapping the
/// sender copies their address; the check resolves (deletes) the message.
class AdminSupportScreen extends StatelessWidget {
  const AdminSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final messages = provider.supportMessages;

    return DashboardScaffold(
      title: t.adminSupportInbox,
      leading: DashIconButton(
        icon: Icons.arrow_back_ios_new_rounded,
        onTap: () => Navigator.pop(context),
      ),
      onRefresh: () => context.read<AppProvider>().loadSupportMessages(),
      slivers: [
        if (messages.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.mark_email_read_outlined,
              title: t.adminSupportEmpty,
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  kDashPagePad,
                  0,
                  kDashPagePad,
                  kDashCardGap,
                ),
                child: SupportMessageCard(message: messages[i]),
              ),
              childCount: messages.length,
            ),
          ),
      ],
    );
  }
}

class SupportMessageCard extends StatelessWidget {
  final SupportMessage message;
  const SupportMessageCard({super.key, required this.message});

  String _timeAgo(AppLocalizations t) {
    final diff = DateTime.now().difference(message.createdAt);
    if (diff.inMinutes < 1) return t.notifJustNow;
    if (diff.inHours < 1) return t.notifMinutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return t.notifHoursAgo(diff.inHours);
    return t.notifDaysAgo(diff.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final email = message.email ?? '';
    final sender = email.isNotEmpty ? email : t.adminSupportAnonymous;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                // The sender's address is the only way to reply, so make it
                // grabbable: tap copies it to the clipboard.
                child: GestureDetector(
                  onTap: email.isEmpty
                      ? null
                      : () {
                          Clipboard.setData(ClipboardData(text: email));
                          showAppSnack(context, t.emailCopied);
                        },
                  child: Text(
                    sender,
                    style: AppTheme.sans(
                      12.5,
                      weight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _timeAgo(t),
                style: AppTheme.sans(11, color: AppColors.mutedLight),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final ok = await context
                      .read<AppProvider>()
                      .deleteSupportMessage(message.id);
                  messenger.showSnackBar(
                    appSnack(
                      ok ? t.adminSupportResolved : t.adminActionFailed,
                      isError: !ok,
                    ),
                  );
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message.message,
            style: AppTheme.sans(13.5, color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}
