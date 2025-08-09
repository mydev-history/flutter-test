// import 'package:flutter/material.dart';

// class DealCard extends StatelessWidget {
//   final String imageUrl;
//   final String dealTitle;
//   final String businessName;
//   final double wahPrice;
//   final double regularPrice;
//   final double discount;
//   final bool isTrending;
//   final bool isFavorite;
//   final double? rating;
//   final int? reviews;

//   const DealCard({
//     Key? key,
//     required this.imageUrl,
//     required this.dealTitle,
//     required this.businessName,
//     required this.wahPrice,
//     required this.regularPrice,
//     required this.discount,
//     required this.isTrending,
//     required this.isFavorite,
//     this.rating,
//     this.reviews,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     // Scaling factors for dimensions and font sizes
//     final fontSizeBase = screenHeight * 0.015;

//     return Container(
//       margin: EdgeInsets.symmetric(
//         vertical: screenHeight * 0.01,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(screenWidth * 0.04),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: screenHeight * 0.01,
//             offset: Offset(0, screenHeight * 0.005),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Image and overlays
//           Stack(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.vertical(
//                   top: Radius.circular(screenWidth * 0.04),
//                 ),
//                 child: Image.network(
//                   imageUrl,
//                   height: screenHeight * 0.18,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               if (isTrending)
//                 Positioned(
//                   top: screenHeight * 0.01,
//                   left: screenWidth * 0.02,
//                   child: Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: screenWidth * 0.02,
//                       vertical: screenHeight * 0.005,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.green,
//                       borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                     ),
//                     child: Text(
//                       'Trending',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: fontSizeBase,
//                       ),
//                     ),
//                   ),
//                 ),
//               Positioned(
//                 top: screenHeight * 0.01,
//                 right: screenWidth * 0.02,
//                 child: Icon(
//                   isFavorite ? Icons.favorite : Icons.favorite_border,
//                   color: isFavorite ? Colors.red : Colors.grey,
//                   size: fontSizeBase * 2,
//                 ),
//               ),
//             ],
//           ),

//           // Content Section
//           Padding(
//             padding: EdgeInsets.all(screenWidth * 0.03),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   dealTitle,
//                   style: TextStyle(
//                     fontSize: fontSizeBase * 1.2,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: screenHeight * 0.005),
//                 Text(
//                   businessName,
//                   style: TextStyle(
//                     fontSize: fontSizeBase,
//                     color: Colors.grey,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: screenHeight * 0.01),
//                 Row(
//                   children: [
//                     Text(
//                       '\$$wahPrice',
//                       style: TextStyle(
//                         fontSize: fontSizeBase * 1.2,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(width: screenWidth * 0.02),
//                     Text(
//                       '\$$regularPrice',
//                       style: TextStyle(
//                         fontSize: fontSizeBase,
//                         color: Colors.grey,
//                         decoration: TextDecoration.lineThrough,
//                       ),
//                     ),
//                     SizedBox(width: screenWidth * 0.02),
//                     Text(
//                       '${discount.toInt()}% OFF',
//                       style: TextStyle(
//                         fontSize: fontSizeBase,
//                         color: Colors.orange,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
                // if (rating != null && reviews != null)
                //   Padding(
                //     padding: EdgeInsets.only(top: screenHeight * 0.01),
                //     child: Row(
                //       children: [
                //         Icon(
                //           Icons.star,
                //           color: Colors.amber,
                //           size: fontSizeBase * 1.5,
                //         ),
                //         SizedBox(width: screenWidth * 0.01),
                //         Text(
                //           '$rating',
                //           style: TextStyle(
                //             fontSize: fontSizeBase,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //         SizedBox(width: screenWidth * 0.01),
                //         Text(
                //           '($reviews)',
                //           style: TextStyle(
                //             fontSize: fontSizeBase,
                //             color: Colors.grey,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';

// class DealCard extends StatelessWidget {
//   final String imageUrl;
//   final String dealTitle;
//   final String businessName;
//   final double wahPrice;
//   final double regularPrice;
//   final double discount;
//   final bool isTrending;
//   final bool isFavorite;
//   final double? rating;
//   final int? reviews;

//   const DealCard({
//     Key? key,
//     required this.imageUrl,
//     required this.dealTitle,
//     required this.businessName,
//     required this.wahPrice,
//     required this.regularPrice,
//     required this.discount,
//     required this.isTrending,
//     required this.isFavorite,
//     this.rating,
//     this.reviews, 
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final fixedHeight = screenHeight * 0.18;// Default fixed height
//     print("Inside Deal Card");
//     print(rating);
//     // Dynamically calculate the card width
//     final cardWidth = (screenWidth - (screenWidth * 0.12)) / 2; // Fit 2 cards per row
//     final imageHeight = fixedHeight * 0.9;// Proportional image height based on fixed height
   
