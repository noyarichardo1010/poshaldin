import 'dart:convert';

// Fungsi helper untuk menjalankan decode
ReceiptData receiptDataFromJson(String str) =>
    ReceiptData.fromJson(json.decode(str));

// 1. Model Utama
class ReceiptData {
  String header;
  String subHeader;
  ReceiptDetails details;
  List<ReceiptItem> items;
  ReceiptTotals totals;
  ReceiptFooter footer;

  ReceiptData({
    required this.header,
    required this.subHeader,
    required this.details,
    required this.items,
    required this.totals,
    required this.footer,
  });

  factory ReceiptData.fromJson(Map<String, dynamic> json) => ReceiptData(
    header: json["header"],
    subHeader: json["sub_header"],
    details: ReceiptDetails.fromJson(json["details"]),
    items: List<ReceiptItem>.from(
      json["items"].map((x) => ReceiptItem.fromJson(x)),
    ),
    totals: ReceiptTotals.fromJson(json["totals"]),
    footer: ReceiptFooter.fromJson(json["footer"]),
  );
}

// 2. Model Detail
class ReceiptDetails {
  String date;
  String time;
  String location;
  String billNo;

  ReceiptDetails({
    required this.date,
    required this.time,
    required this.location,
    required this.billNo,
  });

  factory ReceiptDetails.fromJson(Map<String, dynamic> json) => ReceiptDetails(
    date: json["date"],
    time: json["time"],
    location: json["location"],
    billNo: json["bill_no"],
  );
}

// 3. Model Footer
class ReceiptFooter {
  String paymentMethod;
  String thankYouNote;

  ReceiptFooter({required this.paymentMethod, required this.thankYouNote});

  factory ReceiptFooter.fromJson(Map<String, dynamic> json) => ReceiptFooter(
    paymentMethod: json["payment_method"],
    thankYouNote: json["thank_you_note"],
  );
}

// 4. Model Item (Produk)
class ReceiptItem {
  String name;
  String quantityStr;
  double quantityRaw;
  String priceFormatted;
  String subtotalFormatted;

  ReceiptItem({
    required this.name,
    required this.quantityStr,
    required this.quantityRaw,
    required this.priceFormatted,
    required this.subtotalFormatted,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) => ReceiptItem(
    name: json["name"],
    quantityStr: json["quantity_str"],
    quantityRaw: (json["quantity_raw"] as num).toDouble(),
    priceFormatted: json["price_formatted"],
    subtotalFormatted: json["subtotal_formatted"],
  );
}

// 5. Model Total
class ReceiptTotals {
  String subtotal;
  String discount;
  String gratuity;
  String tax;
  String grandTotal;

  ReceiptTotals({
    required this.subtotal,
    required this.discount,
    required this.gratuity,
    required this.tax,
    required this.grandTotal,
  });

  factory ReceiptTotals.fromJson(Map<String, dynamic> json) => ReceiptTotals(
    subtotal: json["subtotal"],
    discount: json["discount"],
    gratuity: json["gratuity"],
    tax: json["tax"],
    grandTotal: json["grand_total"],
  );
}
