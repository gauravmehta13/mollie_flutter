import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mollie_flutter/src/mollieaddress.dart';
import 'package:mollie_flutter/src/mollieorder.dart';
import 'package:mollie_flutter/src/mollieorderline.dart';

class OrderHandler {
  final String _apiEndpoint = "https://api.mollie.com/v2/orders";

  Map<String, String>? _headers;

  OrderHandler(Map<String, String>? headers) {
    _headers = headers;
  }

  /// Creating an order will automatically create the required payment to allow your customer to pay for the order.
  /// Once you have created an order, you should redirect your customer to the URL in the _links.checkout property from the response.
  /// Note that when the payment fails, expires or is canceled, you can create a new payment using the Create order payment API. This is only possible for orders that have a created status.
  Future<MollieOrderResponse?> create(MollieOrderRequest order) async {
    var res = await http.post(Uri.parse(_apiEndpoint), headers: _headers, body: order.toJson());
    if (res.statusCode == 200 || res.statusCode == 201) {
      dynamic data = json.decode(res.body);
      return MollieOrderResponse.build(data);
    }

    throw Exception("Error creating order ${res.statusCode} ${res.body}");
  }

  /// List all orders
  Future<List<MollieOrderResponse>> listOrders() async {
    List<MollieOrderResponse> orders = [];

    var res = await http.get(
      Uri.parse(_apiEndpoint),
      headers: _headers,
    );

    dynamic data = json.decode(res.body);

    for (int i = 0; i < data["count"]; i++) {
      var order = data["_embedded"]["orders"][i];

      orders.add(MollieOrderResponse.build(order));
    }

    return orders;
  }

  /// Retrieve a single order by its ID.
  Future<MollieOrderResponse?> get(String orderId) async {
    var res = await http.get(
      Uri.parse("$_apiEndpoint/$orderId"),
      headers: _headers,
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      dynamic data = json.decode(res.body);
      return MollieOrderResponse.build(data);
    } else {
      throw Exception("Error getting order ${res.statusCode} ${res.body}");
    }
  }

  /// Cancels an order
  Future<MollieOrderResponse> cancel(String orderId) async {
    var res = await http.delete(
      Uri.parse("$_apiEndpoint/$orderId"),
      headers: _headers,
    );

    return MollieOrderResponse.build(json.decode(res.body));
  }

  /// This endpoint can be used to update the billing and/or shipping address of an order.
  Future<MollieOrderResponse> update(
      String orderId, MollieAddress billingAddress, MollieAddress shippingAddress) async {
    Map data = {"billingAddress": billingAddress.toMap(), "shippingAddress": shippingAddress.toMap()};

    dynamic body = json.encode(data);

    var res = await http.patch(Uri.parse("$_apiEndpoint/$orderId"), headers: _headers, body: body);

    return MollieOrderResponse.build(json.decode(res.body));
  }

  /// This endpoint can be used to update an order line. Only the lines that belong to an order with status created, pending or authorized can be updated.
  Future<MollieOrderResponse> updateOrderLine(MollieOrderLine orderLine) async {
    var res = await http.patch(
        Uri.parse(
          "$_apiEndpoint/${orderLine.orderId!}/lines/${orderLine.orderLineId!}",
        ),
        headers: _headers,
        body: orderLine.toJson());

    return MollieOrderResponse.build(json.decode(res.body));
  }
}
