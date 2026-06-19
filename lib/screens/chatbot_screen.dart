import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});
  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _service = ChatService();
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hi! I'm Vastra, your AI stylist. Ask me about colors, outfits, or what to wear for any occasion. 👗",
      isUser: false,
    ),
  ];
  bool _sending = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _sending = true;
      _controller.clear();
    });
    _scrollToEnd();

    final history = _messages.where((m) => m != _messages.last).toList();
    final reply = await _service.send(history, text);
    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage(text: reply, isUser: false));
      _sending = false;
    });
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Style Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BackgroundWrapper(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 72, 16, 12),
                itemCount: _messages.length + (_sending ? 1 : 0),
                itemBuilder: (_, i) {
                  if (_sending && i == _messages.length) {
                    return _bubble(ChatMessage(text: '…', isUser: false), typing: true);
                  }
                  return _bubble(_messages[i]);
                },
              ),
            ),
            _composer(),
          ],
        ),
      ),
    );
  }

  Widget _bubble(ChatMessage m, {bool typing = false}) {
    final isUser = m.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: isUser
            ? BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kRoyalPurple, Color(0xFF9F75FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: kRoyalPurple.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              )
            : BoxDecoration(
                color: kCardBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: kBorderColor, width: 1),
              ),
        child: typing
            ? const SizedBox(
                width: 28,
                child: Text('• • •', style: TextStyle(color: kElectricBlue, fontWeight: FontWeight.bold)))
            : Text(
                m.text,
                style: kBody(14.5, color: Colors.white),
              ),
      ),
    );
  }

  Widget _composer() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            border: Border(top: BorderSide(color: kBorderColor, width: 1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: kCardBg,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: kBorderColor),
                  ),
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    style: kBody(15, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ask Vastra...',
                      hintStyle: kBody(15, color: kTextSecondary.withOpacity(0.5)),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _send,
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [kRoyalPurple, kElectricBlue]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_upward, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
