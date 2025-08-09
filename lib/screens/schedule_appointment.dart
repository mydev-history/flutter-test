import 'dart:async';
import 'package:flutter/material.dart';
import 'package:booking_calendar/booking_calendar.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wah_frontend_flutter/components/popUp.dart';
import 'package:wah_frontend_flutter/screens/chat_room.dart';
import 'package:wah_frontend_flutter/services/app_service.dart';

class ScheduleAppointmentPage extends StatefulWidget {
  final String vendorId;
  final String customerId;
  final String dealId;
  final String initiatedBy;
  final bool? vendorAcceptance;
  final String? customerName;
  final String? businessName;
  final bool? isEditing;
  final String? scheduleId;

  ScheduleAppointmentPage({
  required this.vendorId, 
  required this.customerId,  
  required this.dealId, 
  required this.initiatedBy, 
  required this.vendorAcceptance, 
  this.businessName, 
  this.customerName, 
  this.isEditing, 
  this.scheduleId});

  @override
  _ScheduleAppointmentPageState createState() => _ScheduleAppointmentPageState();
}

class _ScheduleAppointmentPageState extends State<ScheduleAppointmentPage> {
  final supabase = Supabase.instance.client;
  DateTime selectedDate = DateTime.now();
  List<DateTimeRange> availableSlots = [];
  List<String> bookedSlots = []; // Stores booked slots (HH:mm format)
  int slotDuration = 0;
  String timeZone = "CST";
  List<String> availableDays = [];
  String startTime = "";
  String endTime = "";
  String availablity_id = "";
  late StreamSubscription _scheduleSubscription;

  final AppService appService = AppService(); // Initialize AppService
@override
  void initState() {
    super.initState();
    _fetchVendorAvailability();
    _subscribeToScheduleUpdates(); // ✅ Subscribe to real-time updates
  }

  @override
  void dispose() {
    _scheduleSubscription.cancel(); // ✅ Unsubscribe when widget is disposed
    super.dispose();
  }
  /// **Fetch Vendor Availability & Generate Slots**
  Future<void> _fetchVendorAvailability() async {
    final response = await supabase
        .from('VendorAvailability')
        .select()
        .eq('vendor_id', widget.vendorId)
        .maybeSingle();

    if (response != null) {
      setState(() {
        slotDuration = response['slot_time'] ?? 60;
        timeZone = response['time_zone'] ?? "CST";
        availableDays = List<String>.from(response['availability_days']);
        startTime = response['availability_from'] ??"";
        endTime = response['availability_to'] ?? "";
        availablity_id = response['availability_id'];
      });

      print(response);

      // ✅ Ensure a valid initial date is selected
      if (!_isDateAvailable(selectedDate)) {
        _selectNextAvailableDate();
      } else {
        _fetchScheduledSlots(); // Fetch booked slots before generating available slots
      }
    }
  }

 void _subscribeToScheduleUpdates() {
  _scheduleSubscription = supabase
      .from('Schedule')
      .stream(primaryKey: ['schedule_id']) // ✅ Start listening to changes in Schedule table
      .eq('vendor_id', widget.vendorId)  // ✅ We can use filtering here
      .listen((List<Map<String, dynamic>> data) {
        print("🔄 Realtime Update Received: $data");

        // ✅ Filter only the accepted bookings
        final acceptedBookings = data.where((booking) => booking['vendor_acceptance'] == true).toList();

        if (acceptedBookings.isNotEmpty) {
          _fetchScheduledSlots(); // ✅ Refresh only when there is a relevant update
        }
      });
}

