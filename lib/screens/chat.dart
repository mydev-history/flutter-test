

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:wah_frontend_flutter/components/header.dart';
// import 'package:wah_frontend_flutter/components/navbar.dart';
// import 'package:wah_frontend_flutter/providers/customer_provider/customer_provider.dart';
// // import 'package:wah_frontend_flutter/screens/chat_room.dart';

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({Key? key}) : super(key: key);

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final supabase = Supabase.instance.client;
//   List<Map<String, dynamic>> chatList = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchChatList();
//     listenToChatUpdates();
//   }

//   Future<void> fetchChatList() async {

//   final user = supabase.auth.currentUser;
//   print("🟢 Authenticated User ID: ${user?.id}");

//   final customerData = Provider.of<CustomerProvider>(context, listen: false).customerData;
//   final customerId = customerData?.customerId ?? "";

//   if (customerId.isEmpty) {
//     print("❌ Customer ID is empty");
//     return;
//   }

//   print("🟢 Fetching chats for customer: $customerId");

//   final response = await supabase
//     .from("ChatSession")
//     .select("*");

//   print("🟢 Supabase Raw Response (Without Filters): $response");


//    final query = supabase
//       .from("ChatSession")
//       .select("chat_id, participant_1, participant_2, deal_id, last_message, last_message_time, unread_count")
//       .or([
//         "participant_1.eq.$customerId",
//         "participant_2.eq.$customerId"
//       ].join(","))
//       .order("last_message_time", ascending: false);

//   final response1 = await query;

//   print("🟢 Supabase API Request: ${query.toString()}"); // ✅ Logs the exact API request in JSON
//   print("🟢 Supabase Response: $response1");

//   setState(() {
//     chatList = response1 ?? [];
//   });

//   print("🟢 Updated chatList: ${chatList.length} items");
// }




//   /// ✅ Listens for Realtime Chat Updates
// void listenToChatUpdates() {
//   final channel = supabase
//       .channel("public:ChatSession")
//       .onPostgresChanges(
//         event: PostgresChangeEvent.update,
//         schema: "public",
//         table: "ChatSession",
//         callback: (payload) {
//           fetchChatList(); // Refresh chat list when an update occurs
//         },
//       )
//       .subscribe();
// }


//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final customerData = Provider.of<CustomerProvider>(context).customerData;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ✅ Header
//           Header(
//             cityName: customerData!.city,
//             pageTitle: "Chat",
//           ),

//           // ✅ Chat List
//           Expanded(
//             child: chatList.isEmpty
//                 ? Center(
//                     child: Text(
//                       "No chats yet",
//                       style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black54),
//                     ),
//                   )
//                 : ListView.builder(
//                     itemCount: chatList.length,
//                     itemBuilder: (context, index) {
//                       final chat = chatList[index];
//                       final isCustomerParticipant1 = chat['participant_1'] == customerData.customerId;
//                       final otherUserId = isCustomerParticipant1 ? chat['participant_2'] : chat['participant_1'];

//                       return ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor: Colors.grey.shade300,
//                           child: Icon(Icons.person, color: theme.colorScheme.onBackground),
//                         ),
//                         title: Text(
//                           "Chat with $otherUserId",
//                           style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
//                         ),
//                         subtitle: Text(
//                           chat['last_message'] ?? "No messages yet",
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         trailing: chat['unread_count'] > 0
//                             ? CircleAvatar(
//                                 backgroundColor: Colors.orange,
//                                 child: Text(chat['unread_count'].toString()),
//                               )
//                             : Text(
//                                 chat['last_message_time'] != null
//                                     ? formatTime(chat['last_message_time'])
//                                     : "",
//                                 style: theme.textTheme.bodySmall,
//                               ),
//                         onTap: () {
//                           // Navigator.push(
//                           //   context,
//                           //   MaterialPageRoute(
//                           //     builder: (context) => ChatRoomScreen(chatId: chat['chat_id']),
//                           //   ),
//                           // );
//                         },
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),

//       // ✅ Bottom Navigation Bar
//       bottomNavigationBar: Navbar(
//         currentIndex: 3, // Chat Tab
//         context: context,
//       ),
//     );
//   }

//   /// ✅ Utility function to format time (HH:mm or "Yesterday")
//   String formatTime(String timestamp) {
//     DateTime messageTime = DateTime.parse(timestamp);
//     DateTime now = DateTime.now();

