// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:wah_frontend_flutter/components/popUp.dart';
import 'package:wah_frontend_flutter/screens/schedule_appointment.dart';
import 'package:wah_frontend_flutter/services/vendor_service.dart';
import 'package:intl/intl.dart';
import 'package:wah_frontend_flutter/services/app_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduledAppointments extends StatefulWidget {
  final String vendorId;

  const ScheduledAppointments({Key? key, required this.vendorId}) : super(key: key);

  @override
  _ScheduledAppointmentsState createState() => _ScheduledAppointmentsState();
}

class _ScheduledAppointmentsState extends State<ScheduledAppointments> {
  final VendorService _vendorService = VendorService();
  String _selectedFilter = 'All';
  bool _isAscending = true;
  String _searchQuery = "";
   final supabase = Supabase.instance.client;
     final AppService appService = AppService(); // Initialize AppService

  List<Map<String, dynamic>> _allSchedules = [];
  Map<String, List<Map<String, dynamic>>> _filteredSchedules = {
    "Today's Schedules": [],
    "Upcoming Schedules": [],
    "Previous Appointments": []
  };

  @override
  void initState() {
    super.initState();
    _fetchSchedules(); // Fetch only once
  }

  /// ✅ Fetch schedules **only once** and store them
  Future<void> _fetchSchedules() async {
    List<Map<String, dynamic>> schedules = await _vendorService.getVendorSchedules(widget.vendorId);
    setState(() {
      _allSchedules = schedules;
      _applyFilters(); // Apply filters after fetching
    });
  }


  /// ✅ Apply filters **locally** on stored data
  void _applyFilters() {
    DateTime currentDate = DateTime.now();

    Map<String, List<Map<String, dynamic>>> groupedSchedules = {
      "Today's Schedules": [],
      "Upcoming Schedules": [],
      "Previous Appointments": []
    };

    for (var schedule in _allSchedules) {
      String rawDate = schedule['scheduled_date'];
      DateTime? scheduledDate;

      try {
        scheduledDate = DateFormat('MMM dd yyyy').parse(rawDate); // ✅ Correct format
      } catch (e) {
        print("Date parsing error: $rawDate - $e");
        continue;
      }

      bool matchesFilter = true;
      switch (_selectedFilter) {
        case "Vendor":
          matchesFilter = schedule['initiated_by'] == 'vendor';
          break;
        case "Customer":
          matchesFilter = schedule['initiated_by'] != 'vendor';
          break;
        case "Approved":
          matchesFilter = schedule['vendor_acceptance'] == true;
          break;
        case "Not Approved":
          matchesFilter = schedule['vendor_acceptance'] != true;
          break;
        case "Previous Appointments":
          matchesFilter = scheduledDate.isBefore(currentDate);
          break;
        default:
          matchesFilter = true;
      }

      if (!matchesFilter) continue;

      if (scheduledDate.isBefore(currentDate.subtract(const Duration(days: 1)))) {
        groupedSchedules["Previous Appointments"]!.add(schedule);
      } else if (scheduledDate.year == currentDate.year &&
          scheduledDate.month == currentDate.month &&
          scheduledDate.day == currentDate.day) {
        groupedSchedules["Today's Schedules"]!.add(schedule);
      } else {
        groupedSchedules["Upcoming Schedules"]!.add(schedule);
      }
    }

    // ✅ Apply sorting
    groupedSchedules.forEach((key, list) {
      list.sort((a, b) {
        DateTime dateA = DateFormat('MMM dd yyyy').parse(a['scheduled_date']);
        DateTime dateB = DateFormat('MMM dd yyyy').parse(b['scheduled_date']);
        return _isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      });
    });

    setState(() {
      _filteredSchedules = groupedSchedules;
    });
  }

