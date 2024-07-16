import 'dart:convert';
import 'package:http/http.dart' as http;

class MpesaService {
  final String consumerKey = 'HbRGaUBppEzXgYHTOISrBs5eTG9yMEK0lZz11A90DH7vGNqZ';
  final String consumerSecret = 'd7W3i5BazVM8pdtDto6B6jjTXuIUYPLRdZjpu5m2aYTAhy7aPg63pAhyn4pAZsqU';
  final String shortCode = '174379';
  final String passkey = 'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919';
  final String lipaNaMpesaOnlineUrl = 'https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest';
  final String authUrl = 'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials';
  final String queryUrl = 'https://sandbox.safaricom.co.ke/mpesa/stkpushquery/v1/query';
  final String callbackurl ='https://mydomain.com/path';
  Future<String> getAccessToken() async {
    String credentials = base64Encode(utf8.encode('$consumerKey:$consumerSecret'));
    final response = await http.get(
      Uri.parse(authUrl),
      headers: {
        'Authorization': 'Basic $credentials',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      print('Access token obtained: ${body['access_token']}');
      return body['access_token'];
    } else {
      print('Failed to obtain access token. Status code: ${response.statusCode}, Response body: ${response.body}');
      throw Exception('Failed to obtain access token');
    }
  }

  Future<void> initiatePayment(String phoneNumber, double amount, String bookingId) async {
    String accessToken = await getAccessToken();
    final timestamp = _getFormattedTimestamp();
    final password = base64Encode(utf8.encode('$shortCode$passkey$timestamp'));
    print(phoneNumber);

    final response = await http.post(
      Uri.parse(lipaNaMpesaOnlineUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'BusinessShortCode': shortCode,
        'Password': password,
        'Timestamp': timestamp,
        'TransactionType': 'CustomerPayBillOnline',
        'Amount': amount,
        'PartyA': phoneNumber,
        'PartyB': shortCode,
        'PhoneNumber': phoneNumber,
        'CallBackURL':callbackurl,
        'AccountReference': bookingId,
        'TransactionDesc': 'Unidorms Rent Payment for booking',

      }),
    );

    if (response.statusCode == 200) {
      print('Payment initiated successfully. Response body: ${response.body}');
    } else {
      print('Failed to initiate payment. Status code: ${response.statusCode}, Response body: ${response.body}');
      throw Exception('Failed to initiate payment');
    }
  }

  Future<Map<String, dynamic>> queryPaymentStatus(String checkoutRequestId) async {
    String accessToken = await getAccessToken();
    final timestamp = _getFormattedTimestamp();
    final password = base64Encode(utf8.encode('$shortCode$passkey$timestamp'));

    final response = await http.post(
      Uri.parse(queryUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'BusinessShortCode': shortCode,
        'Password': password,
        'Timestamp': timestamp,
        'CheckoutRequestID': checkoutRequestId,
      }),
    );

    if (response.statusCode == 200) {
      print('Payment status queried successfully. Response body: ${response.body}');
      return jsonDecode(response.body);
    } else {
      print('Failed to query payment status. Status code: ${response.statusCode}, Response body: ${response.body}');
      throw Exception('Failed to query payment status');
    }
  }

  String _getFormattedTimestamp() {
    final DateTime now = DateTime.now().toUtc();
    return '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}';
  }

  String _twoDigits(int n) {
    return n >= 10 ? "$n" : "0$n";
  }
}
