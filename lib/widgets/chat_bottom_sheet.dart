import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking_request.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

void showAppChatBottomSheet(
  BuildContext context, {
  required BookingRequest booking,
  required bool isCustomer,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => ChatBottomSheet(booking: booking, isCustomer: isCustomer),
  );
}

class ChatBottomSheet extends StatefulWidget {
  final BookingRequest booking;
  final bool isCustomer;

  const ChatBottomSheet({
    super.key,
    required this.booking,
    required this.isCustomer,
  });

  @override
  State<ChatBottomSheet> createState() => _ChatBottomSheetState();
}

class _ChatBottomSheetState extends State<ChatBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final user = authProvider.currentUser;

    bookingProvider.sendMessage(
      widget.booking.id,
      user.id,
      user.name,
      text,
      widget.isCustomer,
    );

    _controller.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookingProvider = Provider.of<BookingProvider>(context);

    final otherPartyName = widget.isCustomer
        ? (widget.booking.selectedWorkerName ?? 'Technician')
        : widget.booking.customerName;

    final otherPartyRole = widget.isCustomer ? 'Service Specialist' : 'Customer';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: SizedBox(
        height: 520,
        child: Column(
          children: [
            // Top Bar
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: (widget.isCustomer ? AppTheme.primaryColor : AppTheme.secondaryColor).withValues(alpha: 0.15),
                  child: Icon(
                    widget.isCustomer ? Icons.engineering : Icons.person,
                    color: widget.isCustomer ? AppTheme.primaryColor : AppTheme.secondaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherPartyName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$otherPartyRole • Live Coordination',
                            style: const TextStyle(color: AppTheme.subtitleColor, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 20),

            // Real-time Chat Messages Stream
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirestoreService.streamChatMessages(widget.booking.id),
                builder: (context, snapshot) {
                  List<ChatMessage> messages = [];

                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    messages = snapshot.data!.docs
                        .map((doc) => ChatMessage.fromMap(doc.data()))
                        .toList();
                  } else {
                    messages = bookingProvider.getMessages(widget.booking.id);
                  }

                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 44,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No messages yet with $otherPartyName.',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Send a message to coordinate arrival, location, or problem details.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.subtitleColor, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, idx) {
                      final msg = messages[idx];
                      final isMe = widget.isCustomer ? msg.isCustomer : !msg.isCustomer;
                      final myColor = widget.isCustomer ? AppTheme.primaryColor : AppTheme.secondaryColor;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe
                                ? myColor
                                : (isDark ? const Color(0xFF262626) : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(14),
                              topRight: const Radius.circular(14),
                              bottomLeft: Radius.circular(isMe ? 14 : 2),
                              bottomRight: Radius.circular(isMe ? 2 : 14),
                            ),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.text,
                                style: TextStyle(
                                  color: isMe
                                      ? Colors.white
                                      : (isDark ? Colors.white : Colors.black87),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isMe ? Colors.white70 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // Input Bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type message to $otherPartyName...',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: widget.isCustomer ? AppTheme.primaryColor : AppTheme.secondaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
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
}
