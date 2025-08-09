// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:wah_frontend_flutter/components/header.dart';
// import 'package:wah_frontend_flutter/components/navbar.dart';
// import 'package:wah_frontend_flutter/components/vendor_header.dart';
// import 'package:wah_frontend_flutter/components/vendor_navbar.dart';
// import 'package:wah_frontend_flutter/providers/vendors_provider/vendor_provider.dart';
// import 'package:wah_frontend_flutter/screens/chat_room.dart';

// class VendorChatScreen extends StatefulWidget {
//   const VendorChatScreen({Key? key}) : super(key: key);

//   @override
//   _VendorChatScreenState createState() => _VendorChatScreenState();
// }

// class _VendorChatScreenState extends State<VendorChatScreen> {
//   final supabase = Supabase.instance.client;
//   List<Map<String, dynamic>> chatList = [];
//   Map<String, bool> expandedCustomers = {}; // Stores expanded customers' state

//   @override
//   void initState() {
//     super.initState();
//     fetchChatList();
//     listenToChatUpdates();
//   }

//   Future<void> fetchChatList() async {
//    final vendorData = Provider.of<VendorProvider>(context, listen: false).vendorData;
//     final vendorId = vendorData?.vendorId ?? "";

//     if (vendorId.isEmpty) {
//       print("❌ Vendor ID is empty");
//       return;
//     }

//     print("🟢 Fetching chats for vendor: $vendorId");

//     try {
//       final response = await supabase.rpc("fetch_vendor_chats", params: {"input_vendor_id": vendorId});

//       if (response == null) {
//         print("❌ No chat sessions found.");
//         return;
//       }

//       final List<Map<String, dynamic>> chatData = List<Map<String, dynamic>>.from(response);

//       print(chatData);
//       setState(() {
//         chatList = chatData;
//       });

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
//     final vendorData = Provider.of<VendorProvider>(context).vendorData;

//     // ✅ Group chats by customer (Ensures customer_id is always used correctly)
//     Map<String, List<Map<String, dynamic>>> groupedChats = {};
//     for (var chat in chatList) {
//       String customerId = chat['participant_1'].startsWith("cust_") ? chat['participant_1'] : chat['participant_2'];

//       if (!groupedChats.containsKey(customerId)) {
//         groupedChats[customerId] = [];
//       }
//       groupedChats[customerId]!.add(chat);
//     }

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ✅ Vendor Header with dynamic business name
//           VendorHeader(
//             businessName: vendorData?.businessName ?? "Loading...",
//             onNotificationTap: () {},
//           ),

//           SizedBox(height: screenHeight * 0.03),

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
//                     padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
//                     itemCount: groupedChats.length,
//                     itemBuilder: (context, index) {
//                       String customerId = groupedChats.keys.elementAt(index);
//                       List<Map<String, dynamic>> chats = groupedChats[customerId]!;
//                       final customerName = chats[0]['customer_name'] ?? "Unknown Customer";
//                       final customerProfile = chats[0]['customer_profile'];

//                       bool hasUnreadMessages = chats.any((chat) => chat['unread_count'] > 0);

//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // ✅ Customer Header
//                           GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 expandedCustomers[customerId] = !(expandedCustomers[customerId] ?? false);
//                               });
//                             },
//                             child: Container(
//                               padding: EdgeInsets.all(screenWidth * 0.03),
//                               decoration: BoxDecoration(
//                                 color: hasUnreadMessages ? Colors.orange.shade50 : Colors.transparent,
//                                 borderRadius: BorderRadius.circular(screenWidth * 0.03),
//                               ),
//                               child: Row(
//                                 children: [
//                                   CircleAvatar(
//                                     radius: screenWidth * 0.07,
//                                     backgroundImage: customerProfile != null ? NetworkImage(customerProfile) : null,
//                                     backgroundColor: Colors.grey.shade300,
//                                     child: customerProfile == null
//                                         ? Icon(Icons.person, color: theme.colorScheme.onBackground, size: screenWidth * 0.05)
//                                         : null,
//                                   ),
//                                   SizedBox(width: screenWidth * 0.03),
//                                   Expanded(
//                                     child: Text(
//                                       customerName,
//                                       style: theme.textTheme.titleMedium?.copyWith(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: screenWidth * 0.045,
//                                       ),
//                                     ),
//                                   ),
//                                   Icon(
//                                     expandedCustomers[customerId] ?? false ? Icons.expand_less : Icons.expand_more,
//                                     size: screenWidth * 0.06,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),

