// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wah_frontend_flutter/components/vendor_header.dart';
import 'package:wah_frontend_flutter/components/vendor_navbar.dart';
import 'package:wah_frontend_flutter/config/theme.dart';
import 'package:wah_frontend_flutter/modals/app_modals/banner_data.dart';
import 'package:wah_frontend_flutter/modals/vendors_modals/vendor_data.dart';
import 'package:wah_frontend_flutter/modals/vendors_modals/vendor_deal.dart';
import 'package:wah_frontend_flutter/providers/app_provider/banner_provider.dart';
import 'package:wah_frontend_flutter/providers/vendors_provider/vendor_provider.dart';
import 'package:wah_frontend_flutter/screens/vendors/add_deal.dart';
import 'package:wah_frontend_flutter/screens/vendors/vendor_deal_details.dart';
import 'package:wah_frontend_flutter/services/app_service.dart';
import 'package:wah_frontend_flutter/services/vendor_service.dart';

class VendorHome extends StatefulWidget {
  final String mobilePhone;

  const VendorHome({required this.mobilePhone, Key? key}) : super(key: key);

  @override
  _VendorHomeState createState() => _VendorHomeState();
}

class _VendorHomeState extends State<VendorHome> {
  final VendorService _vendorService = VendorService();
  final AppService _appService = AppService();

  final TextEditingController _searchController = TextEditingController();
  
  bool isLoading = true;
  bool isBannersLoading = true;
  String? bannersErrorMessage;
  List<VendorDeal> vendorDeals = [];

  List<VendorDeal> _filteredDeals = [];

  @override
  void initState() {
    super.initState();
    fetchVendorDetailsAndDeals(); // ✅ Fetch vendor details when the screen loads
    fetchBanners();
  }

  /// ✅ Combined function to fetch vendor details first, then vendor deals
Future<void> fetchVendorDetailsAndDeals() async {
  try {
    final vendorData = await _vendorService.getVendorDetails(widget.mobilePhone);
    Provider.of<VendorProvider>(context, listen: false).setVendorData(VendorData.fromJson(vendorData));

    // ✅ Fetch vendor deals after vendor details are fetched
    await fetchVendorDeals(vendorData["vendor"]["vendor_id"]); // Use vendor_id from API response
  } catch (e) {
    print("Error fetching vendor details: $e");
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

  /// ✅ Fetch vendor deals (also sets `_filteredDeals` initially)
  Future<void> fetchVendorDeals(String vendorId) async {
    try {
      final deals = await _vendorService.fetchVendorDeals(vendorId);
      setState(() {
        vendorDeals = deals;
        _filteredDeals = List.from(deals); // ✅ Set filtered deals initially
      });
    } catch (e) {
      print("Error fetching vendor deals: $e");
    }
  }

  /// ✅ Filter deals based on search query
  void _filterDeals(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDeals = List.from(vendorDeals);
      } else {
        _filteredDeals = vendorDeals.where((deal) {
          final dealTitle = deal.dealTitle.toLowerCase();
          final dealStatus = deal.dealStatus.toLowerCase();
          final dealId = deal.dealId.toLowerCase();
          final queryLower = query.toLowerCase();

          // ✅ Convert numbers to string for search
          final wahPrice = deal.wahPrice.toString();
          final discountValue = deal.discountValue.toString();

          return dealTitle.contains(queryLower) ||
                 dealStatus.contains(queryLower) ||
                 dealId.contains(queryLower) ||
                 wahPrice.contains(queryLower) ||
                 discountValue.contains(queryLower);
        }).toList();
      }
    });
  }


  Future<void> fetchBanners() async {
    try {
      final banners = await _appService.fetchBanners("customers");

      final bannerList = banners.map((banner) => BannerData.fromJson(banner)).toList();

      Provider.of<BannerProvider>(context, listen: false).setBanners(bannerList);

      setState(() {
        isBannersLoading = false;
      });
    } catch (e) {
      setState(() {
        bannersErrorMessage = e.toString();
        isBannersLoading = false;
      });
    }
  }

  void _filterByStatus(String status) {
  setState(() {
    if (status == "All") {
      _filteredDeals = List.from(vendorDeals); // Show all deals
    } else {
      _filteredDeals = vendorDeals.where((deal) {
        return deal.dealStatus.toLowerCase() == status.toLowerCase();
      }).toList();
    }
  });
}
  
  void _showSortBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Filter Deals By Status",
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 16.0),
            ListView(
              shrinkWrap: true,
              children: [
                _buildSortOption(context, "All", () {
                  _filterByStatus("All"); // ✅ Show all deals
                  Navigator.pop(context);
                }),
                _buildSortOption(context, "Active", () {
                  _filterByStatus("Active"); // ✅ Show only active deals
                  Navigator.pop(context);
                }),
                _buildSortOption(context, "Inactive", () {
                  _filterByStatus("Inactive"); // ✅ Show only inactive deals
                  Navigator.pop(context);
                }),
                _buildSortOption(context, "Under Review", () {
                  _filterByStatus("Under Review"); // ✅ Show under review deals
                  Navigator.pop(context);
                }),
                _buildSortOption(context, "Paused", () {
                  _filterByStatus("Paused"); // ✅ Show paused deals
                  Navigator.pop(context);
                }),
              ],
            ),
          ],
        ),
      );
    },
  );
}


