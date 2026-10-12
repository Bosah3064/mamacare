// ============================================
// MamaCare KE - Mama AI Chat Screen
// ============================================
// Intelligent conversational companion with
// integrated clinical safety guardrails, quick
// Kenyan maternal prompts, and emergency triggers.
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/mama_card.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final VoidCallback? onOpenEmergency;
  final VoidCallback? onOpenFacilities;

  const ChatScreen({
    super.key,
    this.onOpenEmergency,
    this.onOpenFacilities,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend([String? presetText]) async {
    final text = presetText ?? _textController.text.trim();
    if (text.isEmpty) return;

    if (presetText == null) {
      _textController.clear();
    }

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(chatProvider.notifier).sendMessage(text);
      _scrollToBottom();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _call1199() async {
    final uri = Uri.parse('tel:1199');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);
    final isSwahili = currentLang == Language.sw;
    final chatState = ref.watch(chatProvider);
    final messages = chatState.messages;

    return Scaffold(
      backgroundColor: MamaCareColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/images/logo_emblem.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: MamaCareColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: MamaCareColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: MamaCareColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mama AI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: MamaCareColors.textPrimary,
                  ),
                ),
                Text(
                  isSwahili ? 'Msaidizi wa Afya ya Uzazi' : 'Maternal Wellbeing Assistant',
                  style: const TextStyle(
                    fontSize: 11,
                    color: MamaCareColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Emergency Red Call Button
          IconButton(
            tooltip: isSwahili ? 'Piga 1199' : 'Call 1199',
            icon: const Icon(Icons.emergency, color: MamaCareColors.error),
            onPressed: widget.onOpenEmergency,
          ),
        ],
      ),
      body: Column(
        children: [
          // Clinical Safety Disclaimer Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: MamaCareColors.primarySurface,
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, size: 14, color: MamaCareColors.primaryDark),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isSwahili
                        ? 'Mwongozo wa kliniki ya Kenya (MoH). Si utambuzi wa daktari.'
                        : 'Aligned with Kenya MoH guidelines. Educational companion.',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: MamaCareColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Message Stream
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(MamaCareSpacing.md),
              itemCount: messages.length + (chatState.isSending ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && chatState.isSending) {
                  return _buildTypingIndicator(isSwahili);
                }

                final msg = messages[index];
                final isUser = msg.role == 'user';
                final isEmergency = msg.riskLevel == AIRiskLevel.emergency;
                final isUrgent = msg.riskLevel == AIRiskLevel.high;

                return _buildMessageBubble(
                  message: msg,
                  isUser: isUser,
                  isEmergency: isEmergency,
                  isUrgent: isUrgent,
                  isSwahili: isSwahili,
                );
              },
            ),
          ),

          // Quick Prompt Chips
          Container(
            height: 42,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildPromptChip(
                  isSwahili ? '🥗 Vyakula vya chuma' : '🥗 Iron-rich foods',
                  isSwahili ? 'Niambie vyakula vya kienyeji vyenye madini ya chuma' : 'Tell me traditional Kenyan foods rich in iron',
                ),
                _buildPromptChip(
                  isSwahili ? '👶 Mateke ya mtoto' : '👶 Baby kick count',
                  isSwahili ? 'Jinsi ya kuhesabu mateke ya mtoto tumboni' : 'How do I count baby kicks at 24 weeks?',
                ),
                _buildPromptChip(
                  isSwahili ? '🏥 Kliniki ya Linda Mama' : '🏥 Linda Mama care',
                  isSwahili ? 'Je, huduma ya Linda Mama inalipia nini kliniki?' : 'What maternal services are covered under Linda Mama?',
                ),
                _buildPromptChip(
                  isSwahili ? '🚨 Dalili za hatari' : '🚨 Danger signs',
                  isSwahili ? 'Ni dalili gani za hatari zinazonifanya niende hospitali mara moja?' : 'What are the urgent danger signs during pregnancy?',
                ),
              ],
            ),
          ),

          // Message Input Field
          Container(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: MamaCareColors.background,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: MamaCareColors.divider),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              textCapitalization: TextCapitalization.sentences,
                              minLines: 1,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: isSwahili ? 'Uliza Mama AI chochote...' : 'Ask Mama AI anything...',
                                hintStyle: const TextStyle(fontSize: 14, color: MamaCareColors.textTertiary),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              onSubmitted: (_) => _handleSend(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: MamaCareColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: () => _handleSend(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptChip(String label, String prompt) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: MamaCareColors.textPrimary),
        ),
        backgroundColor: Colors.white,
        side: const BorderSide(color: MamaCareColors.divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _handleSend(prompt),
      ),
    );
  }

  Widget _buildMessageBubble({
    required AIMessage message,
    required bool isUser,
    required bool isEmergency,
    required bool isUrgent,
    required bool isSwahili,
  }) {
    if (isEmergency) {
      // High-priority clinical danger sign alert bubble
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: MamaCard(
          color: MamaCareColors.errorSurface,
          border: Border.all(color: MamaCareColors.error, width: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.crisis_alert_rounded, color: MamaCareColors.error, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isSwahili ? 'TAARIFA YA DHARURA YA KLINIKI' : 'CRITICAL CLINICAL ALERT',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: MamaCareColors.error,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                message.content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: MamaCareColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: _call1199,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MamaCareColors.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.call, size: 18),
                    label: Text(
                      isSwahili ? 'Piga 1199 (Msalaba Mwekundu)' : 'Call 1199 (Red Cross)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (widget.onOpenFacilities != null)
                    OutlinedButton.icon(
                      onPressed: widget.onOpenFacilities,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: MamaCareColors.error,
                        side: const BorderSide(color: MamaCareColors.error),
                      ),
                      icon: const Icon(Icons.local_hospital, size: 18),
                      label: Text(
                        isSwahili ? 'Tafuta Hospitali' : 'Find Hospital',
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 8, top: 2),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: MamaCareColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: MamaCareColors.primary, size: 16),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? MamaCareColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser ? null : Border.all(color: MamaCareColors.divider),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isUrgent)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: MamaCareColors.warningSurface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: MamaCareColors.warning),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline, size: 12, color: MamaCareColors.warning),
                          const SizedBox(width: 4),
                          Text(
                            isSwahili ? 'Ushauri wa Haraka' : 'Clinical Attention Needed',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: MamaCareColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: isUser ? Colors.white : MamaCareColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      DateFormat('HH:mm').format(message.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: isUser ? Colors.white.withValues(alpha: 0.7) : MamaCareColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser)
            Container(
              margin: const EdgeInsets.only(left: 8, top: 2),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: MamaCareColors.secondarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: MamaCareColors.secondaryDark, size: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isSwahili) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: MamaCareColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: MamaCareColors.primary, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: MamaCareColors.divider),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: MamaCareColors.primary),
                ),
                const SizedBox(width: 8),
                Text(
                  isSwahili ? 'Mama AI anajibu...' : 'Mama AI is thinking...',
                  style: const TextStyle(fontSize: 12, color: MamaCareColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