//                           // ✅ Deal Conversations
//                           if (expandedCustomers[customerId] ?? false)
//                             Column(
//                               children: chats.map((chat) {
//                                 return GestureDetector(
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => ChatRoom(chatId: chat['chat_id'], participantName: customerName, participantAvatar: customerProfile),
//                                       ),
//                                     );
//                                   },
//                                   child: Container(
//                                     padding: EdgeInsets.all(screenWidth * 0.03),
//                                     margin: EdgeInsets.only(left: screenWidth * 0.05, bottom: screenHeight * 0.01),
//                                     decoration: BoxDecoration(
//                                       color: Colors.orange.shade50,
//                                       borderRadius: BorderRadius.circular(screenWidth * 0.03),
//                                     ),
//                                     child: Text(chat['deal_title'] ?? "General Chat"),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                         ],
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: VendorNavbar(currentIndex: 3, context: context),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wah_frontend_flutter/components/vendor_header.dart';
import 'package:wah_frontend_flutter/components/vendor_navbar.dart';
import 'package:wah_frontend_flutter/providers/vendors_provider/vendor_provider.dart';
import 'package:wah_frontend_flutter/screens/chat_room.dart';

class VendorChatScreen extends StatefulWidget {
  const VendorChatScreen({Key? key}) : super(key: key);

  @override
  _VendorChatScreenState createState() => _VendorChatScreenState();
}

class _VendorChatScreenState extends State<VendorChatScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> chatList = [];
  Map<String, bool> expandedCustomers = {}; // Tracks expanded customers

  @override
  void initState() {
    super.initState();
    fetchChatList();
    listenToChatUpdates();
  }

  Future<void> fetchChatList() async {
    final vendorData = Provider.of<VendorProvider>(context, listen: false).vendorData;
    final vendorId = vendorData?.vendorId ?? "";

    if (vendorId.isEmpty) {
      print("❌ Vendor ID is empty");
      return;
    }

    print("🟢 Fetching chats for vendor: $vendorId");

    try {
      final response = await supabase.rpc("get_vendor_chats", params: {"input_vendor_id": vendorId});

      if (response == null) {
        print("❌ No chat sessions found.");
        return;
      }

      final List<Map<String, dynamic>> chatData = List<Map<String, dynamic>>.from(response);
      print(chatData);
      setState(() {
        chatList = chatData;
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
    final vendorData = Provider.of<VendorProvider>(context).vendorData;

    // ✅ Group chats by customer
    Map<String, List<Map<String, dynamic>>> groupedChats = {};
    for (var chat in chatList) {
      String customerId = chat['participant_1'].startsWith("cust_") ? chat['participant_1'] : chat['participant_2'];

      if (!groupedChats.containsKey(customerId)) {
        groupedChats[customerId] = [];
      }
      groupedChats[customerId]!.add(chat);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Vendor Header
          VendorHeader(
            businessName: vendorData?.businessName ?? "Loading...",
            onNotificationTap: () {},
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
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    itemCount: groupedChats.length,
                    itemBuilder: (context, index) {
                      String customerId = groupedChats.keys.elementAt(index);
                      List<Map<String, dynamic>> chats = groupedChats[customerId]!;
                      final customerName = chats[0]['customer_name'] ?? "Unknown Customer";
                      final customerProfile = chats[0]['customer_profile'];

                      bool hasUnreadMessages = chats.any((chat) => chat['vendor_unread_count'] > 0);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ Customer Header (Expandable)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                expandedCustomers[customerId] = !(expandedCustomers[customerId] ?? false);
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
                                    backgroundImage: customerProfile != null ? NetworkImage(customerProfile) : null,
                                    backgroundColor: Colors.grey.shade300,
                                    child: customerProfile == null
                                        ? Icon(Icons.person, color: theme.colorScheme.onBackground, size: screenWidth * 0.05)
                                        : null,
                                  ),
                                  SizedBox(width: screenWidth * 0.03),
                                  Expanded(
                                    child: Text(
                                      customerName,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.045,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    expandedCustomers[customerId] ?? false ? Icons.expand_less : Icons.expand_more,
                                    size: screenWidth * 0.06,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ✅ Deal Conversations (Expandable)
                          if (expandedCustomers[customerId] ?? false)
                            Column(
                              children: chats.map((chat) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatRoom(
                                          chatId: chat['chat_id'],
                                          participantName: customerName,
                                          participantAvatar: customerProfile,
                                          receiver_id: customerId,
                                          sender_id: vendorData!.vendorId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(screenWidth * 0.03),
                                    margin: EdgeInsets.only(left: screenWidth * 0.0, bottom: screenHeight * 0.0),
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
                                            if (chat['vendor_unread_count'] > 0)
                                              CircleAvatar(
                                                backgroundColor: Colors.orange,
                                                radius: screenWidth * 0.04,
                                                child: Text(chat['vendor_unread_count'].toString(),
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
      bottomNavigationBar: VendorNavbar(currentIndex: 3, context: context),
    );
  }

  String formatTime(String timestamp) {
    DateTime messageTime = DateTime.parse(timestamp);
    DateTime now = DateTime.now();
    return now.difference(messageTime).inDays == 0 ? "${messageTime.hour}:${messageTime.minute}" : "Yesterday";
  }
}
