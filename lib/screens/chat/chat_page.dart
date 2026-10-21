import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/chat_message.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/user_avatar.dart';

/// ============================================
/// AVISO GLOBAL PARA O BADGE DE MENSAGENS
/// ============================================
final ValueNotifier<int> unreadMessagesNotifier = ValueNotifier<int>(0);

/// ============================================
/// TELA: CHAT (Integrado ao Supabase)
/// ============================================
class ChatPage extends StatefulWidget {
  final bool isNutritionist;
  final String otherPartyName;

  const ChatPage({super.key, required this.isNutritionist, required this.otherPartyName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _authService = AuthService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  String _displayName = '';

  @override
  void initState() {
    super.initState();
    _displayName = widget.otherPartyName;
    _loadChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChat() async {
    final messages = await _authService.getChatMessagesFromCloud();
    
    String realName = widget.otherPartyName;
    try {
      if (widget.isNutritionist) {
        final patients = await _authService.getAllPatients();
        if (patients.isNotEmpty) {
          realName = patients.first['name'] ?? 'Paciente';
        }
      }
    } catch (e) {
      print('Erro ao buscar nome: $e');
    }

    if (!mounted) return;

    setState(() {
      _messages = messages;
      _displayName = realName;
      _isLoading = false;
    });

    _scrollToBottom();
    
    // Marca como lido no banco
    await _authService.markMessagesAsReadInCloud(byNutritionist: widget.isNutritionist);
    
    // Avisa o app para atualizar o badge
    final newCount = await _authService.countUnreadMessagesFromCloud(forNutritionist: widget.isNutritionist);
    unreadMessagesNotifier.value = newCount;
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    final error = await _authService.sendMessageToCloud(
      text,
      isFromPatient: !widget.isNutritionist,
    );

    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
      return;
    }

    _loadChat();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            UserAvatar(name: _displayName, size: UserAvatarSize.small),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_displayName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                  Text('Online', style: AppTextStyles.caption.copyWith(fontSize: 11, color: AppColors.success)),
                ],
              ),
            ),
          ],
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => AppRoutes.back(context)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            final isMe = widget.isNutritionist ? !msg.isFromPatient : msg.isFromPatient;
                            return _ChatBubble(message: msg, isMe: isMe);
                          },
                        ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Digite uma mensagem...',
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 24,
                    child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 20), onPressed: _sendMessage),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('Nenhuma mensagem ainda', style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Envie uma mensagem para começar.', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
              ),
              child: Text(message.text, style: AppTextStyles.body.copyWith(color: isMe ? Colors.white : AppColors.textPrimary, height: 1.3)),
            ),
            const SizedBox(height: 4),
            Text(message.formattedTime, style: AppTextStyles.caption.copyWith(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}