Widget _buildSortOption(BuildContext context, String title, VoidCallback onTap) {
  return ListTile(
    title: Text(title, style: Theme.of(context).textTheme.bodyText1),
    onTap: onTap,
  );
}

  @override
Widget build(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  final vendorData = Provider.of<VendorProvider>(context).vendorData;
  final banners = Provider.of<BannerProvider>(context).banners;

  return Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: Column(
      children: [
        // ✅ Vendor Header with dynamic business name
        VendorHeader(
          businessName: vendorData?.businessName ?? "Loading...",
          onNotificationTap: () {},
        ),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.03),

                    // ✅ Vendor Performance Section
                    Text(
                      "Wah! Performance",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.normal,
                            fontSize: screenWidth * 0.05,
                          ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildPerformanceCard("Deals", vendorData?.totalDeals.toString() ?? "0", "assets/deals.png"),
                              _buildPerformanceCard("Published", vendorData?.totalPublishedCoupons.toString() ?? "0", "assets/published.png"),
                              _buildPerformanceCard("Redeemed", vendorData?.totalRedeemedCoupons.toString() ?? "0", "assets/published.png"),
                              _buildPerformanceCard("Revenue", "\$${vendorData?.totalRevenueGenerated.toStringAsFixed(2) ?? "0"}", "assets/revenue.png"),
                            ],
                          ),

                    SizedBox(height: screenHeight * 0.03),

                    // ✅ Search Bar
                    Container(
                      height: screenHeight * 0.05,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(
                              Icons.search,
                              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Search",
                                hintStyle: Theme.of(context).textTheme.bodyMedium,
                                border: InputBorder.none,
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                              onChanged: (query) {
                                _filterDeals(query);  // ✅ Ensure filtering happens on every keystroke
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),

              // ✅ Gray Background Container
              Expanded(
                child: Container(
                  width: screenWidth,
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  decoration: BoxDecoration(
                    color: Colors.black12.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ Banners Section
                        isBannersLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                            : bannersErrorMessage != null
                                ? Center(
                                    child: Text(
                                      bannersErrorMessage!,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: Colors.red),
                                    ),
                                  )
                                : SizedBox(
                                    height: screenHeight * 0.2,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: banners.length,
                                      itemBuilder: (context, index) {
                                        final banner = banners[index];
                                        return Container(
                                          margin: EdgeInsets.only(right: screenWidth * 0.04),
                                          padding: EdgeInsets.all(screenWidth * 0.03),
                                          width: screenWidth * 0.8,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Text Section
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      banner.title,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline6
                                                          ?.copyWith(fontWeight: FontWeight.bold),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(height: screenHeight * 0.01),
                                                    Text(
                                                      "${banner.type} →",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle1
                                                          ?.copyWith(
                                                            color: Theme.of(context).colorScheme.primary,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: screenWidth * 0.02),
                                              // Image Section
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: banner.bannerImageUrl != null
                                                    ? Image.network(
                                                        banner.bannerImageUrl,
                                                        height: screenHeight * 0.15,
                                                        width: screenWidth * 0.25,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Container(
                                                        height: screenHeight * 0.15,
                                                        width: screenWidth * 0.25,
                                                        color: Colors.grey[300],
                                                        child: Icon(Icons.image_not_supported),
                                                      ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                        SizedBox(height: screenHeight * 0.02),

                        // ✅ Add Deal & Filter Section
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // ✅ Wrap with GestureDetector to navigate to AddDeal
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddDeal(vendorId: vendorData!.vendorId),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Image.asset(
                                      "assets/addDeal.png",
                                      width: screenWidth * 0.05,
                                      height: screenHeight * 0.05,
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    Text(
                                      "Add Deal",
                                      style: Theme.of(context).textTheme.headline6,
                                    ),
                                  ],
                                ),
                              ),
                              
                              // ✅ Filter Icon
                              GestureDetector(
                                onTap: () {
                                  _showSortBottomSheet(context);
                                },
                                child: Icon(
                                  Icons.filter_alt_outlined,
                                  color: Theme.of(context).colorScheme.onBackground,
                                ),
                              ),
                            ],
                          ),
                        ),


                        SizedBox(height: screenHeight * 0.02),

                        // ✅ Vendor Deals Section (Two Per Row)
                       _filteredDeals.isEmpty
                          ? Center(child: Text("No Deals Available"))
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // Two deals per row
                                  childAspectRatio: screenWidth / (screenHeight * 0.8), // Responsive aspect ratio
                                  crossAxisSpacing: screenWidth * 0.03, // Dynamic spacing
                                  mainAxisSpacing: screenHeight * 0.04, // Dynamic spacing
                              ),
                              itemCount: _filteredDeals.length,  // ✅ Display only filtered deals
                              itemBuilder: (context, index) {
                                  return _buildDealCard(_filteredDeals[index]);  // ✅ Use filtered list
                              },
                          ),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    bottomNavigationBar: VendorNavbar(currentIndex: 0, context: context),
  );
}


Widget _buildDealCard(VendorDeal deal) {
  final vendorData = Provider.of<VendorProvider>(context, listen: false).vendorData;
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  Color statusColor;
  String statusText;

  print(deal.dealStatus);

  switch (deal.dealStatus.toLowerCase()) {
    case "active":
      statusColor = Colors.green;
      statusText = "Active";
      break;
    case "inactive":
      statusColor = Colors.red;
      statusText = "Inactive";
      break;
    case "paused":
      statusColor = Colors.orange;
      statusText = "Paused";
      break;
    case "under_review":
      statusColor = Colors.orange;
      statusText = "Under Review";
      break;
    default:
      statusColor = Colors.grey;
      statusText = "Unknown";
  }

  bool isInactive = deal.dealStatus.toLowerCase() == "inactive";

  return GestureDetector(
    onTap: () {
      // ✅ Navigate to VendorDealDetails page with dealId
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VendorDealDetails(dealId: deal.dealId),
        ),
      );
    },
    child: Container(
      width: screenWidth * 0.44, // Ensuring responsiveness
      decoration: BoxDecoration(
        color: isInactive ? Colors.grey[300] : Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
      ),
      child: Stack(
        children: [
          // ✅ Deal Image with Gray Overlay for Inactive
          ClipRRect(
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
            child: Stack(
              children: [
                Image.network(
                  deal.dealImages.first,
                  height: screenHeight * 0.25,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                if (isInactive)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.4), // Dark overlay
                    ),
                  ),
              ],
            ),
          ),

          // ✅ Status Banner
          Positioned(
            top: screenHeight * 0.01,
            left: screenWidth * 0.02,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenHeight * 0.005),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
              child: Text(
                statusText,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ✅ Deal Details Section
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.01),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(screenWidth * 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Deal Title
                  Text(
                    deal.dealTitle,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isInactive ? Colors.grey : Colors.black,
                      fontSize: screenWidth * 0.035,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: screenHeight * 0.005),

                  // ✅ Business Name
                  Text(
                    vendorData?.businessName ?? "Unknown Vendor",
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isInactive ? Colors.grey[600] : Colors.black54,
                      fontSize: screenWidth * 0.03,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: screenHeight * 0.01),

                  // ✅ Pricing Row
                  Row(
                    children: [
                      Text(
                        "\$${deal.wahPrice}",
                        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isInactive ? Colors.grey : Colors.black,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        "\$${deal.regularPrice}",
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: screenWidth * 0.03,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        "${deal.discountValue}% OFF",
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          fontSize: screenWidth * 0.03,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.008),
                  //   //                 // ✅ Ratings & Reviews (Only if available)
                  // if (deal.rating != null && deal.reviewCount != null) ...[
                  //   Row(
                  //     children: [
                  //       Icon(Icons.star, color: Colors.orange, size: screenWidth * 0.04),
                  //       SizedBox(width: screenWidth * 0.01),
                  //       Text(
                  //         deal.rating.toString(),
                  //         style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  //           fontWeight: FontWeight.bold,
                  //           color: isInactive ? Colors.grey : Colors.black,
                  //         ),
                  //       ),
                  //       SizedBox(width: screenWidth * 0.01),
                  //       Text(
                  //         "(${deal.reviewCount})",
                  //         style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  //           fontWeight: FontWeight.w500,
                  //           color: isInactive ? Colors.grey : Colors.black54,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}




  /// ✅ Performance Card Widget (for "Deals", "Published", "Redeemed", "Revenue")
  Widget _buildPerformanceCard(String title, String value, String assetPath) {
    return Column(
      children: [
        Image.asset(assetPath, width: 40, height: 40),
        SizedBox(height: 4),
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
