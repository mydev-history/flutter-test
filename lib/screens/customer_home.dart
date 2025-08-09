// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wah_frontend_flutter/components/deal_card.dart';
import 'package:wah_frontend_flutter/modals/app_modals/banner_data.dart';
import 'package:wah_frontend_flutter/modals/app_modals/categories_data.dart';
import 'package:wah_frontend_flutter/modals/customer_modals/coupons_data.dart';
import 'package:wah_frontend_flutter/modals/customer_modals/customer_data.dart';
import 'package:wah_frontend_flutter/modals/customer_modals/deals_data.dart';
import 'package:wah_frontend_flutter/providers/app_provider/banner_provider.dart';
import 'package:wah_frontend_flutter/providers/app_provider/categories_provider.dart';
import 'package:wah_frontend_flutter/providers/customer_provider/coupons_provider.dart';
import 'package:wah_frontend_flutter/providers/customer_provider/customer_provider.dart';
import 'package:wah_frontend_flutter/providers/customer_provider/deals_provider.dart';
import 'package:wah_frontend_flutter/screens/customers/deal_details.dart';
import 'package:wah_frontend_flutter/services/app_service.dart';
import 'package:wah_frontend_flutter/services/customer_service.dart';
import 'package:wah_frontend_flutter/components/header.dart';
import 'package:wah_frontend_flutter/components/navbar.dart';

class CustomerHome extends StatefulWidget {
  final String mobilePhone;

  const CustomerHome({required this.mobilePhone, Key? key}) : super(key: key);

  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  final CustomerService _customerService = CustomerService();
  final AppService _appService = AppService();

  final TextEditingController _searchController = TextEditingController();

  bool isLoading = true;
  bool isCategoriesLoading = true;
  bool isBannersLoading = true;
  String? errorMessage;
  String? categoriesErrorMessage;
  String? bannersErrorMessage;
  int _currentIndex = 0;
  int _selectedCategoryIndex = 0;
  bool isDealsLoading = true;
  String? dealsErrorMessage;

   List<DealData> _filteredDeals = [];

  @override
  void initState() {
    super.initState();
    fetchCustomerDetailsAndData();
    // fetchCategories();
    fetchBanners();
    // fetchDeals();
  }

