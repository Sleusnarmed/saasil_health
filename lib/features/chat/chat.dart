import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _suggestedPrompts = [
    "¿Cómo voy?",
    "¿Mis niveles son normales?",
    "¿Qué puedo cenar hoy?",
  ];

  final Map<String, String> _mockResponses = {
    "¿Cómo voy?": "Vas muy bien. Tus niveles han estado estables en los últimos 3 días, con un promedio de 105 mg/dL. ¡Sigue así! 🌟",
    "¿Mis niveles son normales?": "Sí, la mayoría de tus registros recientes están en el rango objetivo (70-180 mg/dL). Solo ten cuidado con los picos después del almuerzo. 📊",
    "¿Qué puedo cenar hoy?": "Considerando tu última lectura de 115 mg/dL, una buena opción sería pechuga de pollo a la plancha con una porción de vegetales al vapor y aguacate. 🥗",
  };

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hola, soy tu asistente Sáasil.\nPuedo ayudarte a entender tus niveles de glucosa e insulina. ¿En qué te puedo apoyar hoy?",
      isUser: false,
    ),
  ];

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _textController.clear();

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });
    _scrollToBottom();

    String replyText = _mockResponses[text] ?? "Por ahora no se ha conectado con el asistente...";

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: replyText,
              isUser: false,
            ),
          );
        });
        _scrollToBottom();
      }
    });
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

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.colorBgSecondary,
      appBar: AppBar(
        backgroundColor: AppTheme.colorBgSecondary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Chat IA',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 20.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 58), 
            decoration: BoxDecoration(
              color: AppTheme.colorBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: SafeArea(
              top: false, 
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _suggestedPrompts.map((prompt) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: OutlinedButton(
                            onPressed: () => _handleSubmitted(prompt),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.colorPrimary,
                              side: const BorderSide(color: AppTheme.colorPrimary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: Text(prompt),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.colorBgSecondary,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextField(
                            controller: _textController,
                            textInputAction: TextInputAction.send,
                            onSubmitted: _handleSubmitted,
                            decoration: const InputDecoration(
                              hintText: "Escribe tu mensaje...",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppTheme.colorPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () => _handleSubmitted(_textController.text),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF00A99D), 
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? AppTheme.colorPrimary : Colors.white,
                border: message.isUser ? null : Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: message.isUser ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                message.text, 
                style: TextStyle(
                  color: message.isUser ? Colors.white : AppTheme.colorTextPrimary,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),

          if (message.isUser) const SizedBox(width: 40), 
        ],
      ),
    );
  }
}