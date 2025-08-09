import 'package:flutter/material.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wah_frontend_flutter/components/popUp.dart';
import 'package:wah_frontend_flutter/modals/vendors_modals/vendor_data.dart';
import 'package:wah_frontend_flutter/providers/vendors_provider/vendor_provider.dart';
import 'package:wah_frontend_flutter/services/vendor_service.dart';

class VendorAvailability extends StatefulWidget {
  @override
  _VendorAvailabilityState createState() => _VendorAvailabilityState();
}

class _VendorAvailabilityState extends State<VendorAvailability> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  MultiSelectController<String> multiSelectController = MultiSelectController();


  String? selectedTimezone;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  List<String> selectedDays = [];
  int? selectedSlotTime;
  String? availabilityId; // Store existing availability ID
  bool isEditMode = false;

  List<String> daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  List<int> slotTimes = [30, 60, 120]; // Slot times in minutes
  List<String> timeZones = ["UTC", "PST", "CST", "EST", "IST"]; // Example time zones


  @override
  void initState() {
    super.initState();
    _fetchVendorAvailability();
  }

  /// **Fetch Vendor Availability**
  Future<void> _fetchVendorAvailability() async {
  final VendorData? vendorData = Provider.of<VendorProvider>(context, listen: false).vendorData;
  if (vendorData == null) return;

  final response = await supabase
      .from('VendorAvailability')
      .select()
      .eq('vendor_id', vendorData.vendorId)
      .maybeSingle(); // Fetch a single record

  if (response != null) {
    List<dynamic> rawDays = response['availability_days']; // Get raw list
    List<String> formattedDays = rawDays.map((day) => day.toString()).toList(); // Convert to List<String>

    print("Fetched Days: $rawDays"); // ✅ Debugging: Check raw data
    print("Formatted Days: $formattedDays"); // ✅ Debugging: Ensure conversion

    setState(() {
      isEditMode = true;
      availabilityId = response['availability_id'];
      selectedDays = formattedDays; // ✅ Ensure proper formatting
      selectedStartTime = _parseTime(response['availability_from']);
      selectedEndTime = _parseTime(response['availability_to']);
      selectedSlotTime = response['slot_time'];
      selectedTimezone = response['time_zone'];
    });

    print("Updated selectedDays in State: $selectedDays"); // ✅ Debugging: Verify final state

    selectedDays.forEach((day) {
      print("Selected day exists in daysOfWeek: ${daysOfWeek.contains(day)} for day: $day");
    });

  }
}


  /// **Convert Time String to TimeOfDay**
  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
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

   @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final VendorData? vendorData = Provider.of<VendorProvider>(context).vendorData;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bubble Design + Logo
            Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/hero_bubble.png',
                    width: screenWidth,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.1),
                  child: Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/Logo.png',
                          height: screenHeight * 0.15,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          isEditMode ? "Edit Availability" : "Add Availability",
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),

            // Form Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Select Available Days
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Available Days", style: theme.textTheme.titleMedium),
                    ),
                    MultiSelectContainer(
                    items: daysOfWeek.map((day) => MultiSelectCard(
                      value: day,
                      label: day,
                      selected: selectedDays.contains(day), // ✅ Ensure selection
                    )).toList(),
                    onChange: (values, reason) {
                      setState(() {
                        selectedDays = values.cast<String>();
                        print("Updated Selected Days: $selectedDays"); // ✅ Debugging
                      });
                    },
                  ),



                    SizedBox(height: screenHeight * 0.02),

                    // Start Time Picker
                    _buildTimePicker("Availability From", selectedStartTime, (pickedTime) {
                      setState(() => selectedStartTime = pickedTime);
                    }),

                    SizedBox(height: screenHeight * 0.02),

                    // End Time Picker
                    _buildTimePicker("Availability To", selectedEndTime, (pickedTime) {
                      setState(() => selectedEndTime = pickedTime);
                    }),

                    SizedBox(height: screenHeight * 0.02),

                    // Slot Duration Selection
                    _buildDropdown("Slot Duration (mins)", slotTimes, selectedSlotTime, (value) {
                      setState(() => selectedSlotTime = value as int?);
                    }),

                    SizedBox(height: screenHeight * 0.02),

                    // Time Zone Selection
                    _buildDropdown("Time Zone", timeZones, selectedTimezone, (value) {
                      setState(() => selectedTimezone = value as String?);
                    }),

                    SizedBox(height: screenHeight * 0.03),

                    // Save/Update Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (vendorData != null) {
                            _saveAvailability(vendorData.vendorId);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                        ),
                        child: Text(
                          isEditMode ? "Update Availability" : "Save Availability",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Time Picker
  Widget _buildTimePicker(String label, TimeOfDay? selectedTime, Function(TimeOfDay) onTimePicked) {
    return GestureDetector(
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
        );
        if (pickedTime != null) onTimePicked(pickedTime);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(selectedTime != null ? selectedTime.format(context) : "Select $label"),
            Icon(Icons.access_time),
          ],
        ),
      ),
    );
  }

  // Dropdown Builder
  Widget _buildDropdown(String label, List<dynamic> options, dynamic selectedValue, Function(dynamic) onChanged) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      value: selectedValue,
      items: options.map((option) {
        return DropdownMenuItem(value: option, child: Text(option.toString()));
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? "$label is required" : null,
    );
  }

  // **Save or Update Vendor Availability**
  Future<void> _saveAvailability(String vendorId) async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDays.isEmpty || selectedStartTime == null || selectedEndTime == null || selectedSlotTime == null || selectedTimezone == null) {
      _showFailurePopup(context, "Please complete all fields.");
      return;
    }

    final startTime = "${selectedStartTime!.hour.toString().padLeft(2, '0')}:${selectedStartTime!.minute.toString().padLeft(2, '0')}:00";
    final endTime = "${selectedEndTime!.hour.toString().padLeft(2, '0')}:${selectedEndTime!.minute.toString().padLeft(2, '0')}:00";

    final data = {
      'vendor_id': vendorId,
      'availability_days': selectedDays,
      'availability_from': startTime,
      'availability_to': endTime,
      'slot_time': selectedSlotTime,
      'time_zone': selectedTimezone,
    };

    try {
      if (isEditMode && availabilityId != null) {
        await supabase.from('VendorAvailability').update(data).eq('availability_id', availabilityId!);
      } else {
        await supabase.from('VendorAvailability').insert(data);
      }
      _showSuccessPopup(context, "Availability saved successfully!");
    } catch (e) {
      _showFailurePopup(context, "An unexpected error occurred: $e");
    }
  }


}