  Future<void> fetchCustomerDetailsAndData() async {
    try {
      // Step 1: Fetch Customer Details
      final details = await _customerService.getCustomerDetails(widget.mobilePhone);
      final customerData = CustomerData.fromJson(details);
      Provider.of<CustomerProvider>(context, listen: false).setCustomerData(customerData);

      // Step 2: Fetch Categories and Deals after Customer Details
      setState(() {
        isCategoriesLoading = true;
        isDealsLoading = true;
      });

      await Future.wait([
        fetchCategories(),
        fetchDeals(),
        fetchCoupons()
      ]);

      setState(() {
        isLoading = false;
        isCategoriesLoading = false;
        isDealsLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> fetchDeals() async {
  try {
    final customerData = Provider.of<CustomerProvider>(context, listen: false).customerData;
    if (customerData == null) throw Exception('Customer data is not available.');

    final zipCode = customerData.zipcode;

    final deals = await _customerService.fetchDeals(zipCode, customerData.customerId);


    final dealList = deals.map((deal) => DealData.fromJson(deal)).toList();

    Provider.of<DealsProvider>(context, listen: false).setDeals(dealList);

    setState(() {
      isDealsLoading = false;
    });
  } catch (e) {
      setState(() {
        dealsErrorMessage = e.toString();
        isDealsLoading = false;
      });
    }
  }

  void _filterDeals(String query) {
  final dealsProvider = Provider.of<DealsProvider>(context, listen: false);
  
  if (query.isEmpty) {
    // Reset to full deal list when search is empty
    fetchDeals();
    return;
  }

  final filteredDeals = dealsProvider.deals.where((deal) {
    final dealTitle = deal.dealTitle.toLowerCase();
    final businessName = deal.businessName?.toLowerCase() ?? '';
    final discount = deal.discountValue.toString();
    final dealId = deal.dealId.toLowerCase();

    return dealTitle.contains(query.toLowerCase()) ||
           businessName.contains(query.toLowerCase()) ||
           discount.contains(query) ||
           dealId.contains(query.toLowerCase());
  }).toList();

  dealsProvider.setDeals(filteredDeals);
}

void _filterDealsByCategory(String categoryId) {
  final dealsProvider = Provider.of<DealsProvider>(context, listen: false);

  if (categoryId == "all") {
    // Show all deals if 'All' category is selected
    fetchDeals();
    return;
  }

  final filteredDeals = dealsProvider.deals.where((deal) {
    return deal.categoryId == categoryId;
  }).toList();

  dealsProvider.setDeals(filteredDeals);
}




  Future<void> fetchCategories() async {
    try {
      final categories = await _appService.fetchCategories();

      final allCategories = [
        CategoryData(categoryId: "all", name: "All", image: null, description: null, status: "Active")
      ] +
          categories.map((category) => CategoryData.fromJson(category)).toList();

      Provider.of<CategoriesProvider>(context, listen: false).setCategories(allCategories);

      setState(() {
        isCategoriesLoading = false;
      });
    } catch (e) {
      setState(() {
        categoriesErrorMessage = e.toString();
        isCategoriesLoading = false;
      });
    }
  }

  Future<void> fetchCoupons() async {
  try {
    final customerData = Provider.of<CustomerProvider>(context, listen: false).customerData;
    if (customerData == null) throw Exception('Customer data is not available.');

    final coupons = await _customerService.fetchCoupons(customerData.customerId);

    final couponList = coupons.map((coupon) => CouponData.fromJson(coupon)).toList();

    Provider.of<CouponsProvider>(context, listen: false).setCoupons(couponList);

    setState(() {
      isLoading = false;
    });
  } catch (e) {
    print("error");
    print(e);
    setState(() {
      errorMessage = e.toString();
      isLoading = false;
    });
  }
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

  void _onNavbarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showSortBottomSheet(BuildContext context) {
  final dealsProvider = Provider.of<DealsProvider>(context, listen: false);

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
              "Sort By",
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 16.0),
            ListView(
              shrinkWrap: true,
              children: [
                _buildSortOption(context, "Price – High to Low", () {
                  _sortDeals(context, "price_high");
                  Navigator.pop(context);
                }),
                _buildSortOption(context, "Price – Low to High", () {
                  _sortDeals(context, "price_low");
                  Navigator.pop(context);
                }),
                // _buildSortOption(context, "Popularity", () {
                //   _sortDeals(context, "popularity");
                //   Navigator.pop(context);
                // }),
                _buildSortOption(context, "Discount", () {
                  _sortDeals(context, "discount");
                  Navigator.pop(context);
                }),
                // _buildSortOption(context, "Liked", () {
                //   _sortDeals(context, "liked");
                //   Navigator.pop(context);
                // }),
                _buildSortOption(context, "Customer Rating", () {
                  _sortDeals(context, "rating");
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

void _sortDeals(BuildContext context, String sortBy) {
  final dealsProvider = Provider.of<DealsProvider>(context, listen: false);

  var deals = dealsProvider.deals;

  switch (sortBy) {
    case "price_high":
      deals.sort((a, b) => b.wahPrice.compareTo(a.wahPrice));
      break;
    case "price_low":
      deals.sort((a, b) => a.wahPrice.compareTo(b.wahPrice));
      break;
    // case "popularity":
    //   deals.sort((a, b) => b.popularity.compareTo(a.popularity)); // Add popularity to DealData if not present
    //   break;
    case "discount":
      deals.sort((a, b) => b.discountValue.compareTo(a.discountValue));
      break;
    // case "liked":
    //   deals = deals.where((deal) => deal.isFavorite ?? false).toList(); // ✅ Filter only liked deals
    //   break;
    case "rating":
      deals.sort((a, b) => (b.totalDealRating ?? 0).compareTo(a.totalDealRating ?? 0));
      break;
    default:
      break;
  }

  dealsProvider.setDeals(deals);
}



  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final customerData = Provider.of<CustomerProvider>(context).customerData;
    final banners = Provider.of<BannerProvider>(context).banners;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Header(
            cityName: "Frisco",
            pageTitle: "Wah!",
            // onNotificationTap: () {
            //   print("Notification tapped");
            // },
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

                      // Greeting Text
                      isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : errorMessage != null
                              ? Center(
                                  child: Text(
                                    errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(color: Colors.red),
                                  ),
                                )
                              : customerData == null
                                  ? const Center(
                                      child: Text("No customer data available"),
                                    )
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Hi, ${customerData.firstName.split(" ")[0] ?? "User"}",
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                        SizedBox(height: screenHeight * 0.01),
                                        Text(
                                          "What are you looking for today?",
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: screenWidth * 0.06),
                                        ),
                                      ],
                                    ),

                      SizedBox(height: screenHeight * 0.03),

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
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: "Search ",
                                  hintStyle: Theme.of(context).textTheme.bodyMedium,
                                  border: InputBorder.none,
                                ),
                                style: Theme.of(context).textTheme.bodyMedium,
                                onChanged: (query) => _filterDeals(query),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),
                    ],
                  ),
                ),

                // Gray Container for Categories and Content
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
                         // Categories Tabs
                          isCategoriesLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                )
                              : categoriesErrorMessage != null
                                  ? Center(
                                      child: Text(
                                        categoriesErrorMessage!,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(color: Colors.red),
                                      ),
                                    )
                                  : Consumer<CategoriesProvider>(
                                      builder: (context, categoriesProvider, child) {
                                        final categories = categoriesProvider.categories;

                                        return SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: List.generate(categories.length, (index) {
                                              final category = categories[index];

                                              return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedCategoryIndex = index;
                                                    _filterDealsByCategory(category.categoryId);
                                                  });
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets.only(right: 12),
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: screenHeight * 0.01,
                                                    horizontal: screenWidth * 0.04,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _selectedCategoryIndex == index
                                                        ? Theme.of(context).colorScheme.primary
                                                        : Colors.transparent,
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: Text(
                                                    category.name,
                                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                          color: _selectedCategoryIndex == index
                                                              ? Theme.of(context).colorScheme.onBackground
                                                              : Theme.of(context).colorScheme.onBackground,
                                                          fontWeight: _selectedCategoryIndex == index
                                                              ? FontWeight.bold
                                                              : FontWeight.normal,
                                                        ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        );
                                      },
                                    ),


                          SizedBox(height: screenHeight * 0.02),

                          // Banners Section
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
                                    height: screenHeight * 0.2, // Adjusted height to match design
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: banners.length,
                                      itemBuilder: (context, index) {
                                        final banner = banners[index];
                                        return Container(
                                          margin: EdgeInsets.only(right: screenWidth * 0.04),
                                          padding: EdgeInsets.all(screenWidth * 0.03),
                                          width: screenWidth * 0.8, // Ensures banner width consistency
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20), // Matches the design
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //     color: Colors.black12,
                                            //     blurRadius: 5,
                                            //     offset: Offset(0, 3),
                                            //   ),
                                            // ],
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Text Section
                                              Expanded(
                                                flex: 2, // Allocates 2/3 of the space to the text
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      banner.title ?? "No Title",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline6 // Larger text for the title
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
                                              SizedBox(width: screenWidth * 0.02), // Space between text and image
                                              // Image Section
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: banner.bannerImageUrl != null
                                                    ? Image.network(
                                                        banner.bannerImageUrl!,
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
                                  
                                // Deals Section
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "",
                                        style: Theme.of(context).textTheme.headline6,
                                      ),
                                      GestureDetector(
                                onTap: () {
                                  _showSortBottomSheet(context);
                                },
                                child: Icon(Icons.filter_alt_outlined, color: Theme.of(context).colorScheme.onBackground),
                              ),
                                    ],
                                  ),
                                ),
                                // SizedBox(height: screenHeight * 0.01),