//     return Container(
//       width: cardWidth,
//       height: screenHeight * 0.1, // Fixed height for the card
//       margin: const EdgeInsets.only(bottom: 12.0), // Add margin for spacing
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 6.0,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Image Section
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(
//               top: Radius.circular(12.0),
//             ),
//             child: Image.network(
//               imageUrl,
//               height: imageHeight, // Fixed image height
//               width: double.infinity,
//               fit: BoxFit.contain,
//             ),
//           ),

//           // Content Section
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensure spacing is even
//               children: [
//                 // Deal Title
//                 Text(
//                   dealTitle,
//                   style: const TextStyle(
//                     fontSize: 14.0,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 4.0),

//                 // Business Name
//                 Text(
//                   businessName,
//                   style: const TextStyle(
//                     fontSize: 12.0,
//                     color: Colors.grey,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 8.0),

//                 // Price and Discount Section
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Price and Discount
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           '\$$wahPrice',
//                           style: const TextStyle(
//                             fontSize: 14.0,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Row(
//                           children: [
//                             Text(
//                               '\$$regularPrice',
//                               style: const TextStyle(
//                                 fontSize: 12.0,
//                                 color: Colors.grey,
//                                 decoration: TextDecoration.lineThrough,
//                               ),
//                             ),
//                             const SizedBox(width: 4.0),
//                             Text(
//                               '${discount.toInt()}% OFF',
//                               style: const TextStyle(
//                                 fontSize: 12.0,
//                                 color: Colors.orange,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                         if (rating != null)
//                         Padding(
//                           padding: EdgeInsets.only(top: screenHeight * 0.01),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.star,
//                                 color: Colors.amber,
//                                 size: screenHeight * 0.03,
//                               ),
//                               SizedBox(width: screenWidth * 0.01),
//                               Text(
//                                 '$rating',
//                                 style: TextStyle(
//                                   fontSize: screenHeight * 0.02,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(width: screenWidth * 0.01),
//                               // Text(
//                               //   '($reviews)',
//                               //   style: TextStyle(
//                               //     fontSize: screenHeight * 0.05,
//                               //     color: Colors.grey,
//                               //   ),
//                               // ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:wah_frontend_flutter/services/customer_service.dart';

class DealCard extends StatefulWidget {
  final String imageUrl;
  final String dealTitle;
  final String businessName;
  final double wahPrice;
  final double regularPrice;
  final double discount;
  final bool isTrending;
  final bool? isFavorite;
  final double? rating;
  final int? reviews;
  final String dealId;
  final String customerId;

  const DealCard({
    Key? key,
    required this.imageUrl,
    required this.dealTitle,
    required this.businessName,
    required this.wahPrice,
    required this.regularPrice,
    required this.discount,
    required this.isTrending,
    required this.dealId,
    required this.customerId,
    this.rating,
    this.reviews,
    this.isFavorite,
  }) : super(key: key);

  @override
  _DealCardState createState() => _DealCardState();
}

class _DealCardState extends State<DealCard> {
  late bool _isFavorite;
  final CustomerService _customerService = CustomerService();

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite ?? false;
  }

  Future<void> _toggleFavorite() async {
    try {
      final response = await _customerService.userFavorites(widget.customerId, widget.dealId);
      if (response['data']['message'] == "Favorite added") {
        setState(() {
          _isFavorite = true;
        });
      } else if (response['data']['message'] == "Favorite removed") {
        setState(() {
          _isFavorite = false;
        });
      }
    } catch (e) {
      print("Error toggling favorite: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fixedHeight = screenHeight * 0.18; // Fixed height for card
    final cardWidth = (screenWidth - (screenWidth * 0.12)) / 2;
    final imageHeight = fixedHeight * 0.9;

    return Container(
      width: cardWidth,
      height: screenHeight * 0.1, // Fixed height for card
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section with Heart Icon
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12.0),
                ),
                child: Stack(
                  children: [
                    Image.network(
                      widget.imageUrl,
                      height: imageHeight,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _toggleFavorite,
                        child: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.grey,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Deal Title
                    Text(
                      widget.dealTitle,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),

                    // Business Name
                    Text(
                      widget.businessName,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8.0),

                    // Price and Discount Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${widget.wahPrice}',
                              style: const TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '\$${widget.regularPrice}',
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  '${widget.discount.toInt()}% OFF',
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (widget.rating != null)
                              Padding(
                                padding: EdgeInsets.only(top: screenHeight * 0.01),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: screenHeight * 0.03,
                                    ),
                                    SizedBox(width: screenWidth * 0.01),
                                    Text(
                                      '${widget.rating}',
                                      style: TextStyle(
                                        fontSize: screenHeight * 0.02,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
