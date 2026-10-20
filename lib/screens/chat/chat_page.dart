import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/chat_message.dart';
import '../../../services/local_storage_service.dart';
import '../../../widgets/user_avatar.dart';

/// ============================================
/// TELA: CHAT (Paciente <-> Nutricionista)
/// ============================================
class ChatPage extends StatefulWidget {
  final bool isNutritionist;
  final String otherPartyName;

  const ChatPage({
    super.key,
    required this.isNutritionist,
    required this.otherPartyName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _storage = LocalStorageService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================
  // CARREGAR MENSAGENS
  // ============================================
  Future<void> _loadMessages() async {
    final messages = await _storage.loadChatMessages();
    if (!mounted) return;

    setState(() {
      _messages = messages;
      _isLoading = false;
    });

    _scrollToBottom();
  }

  // ============================================
  // ENVIAR MENSAGEM
  // ============================================
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      timestamp: DateTime.now(),
      isFromPatient: !widget.isNutritionist, // Se é nutricionista, não é do paciente
      isRead: true,
    );

    setState(() {
      _messages.add(message);
    });

    _scrollToBottom();
    await _storage.saveChatMessage(message);
  }

  // ============================================
  // SCROLL
  // ============================================
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            UserAvatar(
              name: widget.otherPartyName,
              size: UserAvatarSize.small,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherPartyName,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Online',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRoutes.back(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ============================================
            // LISTA DE MENSAGENS
            // ============================================
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
                            // A mensagem é "minha" se:
                            // - Sou nutricionista E a msg não é do paciente
                            // - Sou paciente E a msg é do paciente
                            final isMe =
                                widget.isNutritionist ? !msg.isFromPatient : msg.isFromPatient;

                            return _ChatBubble(
                              message: msg,
                              isMe: isMe,
                            );
                          },
                        ),
            ),

            // ============================================
            // CAMPO DE DIGITAR
            // ============================================
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border),
                ),
              ),
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _sendMessage,
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

  // ============================================
  // ESTADO VAZIO
  // ============================================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma mensagem ainda',
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Envie uma mensagem para começar.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

// ============================================
// WIDGET: BALÃO DE MENSAGEM
// ============================================
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _ChatBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: AppTextStyles.body.copyWith(
                  color: isMe ? Colors.white : AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.formattedTime,
              style: AppTextStyles.caption.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}