                                // GridView wrapped in a constrained container
                                Consumer<DealsProvider>(
                          builder: (context, dealsProvider, child) {
                            final deals = dealsProvider.deals;

                            return GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // Two deals per row
                                childAspectRatio: screenWidth / (screenHeight * 0.8), // Responsive aspect ratio
                                crossAxisSpacing: screenWidth * 0.03, // Dynamic spacing
                                mainAxisSpacing: screenHeight * 0.04, // Dynamic spacing
                              ),
                              itemCount: deals.length,
                              itemBuilder: (context, index) {
                                final deal = deals[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DealDetailsPage(deal: deal),
                                      ),
                                    );
                                  },
                                  child: DealCard(
                                    imageUrl: deal.images.first,
                                    dealTitle: deal.dealTitle,
                                    businessName: deal.businessName ?? 'N/A',
                                    wahPrice: deal.wahPrice,
                                    regularPrice: deal.regularPrice,
                                    discount: (deal.discountValue / deal.regularPrice) * 100,
                                    isTrending: deal.isTrending ?? false,
                                    isFavorite: deal.isFavorite,
                                    rating: deal.totalDealRating,
                                    reviews: deal.reviews,
                                    dealId: deal.dealId,
                                    customerId: customerData!.customerId,
                                  ),
                                );
                              },
                            );
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
     bottomNavigationBar: Navbar(
      currentIndex: 0,  // This indicates that "Home" is the active tab
      context: context, 
      ),

    );
  }
}