 /// **Fetch Scheduled Slots from `Schedule` Table**
Future<void> _fetchScheduledSlots() async {
  final response = await supabase
      .from('Schedule')
      .select('scheduled_slot')
      .eq('vendor_id', widget.vendorId)
      .eq('scheduled_date', DateFormat('yyyy-MM-dd').format(selectedDate))
      .eq('vendor_acceptance', true); // ✅ Only fetch accepted bookings

  setState(() {
    // ✅ Convert scheduled_slot values to ensure format consistency (HH:mm:ss)
    bookedSlots = response.isNotEmpty
        ? response.map<String>((row) {
            String slotTime = row['scheduled_slot'] as String;
            return slotTime.trim(); // ✅ Ensure no extra spaces
          }).toList()
        : [];
  });

  _generateAvailableSlots(); // ✅ Generate slots after fetching booked ones
}

/// **Generate Available Time Slots Based on Vendor Availability & Bookings**
void _generateAvailableSlots() {
  if (!mounted) return;

  List<DateTimeRange> slots = [];
  TimeOfDay start = _parseTime(startTime);
  TimeOfDay end = _parseTime(endTime);

  print("Generating slots for ${DateFormat('yyyy-MM-dd').format(selectedDate)}");

  String selectedDay = DateFormat('EEEE').format(selectedDate);
  if (!availableDays.contains(selectedDay)) {
    setState(() {
      availableSlots = [];
    });
    return;
  }

  for (int i = start.hour * 60 + start.minute;
      i < end.hour * 60 + end.minute;
      i += slotDuration) {
    DateTime slotStart = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, i ~/ 60, i % 60);
    DateTime slotEnd = slotStart.add(Duration(minutes: slotDuration));

    // ✅ Fix: Correct logic to filter out booked slots
    String slotTimeStr = "${slotStart.hour.toString().padLeft(2, '0')}:${slotStart.minute.toString().padLeft(2, '0')}:00";

    if (bookedSlots.contains(slotTimeStr)) {
      print("Slot $slotTimeStr is booked. Skipping...");
    } else {
      print("Slot $slotTimeStr is available.");
      slots.add(DateTimeRange(start: slotStart, end: slotEnd)); // ✅ Add only available slots
    }
  }

  print("Available Slots: $slots");

