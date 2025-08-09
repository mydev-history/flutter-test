// import 'package:flutter/material.dart';

// class PopUp extends StatelessWidget {
//   final String message;
//   final String icon;
//   final bool isCancel;
//   final String mainButtonText;

//   const PopUp({
//     Key? key,
//     required this.message,
//     required this.icon,
//     required this.isCancel,
//     required this.mainButtonText,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final theme = Theme.of(context);

//     return Container(
//       padding: EdgeInsets.all(screenWidth * 0.06),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Icon at the Top
//           Image.asset(
//             icon,
//             width: screenWidth * 0.4,
//             height: screenWidth * 0.4,
//             fit: BoxFit.contain,
//           ),
//           SizedBox(height: screenHeight * 0.02),

//           // Message Text
//           Text(
//             message,
//             textAlign: TextAlign.center,
//             style: theme.textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//           SizedBox(height: screenHeight * 0.03),

//           // Buttons
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               if (isCancel)
//                 OutlinedButton(
//                   onPressed: () {
//                     Navigator.pop(context, false); // Return false when canceled
//                   },
//                   style: OutlinedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(
//                         vertical: screenHeight * 0.018, horizontal: screenWidth * 0.1),
//                     side: BorderSide(color: theme.colorScheme.primary, width: 2),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     backgroundColor: Colors.white,
//                   ),
//                   child: Text(
//                     "Close",
//                     style: theme.textTheme.bodyLarge?.copyWith(
//                       color: theme.colorScheme.primary,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),

//               if (isCancel) SizedBox(width: screenWidth * 0.04),

//               // Main Button with Dynamic Text
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context, true); // Return true when confirmed
//                 },
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.symmetric(
//                       vertical: screenHeight * 0.018, horizontal: screenWidth * 0.1),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   backgroundColor: theme.colorScheme.primary,
//                 ),
//                 child: Text(
//                   mainButtonText,
//                   style: theme.textTheme.bodyLarge?.copyWith(
//                     color: theme.colorScheme.onBackground,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: screenHeight * 0.02),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

class PopUp extends StatefulWidget {
  final String message;
  final String icon;
  final bool isCancel;
  final String mainButtonText;
  final bool isConfirmationRequired; // ✅ New optional parameter
  final String? confirmationText; // ✅ Optional confirmation text

  const PopUp({
    Key? key,
    required this.message,
    required this.icon,
    required this.isCancel,
    required this.mainButtonText,
    this.isConfirmationRequired = false, // Default is false
    this.confirmationText, // Optional
  }) : super(key: key);

  @override
  _PopUpState createState() => _PopUpState();
}

class _PopUpState extends State<PopUp> {
  final TextEditingController _textController = TextEditingController();
  bool isMainButtonEnabled = false; // ✅ Controls button activation

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (widget.isConfirmationRequired && widget.confirmationText != null) {
        setState(() {
          isMainButtonEnabled = _textController.text.trim() == widget.confirmationText;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.06),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ✅ Icon at the Top
          Image.asset(
            widget.icon,
            width: screenWidth * 0.4,
            height: screenWidth * 0.4,
            fit: BoxFit.contain,
          ),
          SizedBox(height: screenHeight * 0.02),

          /// ✅ Message Text
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

          /// ✅ Confirmation Input (Only if required)
          if (widget.isConfirmationRequired && widget.confirmationText != null) ...[
            Text(
              "Type '${widget.confirmationText}' to proceed:",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            TextField(
              controller: _textController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "Enter confirmation text",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
          ],

          /// ✅ Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isCancel)
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context, false); // Return false when canceled
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.018, horizontal: screenWidth * 0.1),
                    side: BorderSide(color: theme.colorScheme.primary, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    "Close",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              if (widget.isCancel) SizedBox(width: screenWidth * 0.04),

              /// ✅ Main Button (Disabled if confirmation is required but incorrect)
              ElevatedButton(
                onPressed: isMainButtonEnabled || !widget.isConfirmationRequired
                    ? () {
                        Navigator.pop(context, true); // Return true when confirmed
                      }
                    : null, // Disabled if text is incorrect
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.018, horizontal: screenWidth * 0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: theme.colorScheme.primary,
                ),
                child: Text(
                  widget.mainButtonText,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