  /// ✅ Show filter bottom sheet
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Filter Appointments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildFilterOption("All"),
              _buildFilterOption("Vendor"),
              _buildFilterOption("Customer"),
              _buildFilterOption("Approved"),
              _buildFilterOption("Not Approved"),
              _buildFilterOption("Previous Appointments"),
              ListTile(
                title: const Text("Sort by Scheduled Date"),
                trailing: Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward),
                onTap: () {
                  setState(() {
                    _isAscending = !_isAscending;
                    _applyFilters();
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }



Future<void> _showSuccessPopup(BuildContext context, String message) async {
    bool? isClosed = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return PopUp(
          message: message,
          icon: "assets/success.png",
          isCancel: false,
          mainButtonText: "Close",
        );
      },
    );

    // Navigate back to the previous screen when the popup is closed.
    if (isClosed == true) {
      Navigator.pop(context);
    }
  }

  Future<void> _showFailurePopup(BuildContext context, String message) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return PopUp(
          message: message,
          icon: "assets/close.png",
          isCancel: false,
          mainButtonText: "Close",
        );
      },
    );
  }
  /// **Approve Schedule in Supabase**
Future<void> approveSchedule(String scheduleId) async {
  try {
    final response = await supabase
        .from('Schedule')
        .update({
          'vendor_acceptance': true, // ✅ Mark as approved
          'updated_at': DateTime.now().toIso8601String(), // ✅ Track update time
        })
        .eq('schedule_id', scheduleId);

    if (response == null) { // ✅ Update successful
      print("✅ Schedule Approved: $scheduleId");

      // ✅ Fetch the schedule details for email notification
      final scheduleData = await supabase
          .from('Schedule')
          .select('vendor_id, customer_id, deal_id, scheduled_date, scheduled_slot, initiated_by')
          .eq('schedule_id', scheduleId)
          .single();

      final scheduledDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(scheduleData['scheduled_date']));
      final scheduledTime = scheduleData['scheduled_slot'];

      // ✅ Send Email Notification
      await appService.sendInvite(
        vendorId: scheduleData['vendor_id'],
        dealId: scheduleData['deal_id'],
        customerId: scheduleData['customer_id'],
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        initiatedBy: scheduleData['initiated_by'],
      ).then((result) {
        print("📩 Approval Notification Sent: $result");
      }).catchError((error) {
        print("❌ Failed to send approval notification: $error");
      });
    
      _fetchSchedules(); // Refresh list after approval
      _showSuccessPopup(context, "Schedule Approved Successfully");
    } else {
      print("❌ Schedule Approval Failed: $response");
      _showFailurePopup(context, "Approval Failed");
    }
  } catch (e, stackTrace) {
    print("⚠️ Exception Caught: $e");
    print(stackTrace); // ✅ Debugging log
    _showFailurePopup(context, "Error Approving Schedule, Please Try Again");
  }
}




  Widget _buildFilterOption(String option) {
    return ListTile(
      title: Text(option),
      leading: Radio(
        value: option,
        groupValue: _selectedFilter,
        onChanged: (value) {
          setState(() {
            _selectedFilter = value as String;
            _applyFilters();
            Navigator.pop(context);
          });
        },
      ),
    );
  }

  

  /// ✅ Search Functionality - Filters only "Today's Schedules"
  List<Map<String, dynamic>> _getSearchResults() {
    if (_searchQuery.isEmpty) {
      return _filteredSchedules["Today's Schedules"]!;
    }
    return _filteredSchedules["Today's Schedules"]!.where((schedule) {
      String vendorId = schedule['vendor_id'].toLowerCase();
      String dealId = schedule['deal_id'].toLowerCase();
      String dealTitle = schedule['deal_title'].toLowerCase();
      String customerId = schedule['customer_id'].toLowerCase();
      String customerName = schedule['first_name'].toLowerCase();

      return vendorId.contains(_searchQuery) ||
          dealId.contains(_searchQuery) ||
          dealTitle.contains(_searchQuery) ||
          customerId.contains(_searchQuery) ||
          customerName.contains(_searchQuery);
    }).toList();
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
        title: Text(
          "Scheduled Appointments",
          style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05
        , vertical: screenHeight * 0.02),
        child: _filteredSchedules.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  /// ✅ **Search Bar Above "Today's Schedules"**
                  Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search by Vendor ID, Deal ID, Deal Title, Customer ID, Name",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),

                  /// ✅ **Filtered Schedules**
                  ..._filteredSchedules.keys.where((key) => _filteredSchedules[key]!.isNotEmpty).map((dateGroup) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dateGroup,
                                style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.filter_list),
                                onPressed: _showFilterBottomSheet,
                              ),
                            ],
                          ),
                        ),

                        /// ✅ **Search is applied only to "Today's Schedules"**
                        if (dateGroup == "Today's Schedules")
                          ..._getSearchResults()
                              .map((schedule) => _buildAppointmentCard(schedule, screenWidth, screenHeight)),
                               

                        if (dateGroup != "Today's Schedules")
                          ..._filteredSchedules[dateGroup]!
                              .map((schedule) => _buildAppointmentCard(schedule, screenWidth, screenHeight)),
                      ],
                    );
                  }).toList(),
                ],
              ),
      ),
    );
  }