  if (mounted) {
    setState(() {
      availableSlots = slots;
    });
  }
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

/// **Insert Booking into Supabase**
Future<void> _uploadBooking(BookingService newBooking) async {
  try {
    final scheduledDate = DateFormat('yyyy-MM-dd').format(newBooking.bookingStart);
    final scheduledSlot = DateFormat('HH:mm:ss').format(newBooking.bookingStart);

    // ✅ Step 1: Check if a booking already exists
    final existingSchedule = await supabase
        .from('Schedule')
        .select('schedule_id')
        .eq('vendor_id', widget.vendorId)
        .eq('customer_id', widget.customerId)
        .eq('deal_id', widget.dealId)
        .maybeSingle(); // ✅ Use maybeSingle() to avoid exceptions if no data found

    if (existingSchedule != null) {
      print("❌ Slot already created: ${existingSchedule['schedule_id']}");
      _showFailurePopup(context, "Slot already created for this deal. Please check your schedule.");
      return; // Exit function to prevent duplicate insertion
    }

    // ✅ Step 2: Insert New Booking
    final response = await supabase.from('Schedule').insert({
      'availability_id': availablity_id, 
      'vendor_id': widget.vendorId,
      'customer_id': widget.customerId,
      'deal_id': widget.dealId,
      'scheduled_date': scheduledDate,
      'scheduled_slot': scheduledSlot,
      'vendor_acceptance': widget.vendorAcceptance, 
      'customer_acceptance': false, 
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    if (response == null) { // ✅ Booking successful
      print("✅ Booking Added: $scheduledDate at $scheduledSlot");
      
      _showSuccessPopup(context, "Booking Successful");

      // ✅ Trigger the sendInvite API
      await appService.sendInvite(
        vendorId: widget.vendorId,
        dealId: widget.dealId,
        customerId: widget.customerId,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledSlot,
        initiatedBy: widget.initiatedBy,
      ).then((result) {
        print("📩 Notification Sent: $result");
      }).catchError((error) {
        print("❌ Failed to send notification: $error");
      });

      _fetchScheduledSlots(); // Refresh booked slots
    } else {
      print("❌ Booking Failed: ");
      _showFailurePopup(context, "Booking Failed");
    }
  } catch (e, stackTrace) {
    print("⚠️ Exception Caught: $e");
    print(stackTrace); 

    _showFailurePopup(context, "Error While Booking, Please Try Again");
  }
}


Future<void> _editBooking(BookingService updatedBooking) async {
  try {
    final scheduledDate = DateFormat('yyyy-MM-dd').format(updatedBooking.bookingStart);
    final scheduledSlot = DateFormat('HH:mm:ss').format(updatedBooking.bookingStart);

    if (widget.scheduleId == null || widget.scheduleId!.isEmpty) {
      print("❌ Schedule ID is missing!");
      _showFailurePopup(context, "Error: Schedule ID is missing.");
      return;
    }

    // ✅ Step 1: Update the Existing Booking
    final response = await supabase
        .from('Schedule')
        .update({
          'scheduled_date': scheduledDate,
          'scheduled_slot': scheduledSlot,
          'updated_at': DateTime.now().toIso8601String(),
          'initiated_by': widget.initiatedBy
        })
        .eq('schedule_id', widget.scheduleId??'');

    if (response == null) { // ✅ Update successful
      print("✅ Booking Updated: $scheduledDate at $scheduledSlot");

      _showSuccessPopup(context, "Booking Updated Successfully");

      // ✅ Step 2: Send Update Notification
      await appService.sendInvite(
        vendorId: widget.vendorId,
        dealId: widget.dealId,
        customerId: widget.customerId,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledSlot,
        initiatedBy: widget.initiatedBy,
      ).then((result) {
        print("📩 Update Notification Sent: $result");
      }).catchError((error) {
        print("❌ Failed to send notification: $error");
      });

      _fetchScheduledSlots(); // Refresh booked slots
    } else {
      print("❌ Booking Update Failed");
      _showFailurePopup(context, "Booking Update Failed");
    }
  } catch (e, stackTrace) {
    print("⚠️ Exception Caught: $e");
    print(stackTrace);

    _showFailurePopup(context, "Error While Updating, Please Try Again");
  }
}


Future<void> navigateToChatRoomForCustomer() async {
  final vendorId = widget.vendorId;
  final dealId = widget.dealId;
  final customerId = widget.customerId;

  if (customerId.isEmpty || vendorId.isEmpty) {
    print("❌ Missing Customer or Vendor ID");
    return;
  }

  print("🟢 Checking for existing chat session: Vendor: $vendorId, Customer: $customerId, Deal: $dealId");

  try {
    String? chatId;

    // ✅ Query ChatSession ensuring participant_1 or participant_2 can be customer/vendor with the SAME deal_id
    final response = await Supabase.instance.client
        .from("ChatSession")
        .select("chat_id")
        .or([
          "participant_1.eq.$customerId,participant_2.eq.$vendorId",
          "participant_1.eq.$vendorId,participant_2.eq.$customerId"
        ].join(","))
        .eq("deal_id", dealId)  // ✅ Ensure only the chat with the given deal_id is selected
        .limit(1) // ✅ Prevent multiple rows error
        .maybeSingle(); // ✅ Returns null if no matching session is found

    if (response != null && response["chat_id"] != null) {
      chatId = response["chat_id"];
      print("✅ Existing chat session found: $chatId");
    } else {
      print("⚡ No chat session found. Navigating to an empty chat room.");
    }

    // ✅ Navigate to Chat Room
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoom(
          chatId: chatId ?? "", // If empty, ChatRoom knows it's a new session
          participantName: widget.customerName?? "",
          participantAvatar: null, // Customer may not have an avatar
          receiver_id: customerId,
          sender_id: vendorId,
          dealId: dealId, // Pass deal ID to create a session if needed
        ),
      ),
    );
  } catch (error) {
    print("❌ Error checking chat session: $error");
  }
}





