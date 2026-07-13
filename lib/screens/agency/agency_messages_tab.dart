import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/inquiry_model.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/colors.dart';
import '../../widgets/dashboard/dashboard_scaffold.dart';
import '../../widgets/dashboard/empty_state.dart';
import '../../widgets/dashboard/entity_list_card.dart';

class AgencyMessagesTab extends StatelessWidget {
  const AgencyMessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final threads = provider.agencyInquiries;
    return DashboardScaffold(
      title: t.agencyMessages,
      onRefresh: provider.loadAgencyInquiries,
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: kDashCardGap)),
        if (threads.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.forum_outlined,
              title: t.agencyMessagesEmpty,
              body: t.agencyMessagesEmptyBody,
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  kDashPagePad,
                  0,
                  kDashPagePad,
                  kDashCardGap,
                ),
                child: EntityListCard(
                  leading: const Icon(Icons.chat_bubble_outline_rounded),
                  title: t.agencyInquiryNumber(index + 1),
                  subtitle:
                      threads[index].lastMessage?.body ??
                      t.agencyInquiryNoMessages,
                  chevron: true,
                  onTap: () => _openThread(context, threads[index]),
                ),
              ),
              childCount: threads.length,
            ),
          ),
      ],
    );
  }

  void _openThread(BuildContext context, InquiryThread thread) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _InquiryThreadScreen(thread: thread)),
    );
  }
}

class _InquiryThreadScreen extends StatefulWidget {
  final InquiryThread thread;
  const _InquiryThreadScreen({required this.thread});

  @override
  State<_InquiryThreadScreen> createState() => _InquiryThreadScreenState();
}

class _InquiryThreadScreenState extends State<_InquiryThreadScreen> {
  final _reply = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final currentUserId = context.watch<AppProvider>().user?.id;
    return Scaffold(
      appBar: AppBar(title: Text(t.agencyMessages)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.thread.messages.length,
              itemBuilder: (context, index) {
                final message = widget.thread.messages[index];
                final mine = message.senderId == currentUserId;
                return Align(
                  alignment: mine
                      ? AlignmentDirectional.centerEnd
                      : AlignmentDirectional.centerStart,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: mine ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: mine ? null : Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      message.body,
                      style: AppTheme.sans(
                        13,
                        color: mine ? Colors.white : AppColors.ink,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _reply,
                      decoration: InputDecoration(hintText: t.agencyReplyHint),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final body = _reply.text.trim();
    if (body.isEmpty) return;
    setState(() => _sending = true);
    final error = await context.read<AppProvider>().replyToInquiry(
      widget.thread.id,
      body,
    );
    if (!mounted) return;
    setState(() => _sending = false);
    if (error == null) {
      _reply.clear();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}
