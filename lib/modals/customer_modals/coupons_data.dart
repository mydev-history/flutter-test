import 'package:wah_frontend_flutter/modals/customer_modals/deals_data.dart';

class CouponData {
  final String couponId;
  final String qrCode;
  final String dealId;
  final String status;
  final String createdAt;
  DealData? dealDetails;

  CouponData({
    required this.couponId,
    required this.qrCode,
    required this.dealId,
    required this.status,
    required this.createdAt,
    this.dealDetails,
  });

  factory CouponData.fromJson(Map<String, dynamic> json) {
    return CouponData(
      couponId: json['coupon_id'],
      qrCode: json['qr_code'],
      dealId: json['deal_id'],
      status: json['status'],
      createdAt: json['created_at'],
      dealDetails: json.containsKey('deal_details') && json['deal_details'] != null
          ? DealData.fromJson(json['deal_details']) // ✅ Handle null case
          : null,
    );
  }
}