  /// **Check if the Selected Date is Within Available Days**
  bool _isDateAvailable(DateTime date) {
    String day = DateFormat('EEEE').format(date);
    return availableDays.contains(day);
  }

  /// **Select the Next Available Date**
  void _selectNextAvailableDate() {
    DateTime nextDate = selectedDate;
    for (int i = 0; i < 30; i++) {
      nextDate = selectedDate.add(Duration(days: i));
      if (_isDateAvailable(nextDate)) {
        setState(() {
          selectedDate = nextDate;
        });
        _fetchScheduledSlots(); // ✅ Fetch booked slots for the new date
        return;
      }
    }
    setState(() {
      availableSlots = [];
    });
  }

  /// **Convert Time String to TimeOfDay**
  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
  @override
  Widget build(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  return Scaffold(
    appBar: AppBar(
      title: const Text("Available Slots"),
      actions: [
        GestureDetector(
          onTap: () {
            if (widget.customerId.isNotEmpty) {
              navigateToChatRoomForCustomer();
            } else {
              print("❌ Customer ID missing!");
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Image.asset(
              'assets/chat_color.png',
              width: screenWidth * 0.06, // Adjust size as needed
            ),
          ),
        ),
      ],
    ),

    body: Column(
      children: [
        // ✅ Booking Calendar (Handles Date Selection)
        Expanded(
          child: BookingCalendar(
            bookingService: BookingService(
              serviceName: "Vendor Appointment",
              serviceDuration: slotDuration,
              bookingStart: DateTime(
                  selectedDate.year, selectedDate.month, selectedDate.day,
                  int.parse(startTime.split(":")[0]), int.parse(startTime.split(":")[1])),
              bookingEnd: DateTime(
                  selectedDate.year, selectedDate.month, selectedDate.day,
                  int.parse(endTime.split(":")[0]), int.parse(endTime.split(":")[1])),
              userEmail: "customer@example.com",
              userName: "Customer",
            ),

            // ✅ Capture the selected date change from BookingCalendar
            getBookingStream: ({required DateTime start, required DateTime end}) async* {
              if (selectedDate != start) {
                setState(() {
                  selectedDate = start;
                });

                if (_isDateAvailable(start)) {
                  _fetchScheduledSlots();
                } else {
                  setState(() {
                    availableSlots = []; // Clear slots for unavailable dates
                  });
                }
              }
              yield availableSlots; // ✅ Return available slots so they don't appear booked
            },

            convertStreamResultToDateTimeRanges: ({required dynamic streamResult}) {
              return bookedSlots.map((slot) {
                DateTime startTime = DateFormat("HH:mm:ss").parse(slot);
                return DateTimeRange(
                  start: DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
                      startTime.hour, startTime.minute),
                  end: DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
                      startTime.hour, startTime.minute + slotDuration),
                );
              }).toList();
            },

            uploadBooking: ({required BookingService newBooking}) async {
              if (widget.isEditing == true) {
                _editBooking(newBooking); // ✅ Trigger Edit Booking
              } else {
                _uploadBooking(newBooking); // ✅ Trigger New Booking
              }
            },

            pauseSlots: [],
            availableSlotColor: availableSlots.isEmpty ? Colors.transparent : Colors.green,
            selectedSlotColor: availableSlots.isEmpty ? Colors.transparent : Colors.orange,
            bookedSlotColor: availableSlots.isEmpty ? Colors.transparent : Colors.red,
            bookingGridCrossAxisCount: 3,

            // ✅ Using the Default Booking Button but Changing its Function & Text Dynamically
            bookingButtonText: widget.isEditing == true ? "Edit Booking" : "Book Slot",
            bookingButtonColor: widget.isEditing == true ? Colors.blue : Colors.green,
          ),
        ),

        // ✅ "No available slots" Message Below the Calendar
        Visibility(
          visible: availableSlots.isEmpty,
          child: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              "No available slots for this date",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ),
        ),
      ],
    ),
  );
}

}
