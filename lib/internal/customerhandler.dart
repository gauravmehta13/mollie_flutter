import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mollie_flutter/src/molliecustomer.dart';

class CustomerHandler {
  Map<String, String>? _headers;

  final String _apiEndpoint = "https://api.mollie.com/v2/customers";

  CustomerHandler(Map<String, String>? headers) {
    _headers = headers;
  }

  /// Creates a simple minimal representation of a customer in the
  /// Mollie API to use for the Mollie Checkout and Recurring features.
  /// These customers will appear in your Mollie Dashboard where you can manage their details,
  /// and also see their payments and subscriptions.
  Future<MollieCustomer?> create(String name, String email) async {
    Map data = {"name": name, "email": email};

    dynamic body = json.encode(data);

    var res = await http.post(Uri.parse(_apiEndpoint), headers: _headers, body: body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      dynamic data = json.decode(res.body);
      return MollieCustomer.build(data);
    } else {
      throw Exception("Error creating customer ${res.statusCode} ${res.body}");
    }
  }

  /// Retrieve a single customer by its ID.
  Future<MollieCustomer?> get(String customerId) async {
    var res = await http.get(
      Uri.parse("$_apiEndpoint/$customerId"),
      headers: _headers,
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      dynamic data = json.decode(res.body);
      return MollieCustomer.build(data);
    } else {
      throw Exception("Error getting customer ${res.statusCode} ${res.body}");
    }
  }

  /// Update an existing customer.
  Future<MollieCustomer?> update(String customerId, String name, String email) async {
    Map data = {"name": name, "email": email};

    dynamic body = json.encode(data);

    var res = await http.patch(Uri.parse("$_apiEndpoint/$customerId"), headers: _headers, body: body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      dynamic data = json.decode(res.body);
      return MollieCustomer.build(data);
    } else {
      throw Exception("Error updating customer ${res.statusCode} ${res.body}");
    }
  }

  /// Delete a customer. All mandates and subscriptions created for this customer will be canceled as well.
  Future<String> delete(String customerId) async {
    await http.delete(
      Uri.parse("$_apiEndpoint/$customerId"),
      headers: _headers,
    );

    return "Customer ${customerId}was deleted successfully";
  }

  /// Retrieve all customers created.
  Future<List<MollieCustomer>> listCustomers() async {
    List<MollieCustomer> customers = [];

    var res = await http.get(
      Uri.parse(_apiEndpoint),
      headers: _headers,
    );

    dynamic data = json.decode(res.body);

    for (int i = 0; i < data["count"]; i++) {
      var customer = data["_embedded"]["customers"][i];

      customers.add(MollieCustomer.build(customer));
    }

    return customers;
  }
}
