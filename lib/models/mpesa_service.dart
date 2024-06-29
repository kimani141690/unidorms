// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class MpesaService {
//   final String consumerKey = 'XLEhPQd986JRSeMtVtbGr9VUPNMWAOVD7hEGt2jxBTxZ9Awc'; // Replace with your actual key
//   final String consumerSecret = 'A0vDbI6E3yLg9JblMhVh5Dv91upyai5m19HycmvCMqq32nRL5Bqx62tgaVHdHHcG'; // Replace with your actual secret
//   final String lipaNaMpesaOnlineUrl = 'https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest';
//   final String accessTokenUrl = 'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials';
//   final String callbackUrlBase = 'https://your-callback-url.com/mpesa/callback';
//   final String businessShortCode = '174379'; // Use sandbox shortcode
//   final String lnmPasskey = 'bfb279f9aa9bdbcf158e97dd71a467cd2c2ee31c4f6e509b5e339e31f22ebdbb'; // Sandbox passkey
//
//   Future<String> cgetAccessToken() async {
//     try {
//       String credentials = base64Encode(utf8.encode('$consumerKey:$consumerSecret'));
//       var response = await http.get(
//         Uri.parse(accessTokenUrl),
//         headers: {
//           'Authorization': 'Basic $credentials',
//         },
//       );
//       if (response.statusCode == 200) {
//         var jsonResponse = json.decode(response.body);
//         return jsonResponse['access_token'];
//       } else {
//         throw Exception('Failed to obtain access token');
//       }
//     } catch (e) {
//       print("Error getting access token: $e");
//       rethrow;
//     }
//   }
//
//   String getTimestamp() {
//     var now = DateTime.now();
//     return now.year.toString() +
//         now.month.toString().padLeft(2, '0') +
//         now.day.toString().padLeft(2, '0') +
//         now.hour.toString().padLeft(2, '0') +
//         now.minute.toString().padLeft(2, '0') +
//         now.second.toString().padLeft(2, '0');
//   }
//
//   Future<void> initiatePayment(String phoneNumber, double amount, String bookingId) async {
//     try {
//       String accessToken = await getAccessToken();
//       String timestamp = getTimestamp();
//       String password = base64Encode(utf8.encode('$businessShortCode$lnmPasskey$timestamp'));
//
//       var response = await http.post(
//         Uri.parse(lipaNaMpesaOnlineUrl),
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'BusinessShortCode': 174379,
//           'Password': password,
//           'Timestamp': timestamp,
//           'TransactionType': 'CustomerPayBillOnline',
//           'Amount': amount,
//           'PartyA': phoneNumber,
//           'PartyB': 174379,
//           'PhoneNumber': phoneNumber,
//           'CallBackURL': '$callbackUrlBase/$bookingId', // Include bookingId in callback URL
//           'AccountReference': 'default',
//           'TransactionDesc': 'Unidorms booking payment',
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         print('Payment initiated successfully');
//       } else {
//         var jsonResponse = json.decode(response.body);
//         print('Failed to initiate payment: ${jsonResponse['errorMessage']}');
//         throw Exception('Failed to initiate payment: ${jsonResponse['errorMessage']}');
//       }
//     } catch (e) {
//       print("Error initiating payment: $e");
//       rethrow;
//     }
//   }
// }
