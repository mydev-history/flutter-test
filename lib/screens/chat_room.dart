import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:mime/mime.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:wah_frontend_flutter/components/navbar.dart';
import 'package:wah_frontend_flutter/screens/schedule_appointment.dart';

class ChatRoom extends StatefulWidget {
  final String? chatId;
  final String participantName;
  final String? participantAvatar;
  final String receiver_id;
  final String sender_id;
  final String? dealId;

  const ChatRoom({
    Key? key,
    this.chatId,
    required this.participantName,
    this.participantAvatar,
    required this.receiver_id,
    required this.sender_id,
    this.dealId,
  }) : super(key: key);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final supabase = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final parser = EmojiParser();
  bool showSchedule = false; // ✅ Controls Schedule Section Visibility
  bool showAttachmentOptions = false;
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    fetchMessages();
    listenToMessages();
    resetUnreadCount();
  }

   void _toggleSchedule() {
    setState(() {
      showSchedule = !showSchedule;
    });
  }

     /// ✅ Reset Unread Count for the Current User
Future<void> resetUnreadCount() async {
  if (widget.chatId == null || widget.chatId!.isEmpty) return;

  try {
    // ✅ Fetch the chat session to determine participant roles
    final response = await supabase
        .from("ChatSession")
        .select("participant_1, participant_2")
        .eq("chat_id", widget.chatId!)
        .maybeSingle();

    if (response == null) {
      print("❌ No chat session found for chat_id: ${widget.chatId}");
      return;
    }

    final participant1 = response["participant_1"];
    final participant2 = response["participant_2"];

    // ✅ Determine whether the sender is participant_1 or participant_2
    if (widget.sender_id == participant1) {
      await supabase.from("ChatSession").update({
        "participant1_unread_count": 0
      }).eq("chat_id", widget.chatId!);
      print("✅ Reset participant1_unread_count for ${widget.sender_id}");
    } else if (widget.sender_id == participant2) {
      await supabase.from("ChatSession").update({
        "participant2_unread_count": 0
      }).eq("chat_id", widget.chatId!);
      print("✅ Reset participant2_unread_count for ${widget.sender_id}");
    } else {
      print("❌ Sender ID does not match any participant in chat session.");
    }

  } catch (error) {
    print("❌ Error resetting unread count: $error");
  }
}

  Future<void> fetchMessages() async {
    if (widget.chatId == null || widget.chatId!.isEmpty) return;
    try {
      final response = await supabase.rpc("fetch_chat_messages", params: {"input_chat_id": widget.chatId});
      if (response == null) return;
      setState(() {
        messages = List<Map<String, dynamic>>.from(response);
      });
      _scrollToBottom();
    } catch (error) {
      print("❌ Error fetching messages: $error");
    }
  }

  void listenToMessages() {
    supabase
        .channel("chat:${widget.chatId}")
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: "public",
          table: "Messages",
          callback: (payload) => fetchMessages(),
        )
        .subscribe();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

    Future<bool> isAbusiveText(String message) async {
  print("inside abusive text");
  print(message);
  final url = Uri.parse("https://www.purgomalum.com/service/containsprofanity?text=$message");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return response.body.toLowerCase() == "true";
  } else {
    return false; // Assume clean if API fails
  }
}

  Future<void> sendMessage({String? text, String? attachmentUrl}) async {
    if (text == null && attachmentUrl == null) return;

     // ✅ API-based Filtering
      if (text != null) {
  bool isAbusive = await isAbusiveText(text);
  if (isAbusive) {
    print("🚨 Abusive message detected. Message will not be sent.");

    // ✅ Delay Snackbar Execution to Prevent Context Errors
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(content: Text("🚫 Abusive messages are not allowed!")),
        );
      }
    });

    return; // Stop execution if the message is abusive
  }
}


      
    final senderId = widget.sender_id;
    final receiverId = widget.receiver_id;
    String? chatId = widget.chatId;
    final dealId = widget.dealId;

    try {
      if (widget.chatId!.isEmpty) {
        final response = await supabase.rpc("generate_id", params: {"prefix": "chat"});
        chatId = response;

        await supabase.from("ChatSession").insert({
          "chat_id": chatId,
          "participant_1": senderId,
          "participant_2": receiverId,
          "deal_id": dealId,
          "last_message": text ?? "Attachment Sent",
          "last_message_time": DateTime.now().toIso8601String(),
          "unread_count": 1,
        });

        setState(() {
          chatId = chatId;
        });
      }

      final messageIdResponse = await supabase.rpc("generate_id", params: {"prefix": "mess"});
      final message_id = messageIdResponse;

      final newMessage = {
        "message_id": message_id,
        "chat_id": chatId,
        "sender_id": senderId,
        "receiver_id": receiverId,
        "message": text ?? "",
        "attachment_url": attachmentUrl,
        "status": "sent",
        "read_status": false,
      };

      await supabase.from("Messages").insert([newMessage]);


      await supabase.rpc("increment_unread_count_participant", params: {
        "input_chat_id": chatId,
        "sender_id": senderId,
      });

      await supabase.from("ChatSession").update({
        "last_message": text ?? "Attachment Sent",
        "last_message_time": DateTime.now().toIso8601String(),
      }).eq("chat_id", chatId!);
      fetchMessages();
    } catch (error) {
      print("❌ Error sending message: $error");
    }
  }

  Future<void> pickFile(ImageSource source, bool isVideo) async {
    try {
      final pickedFile = isVideo
          ? await _picker.pickVideo(source: source, maxDuration: Duration(minutes: 2, seconds: 30))
          : await _picker.pickImage(source: source);

      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      final fileSize = await file.length();

      if (fileSize > 200 * 1024 * 1024) {
        print("❌ File exceeds 200MB limit.");
        return;
      }

      final fileName = basename(pickedFile.path);
      final fileExt = extension(fileName);
      final filePath = "chat_media/${widget.chatId}/$fileName";
      final contentType = lookupMimeType(fileName) ?? "application/octet-stream";

      final uploadResponse = await supabase.storage
          .from("chat_media")
          .upload(filePath, file, fileOptions: FileOptions(contentType: contentType));

      if (uploadResponse != null) {
        final attachmentUrl = supabase.storage.from("chat_media").getPublicUrl(filePath);
        sendMessage(attachmentUrl: attachmentUrl);
      }
    } catch (error) {
      print("❌ Error picking file: $error");
    }
  }

  String formatDateTime(String timestamp) {
    DateTime date = DateTime.parse(timestamp).toLocal();
    return DateFormat('hh:mm a').format(date);
  }

  Widget _buildMessageItem(Map<String, dynamic> message, bool isSender) {
    DateTime date = DateTime.parse(message['created_at']).toLocal();
    String formattedTime = DateFormat('hh:mm a').format(date);
    
    return Column(
      crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            // if (message['attachment_url'] != null) {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (_) => FullScreenMedia(url: message['attachment_url']),
            //     ),
            //   );
            // }
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSender ? Colors.blue.shade400 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message["attachment_url"] != null)
                  Image.network(
                    message["attachment_url"],
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                if (message["message"] != null)
                  Text(parser.emojify(message["message"])),
                Text(
                  formattedTime,
                  style: TextStyle(fontSize: 12, color: isSender ? Colors.white : Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
   @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final String vendorId = widget.sender_id.startsWith('vend_') ? widget.sender_id : widget.receiver_id;
    final String customerId = widget.sender_id.startsWith('cust_') ? widget.sender_id : widget.receiver_id;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.participantAvatar != null
                  ? NetworkImage(widget.participantAvatar!)
                  : null,
              child: widget.participantAvatar == null ? Icon(Icons.person) : null,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.participantName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/schedule.png',
              width: screenWidth * 0.08, // ✅ Adjust width as needed
              height: screenWidth * 0.08, // ✅ Adjust height as needed
            ),
            onPressed: _toggleSchedule, // ✅ Toggle Schedule Section
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final bool isSender = message["sender_id"] == widget.sender_id;
                return _buildMessageItem(message, isSender);
              },
            ),
          ),

          // ✅ Schedule Section (Only Visible when `showSchedule == true`)
          if (showSchedule)
            Container(
              height: screenHeight * 0.55, // Adjust height as needed
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
              ),
              child: ScheduleAppointmentPage(
                vendorId: vendorId,
                customerId: customerId,
                dealId: widget.dealId ?? "",
                initiatedBy: "vendor",
                vendorAcceptance: true,
                customerName: widget.participantName,

              ),
            ),

          _buildMessageInput(),
        ],
      ),
      bottomNavigationBar: Navbar(currentIndex: 3, context: context),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => setState(() => showAttachmentOptions = !showAttachmentOptions),
          ),
          if (showAttachmentOptions) ...[
            IconButton(icon: Icon(Icons.camera_alt), onPressed: () => pickFile(ImageSource.camera, false)),
            IconButton(icon: Icon(Icons.image), onPressed: () => pickFile(ImageSource.gallery, false)),
            IconButton(icon: Icon(Icons.videocam), onPressed: () => pickFile(ImageSource.gallery, true)),
          ],
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(hintText: "Type a message"),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () => sendMessage(text: _messageController.text.trim()),
          ),
        ],
      ),
    );
  }
}

