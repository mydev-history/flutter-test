
import 'package:flutter/material.dart';
import 'package:wah_frontend_flutter/services/vendor_service.dart';

class VendorNotifications extends StatefulWidget {
  final String vendorId;

  const VendorNotifications({Key? key, required this.vendorId}) : super(key: key);

  @override
  _VendorNotificationsState createState() => _VendorNotificationsState();
}

class _VendorNotificationsState extends State<VendorNotifications> {
  late Future<List<Map<String, dynamic>>> _notificationsFuture;
  final VendorService _vendorService = VendorService();

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _fetchAndMarkNotifications();
  }

  /// ✅ Fetch notifications and then mark them as read
  Future<List<Map<String, dynamic>>> _fetchAndMarkNotifications() async {
    final notifications = await _vendorService.fetchvendorNotifications(widget.vendorId);

    if (notifications.isNotEmpty) {
      await _vendorService.markNotificationsAsRead(widget.vendorId);
    }

    return notifications;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/wah_logo.png',
              height: screenHeight * 0.035, // Responsive height
            ),
            const SizedBox(width: 8),
            const Text(
              "Notifications",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _notificationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No notifications available"));
            }

            final notifications = snapshot.data!;
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isPositive = notification['type'] == "positive";

                return Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                  child: Row(
                    children: [
                      // ✅ Status Bar (Green for positive, Red for negative)
                      Container(
                        width: screenWidth * 0.015,
                        height: screenHeight * 0.1,
                        decoration: BoxDecoration(
                          color: isPositive ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),

                      // ✅ Notification Box
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 5,
                                spreadRadius: 2,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification['message'],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Text(
                                notification['date'] + " • " + notification['time'],
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