//     if (now.difference(messageTime).inDays == 0) {
//       return "${messageTime.hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')}";
//     } else {
//       return "Yesterday";
//     }
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:wah_frontend_flutter/components/header.dart';
// import 'package:wah_frontend_flutter/components/navbar.dart';
// import 'package:wah_frontend_flutter/providers/customer_provider/customer_provider.dart';

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({Key? key}) : super(key: key);

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final supabase = Supabase.instance.client;
//   List<Map<String, dynamic>> chatList = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchChatList();
//     listenToChatUpdates();
//   }

//   Future<void> fetchChatList() async {
//     final customerData = Provider.of<CustomerProvider>(context, listen: false).customerData;
//     final customerId = customerData?.customerId ?? "";

//     if (customerId.isEmpty) {
//       print("❌ Customer ID is empty");
//       return;
//     }

//     print("🟢 Fetching chats for customer: $customerId");

//     try {
//       final response = await supabase.rpc("fetch_customer_chats", params: {"input_customer_id": customerId});

//       if (response == null) {
//         print("❌ No chat sessions found.");
//         return;
//       }

//       final List<Map<String, dynamic>> chatData = List<Map<String, dynamic>>.from(response);

//       setState(() {
//         chatList = chatData;
//       });

//       print(chatList);

//       print("🟢 Updated chatList: ${chatList.length} items");
//     } catch (error, stacktrace) {
//       print("❌ Error fetching chat list: $error");
//       print("🔍 Stacktrace: $stacktrace");
//     }
//   }

//   void listenToChatUpdates() {
//     supabase
//         .channel("public:ChatSession")
//         .onPostgresChanges(
//           event: PostgresChangeEvent.update,
//           schema: "public",
//           table: "ChatSession",
//           callback: (payload) {
//             fetchChatList();
//           },
//         )
//         .subscribe();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final customerData = Provider.of<CustomerProvider>(context).customerData;

//     // ✅ Fix: Normalize vendor ID so all chats with the same vendor are grouped together
//     Map<String, List<Map<String, dynamic>>> groupedChats = {};
//     for (var chat in chatList) {
//       // ✅ Determine the vendor ID (ensures the vendor is always used as the key)
//       String vendorId = chat['participant_1'].startsWith("vend_") ? chat['participant_1'] : chat['participant_2'];

//       if (!groupedChats.containsKey(vendorId)) {
//         groupedChats[vendorId] = [];
//       }
//       groupedChats[vendorId]!.add(chat);
//     }

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ✅ Header
//           Header(
//             cityName: customerData!.city,
//             pageTitle: "Chat",
//           ),

//           // ✅ Chat List
//           Expanded(
//             child: chatList.isEmpty
//                 ? Center(
//                     child: Text(
//                       "No chats yet",
//                       style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black54),
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // ✅ Responsive Padding
//                     itemCount: groupedChats.length,
//                     itemBuilder: (context, index) {
//                       String vendorId = groupedChats.keys.elementAt(index);
//                       List<Map<String, dynamic>> chats = groupedChats[vendorId]!;
//                       final businessName = chats[0]['business_name'] ?? "Unknown Business";
//                       final businessLogo = chats[0]['business_logo'];

//                       return Padding(
//                         padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01), // ✅ Responsive Padding
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // ✅ Vendor Header
//                             Row(
//                               children: [
//                                 CircleAvatar(
//                                   radius: screenWidth * 0.07, // ✅ Responsive Avatar Size
//                                   backgroundImage: businessLogo != null ? NetworkImage(businessLogo) : null,
//                                   backgroundColor: Colors.grey.shade300,
//                                   child: businessLogo == null
//                                       ? Icon(Icons.store, color: theme.colorScheme.onBackground, size: screenWidth * 0.05)
//                                       : null,
//                                 ),
//                                 SizedBox(width: screenWidth * 0.03), // ✅ Responsive Spacing
//                                 Text(
//                                   businessName,
//                                   style: theme.textTheme.titleMedium?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: screenWidth * 0.045, // ✅ Responsive Font Size
//                                   ),
//                                 ),
//                               ],
//                             ),

//                             SizedBox(height: screenHeight * 0.005),