/// ✅ Build appointment card with updated design
Widget _buildAppointmentCard(Map<String, dynamic> schedule, double screenWidth, double screenHeight) {
  final isApproved = schedule['vendor_acceptance'] == true;
  final scheduledText = schedule['initiated_by'] == 'vendor'
      ? "You scheduled an appointment with ${schedule['first_name']} for ${schedule['deal_title']} on ${schedule['scheduled_date']} at ${schedule['scheduled_time']}"
      : "${schedule['first_name']} scheduled ${schedule['deal_title']} on ${schedule['scheduled_date']} at ${schedule['scheduled_time']}";

  final address = "${schedule['address']}, ${schedule['city']}, ${schedule['state']}, ${schedule['country']} - ${schedule['zipcode']}";

  return Column(
    children: [
      Padding(
        padding: EdgeInsets.only(bottom: screenHeight * 0.015),
        child: Row(
          children: [
            // Status Bar (Green if Approved, Red if Not Approved)
            Container(
              width: screenWidth * 0.015,
              height: screenHeight * 0.15, // Increased height for location display
              decoration: BoxDecoration(
                color: isApproved ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(width: screenWidth * 0.03),

            // Appointment Container
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
                    // Appointment Text
                    Text(
                      scheduledText,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: screenHeight * 0.008),

                    // ✅ Location Row (Icon + Address)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, color: Colors.red, size: screenWidth * 0.05),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Text(
                            address,
                            style: TextStyle(color: Colors.black87, fontSize: screenWidth * 0.032),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    // Buttons inside Container
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ✅ Approve Button (Only if Not Approved)
                        if (!isApproved)
                          GestureDetector(
                            onTap: () async {
                              print(schedule['schedule_id']);
                              await approveSchedule(schedule['schedule_id']); // ✅ Trigger approval function
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.green, width: 2), // ✅ Only border color
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check, color: Colors.green, size: 18),
                                  SizedBox(width: 5),
                                  Text("Approve", style: TextStyle(color: Colors.green)),
                                ],
                              ),
                            ),
                          ),

                        // ✅ Edit Button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScheduleAppointmentPage(
                                  vendorId: schedule['vendor_id'],
                                  customerId: schedule['customer_id'],
                                  dealId: schedule['deal_id'],
                                  initiatedBy: 'vendor',
                                  vendorAcceptance: schedule['vendor_acceptance'],
                                  customerName: schedule['first_name'],
                                  isEditing: true, // ✅ Set to true for editing mode
                                  scheduleId: schedule['schedule_id'], // ✅ Pass schedule ID
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black45, width: 2), // ✅ Only border color
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.edit_outlined, color: Colors.black45, size: 18),
                                SizedBox(width: 5),
                                Text("Edit", style: TextStyle(color: Colors.black45)),
                              ],
                            ),
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
      ),

      // ✅ Divider after each appointment
      Divider(thickness: 1, color: Colors.grey.shade300),
    ],
  );
}



}