//                             // ✅ Deal Conversations
//                             Column(
//                               children: chats.map((chat) {
//                                 return GestureDetector(
//                                   onTap: () {
//                                     // Navigate to ChatRoomScreen with chat_id
//                                     // Navigator.push(
//                                     //   context,
//                                     //   MaterialPageRoute(
//                                     //     builder: (context) => ChatRoomScreen(chatId: chat['chat_id']),
//                                     //   ),
//                                     // );
//                                   },
//                                   child: Container(
//                                     padding: EdgeInsets.all(screenWidth * 0.03), // ✅ Responsive Padding
//                                     margin: EdgeInsets.only(left: screenWidth * 0.12, bottom: screenHeight * 0.005), // ✅ Responsive Margin
//                                     decoration: BoxDecoration(
//                                       color: Colors.orange.shade50,
//                                       borderRadius: BorderRadius.circular(screenWidth * 0.03),
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               chat['deal_title'] != null
//                                                   ? "${chat['deal_title']} (ID: ${chat['deal_id']})"
//                                                   : "General Chat",
//                                               style: theme.textTheme.bodyLarge?.copyWith(
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: screenWidth * 0.025, // ✅ Responsive Font Size
//                                               ),
//                                             ),
//                                             SizedBox(height: screenHeight * 0.002),
//                                             Text(
//                                               chat['last_message'] ?? "No messages yet",
//                                               maxLines: 1,
//                                               overflow: TextOverflow.ellipsis,
//                                               style: theme.textTheme.bodyMedium?.copyWith(
//                                                 fontSize: screenWidth * 0.038, // ✅ Responsive Font Size
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         Column(
//                                           children: [
//                                             Text(
//                                               chat['last_message_time'] != null
//                                                   ? formatTime(chat['last_message_time'])
//                                                   : "",
//                                               style: theme.textTheme.bodySmall?.copyWith(fontSize: screenWidth * 0.035),
//                                             ),
//                                             if (chat['unread_count'] > 0)
//                                               CircleAvatar(
//                                                 backgroundColor: Colors.orange,
//                                                 radius: screenWidth * 0.04, // ✅ Responsive Badge Size
//                                                 child: Text(chat['unread_count'].toString(),
//                                                     style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.03)),
//                                               ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),

//       // ✅ Bottom Navigation Bar
//       bottomNavigationBar: Navbar(
//         currentIndex: 3, // Chat Tab
//         context: context,
//       ),
//     );
//   }


//   String formatTime(String timestamp) {
//     DateTime messageTime = DateTime.parse(timestamp);
//     DateTime now = DateTime.now();

//     if (now.difference(messageTime).inDays == 0) {
//       return "${messageTime.hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')}";
//     } else {
//       return "Yesterday";
//     }
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wah_frontend_flutter/components/header.dart';
import 'package:wah_frontend_flutter/components/navbar.dart';
import 'package:wah_frontend_flutter/providers/customer_provider/customer_provider.dart';
import 'package:wah_frontend_flutter/screens/chat_room.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> chatList = [];
  Map<String, bool> expandedVendors = {}; // Stores expanded vendors state

  @override
  void initState() {
    super.initState();
    fetchChatList();
    listenToChatUpdates();
  }

  Future<void> fetchChatList() async {
  final customerData = Provider.of<CustomerProvider>(context, listen: false).customerData;
  final customerId = customerData?.customerId ?? "";

  if (customerId.isEmpty) {
    print("❌ Customer ID is empty");
    return;
  }

  print("🟢 Fetching chats for customer: $customerId");

  try {
    final response = await supabase.rpc("get_customer_chats", params: {"input_customer_id": customerId});

    if (response == null) {
      print("❌ No chat sessions found.");
      return;
    }

    final List<Map<String, dynamic>> chatData = List<Map<String, dynamic>>.from(response);

    setState(() {
      chatList = chatData.map((chat) {
        // ✅ Determine the receiver ID (Ensure vendor ID is always the receiver)
        String receiverId = chat['participant_1'].startsWith("vend_") ? chat['participant_1'] : chat['participant_2'];

        return {
          ...chat,
          "receiver_id": receiverId, // ✅ Add receiver_id explicitly
        };
      }).toList();
    });

    print("🟢 Updated chatList: ${chatList.length} items");
  } catch (error, stacktrace) {
    print("❌ Error fetching chat list: $error");
    print("🔍 Stacktrace: $stacktrace");
  }
}


  void listenToChatUpdates() {
    supabase
        .channel("public:ChatSession")
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: "public",
          table: "ChatSession",
          callback: (payload) {
            fetchChatList();
          },
        )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final customerData = Provider.of<CustomerProvider>(context).customerData;

    // ✅ Group chats by vendor (Ensures vendor_id is always used correctly)
    Map<String, List<Map<String, dynamic>>> groupedChats = {};
    for (var chat in chatList) {
      String vendorId = chat['participant_1'].startsWith("vend_") ? chat['participant_1'] : chat['participant_2'];

      if (!groupedChats.containsKey(vendorId)) {
        groupedChats[vendorId] = [];
      }
      groupedChats[vendorId]!.add(chat);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Header
          Header(
            cityName: customerData!.city,
            pageTitle: "Chat",
          ),

          SizedBox(height: screenHeight * 0.03),

          // ✅ Chat List
          Expanded(
            child: chatList.isEmpty
                ? Center(
                    child: Text(
                      "No chats yet",
                      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // Responsive Padding
                    itemCount: groupedChats.length,
                    itemBuilder: (context, index) {
                      String vendorId = groupedChats.keys.elementAt(index);
                      List<Map<String, dynamic>> chats = groupedChats[vendorId]!;
                      final businessName = chats[0]['business_name'] ?? "Unknown Business";
                      final businessLogo = chats[0]['business_logo'];

                      // ✅ Check if any chats under this vendor are unread
                      bool hasUnreadMessages = chats.any((chat) => chat['customer_unread_count'] > 0);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ Vendor Header (Tappable to Expand/Collapse)
                          SizedBox(height: screenWidth * 0.015),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                expandedVendors[vendorId] = !(expandedVendors[vendorId] ?? false);
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(screenWidth * 0.03),
                              decoration: BoxDecoration(
                                color: hasUnreadMessages ? Colors.orange.shade50 : Colors.transparent,
                                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: screenWidth * 0.07,
                                    backgroundImage: businessLogo != null ? NetworkImage(businessLogo) : null,
                                    backgroundColor: Colors.grey.shade300,
                                    child: businessLogo == null
                                        ? Icon(Icons.store, color: theme.colorScheme.onBackground, size: screenWidth * 0.05)
                                        : null,
                                  ),
                                  SizedBox(width: screenWidth * 0.03),
                                  Expanded(
                                    child: Text(
                                      businessName,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.045,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    expandedVendors[vendorId] ?? false ? Icons.expand_less : Icons.expand_more,
                                    size: screenWidth * 0.06,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ✅ Deal Conversations (Expand/Collapse)
                          if (expandedVendors[vendorId] ?? false)
                            Column(
                              children: chats.map((chat) {
                                return GestureDetector(
                                 onTap: () {
                                    // ✅ Navigate to `ChatRoomScreen` with `chat_id`
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatRoom(chatId: chat['chat_id'], participantName: businessName, participantAvatar: businessLogo, receiver_id: vendorId, sender_id: customerData.customerId,),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(screenWidth * 0.03),
                                    margin: EdgeInsets.only(left: screenWidth * 0.0, bottom: screenHeight * 0.00),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(screenWidth * 0.0),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              chat['deal_title'] != null
                                                  ? "${chat['deal_title']} (${chat['deal_id'].split("_")[1]})"
                                                  : "General Chat",
                                              style: theme.textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: screenWidth * 0.03,
                                              ),
                                            ),
                                            SizedBox(height: screenHeight * 0.002),
                                            Text(
                                              chat['last_message'] ?? "No messages yet",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.bodyMedium?.copyWith(fontSize: screenWidth * 0.03),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              chat['last_message_time'] != null ? formatTime(chat['last_message_time']) : "",
                                              style: theme.textTheme.bodySmall?.copyWith(fontSize: screenWidth * 0.035),
                                            ),
                                            if (chat['customer_unread_count'] > 0)
                                              CircleAvatar(
                                                backgroundColor: Colors.orange,
                                                radius: screenWidth * 0.04,
                                                child: Text(chat['customer_unread_count'].toString(),
                                                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.03)),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Navbar(currentIndex: 3, context: context),
    );
  }

  String formatTime(String timestamp) {
    DateTime messageTime = DateTime.parse(timestamp);
    DateTime now = DateTime.now();
    return now.difference(messageTime).inDays == 0 ? "${messageTime.hour}:${messageTime.minute}" : "Yesterday";
  }
}
