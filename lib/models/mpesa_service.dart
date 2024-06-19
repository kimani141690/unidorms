import 'dart:convert';
import 'package:http/http.dart' as http;

class MpesaService {
  final String consumerKey = 'XLEhPQd986JRSeMtVtbGr9VUPNMWAOVD7hEGt2jxBTxZ9Awc'; // Replace with your actual key
  final String consumerSecret = 'A0vDbI6E3yLg9JblMhVh5Dv91upyai5m19HycmvCMqq32nRL5Bqx62tgaVHdHHcG'; // Replace with your actual secret
  final String securityCredential = 'FUA3i1vs0S7y5y7icw6WBSDtOxv/1cvLMxEGr9PKTKoPnRqsSmzU18DWplHe24sIrjPU1xu4wesxaAlsYZaeq7xgNOfcPcglOdY12AU0bPEEaEbyLqiB0n9l+QFZZaFddV4iocpt+RCkaJbs3ppCBiuRoHEFcpvTqPyAlkXuWCWhYDNs6aJVhmzIj23FloLlRezpKEBkrE37IWMP8qNOLbnSSFW/ZZQ3u4WkAvpi66pMP41FPzHXabU+R+pmKdeT+cDN1CqTPn9A5RyZHOjw//8fKJjAVzZTHBNrspZCEoC0V+SAfaGUBSDvJOWpzHJW3P6cXbwcmOTwZ1ByShn56Q==';
  final String lipaNaMpesaOnlineUrl = 'https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest';
  final String accessTokenUrl = 'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials';
  final String callbackUrl = 'https://your-callback-url.com/mpesa/callback';

  Future<String> getAccessToken() async {
    String credentials = base64Encode(utf8.encode('$consumerKey:$consumerSecret'));
    var response = await http.get(
      Uri.parse(accessTokenUrl),
      headers: {
        'Authorization': 'Basic $credentials',
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return jsonResponse['access_token'];
    } else {
      throw Exception('Failed to obtain access token');
    }
  }

  Future<void> initiatePayment(String phoneNumber, double amount) async {
    String accessToken = await getAccessToken();
    String timestamp = DateTime.now().toString().replaceAll(RegExp(r'[^0-9]'), '');
    String password = base64Encode(utf8.encode('174379' + 'YOUR_LNM_PASSKEY' + timestamp)); // Replace '174379' with the sandbox shortcode

    var response = await http.post(
      Uri.parse(lipaNaMpesaOnlineUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'BusinessShortCode': '174379', // Use sandbox shortcode
        'Password': password,
        'Timestamp': timestamp,
        'TransactionType': 'CustomerPayBillOnline',
        'Amount': amount,
        'PartyA': phoneNumber,
        'PartyB': '174379', // Use sandbox shortcode
        'PhoneNumber': phoneNumber,
        'CallBackURL': callbackUrl,
        'AccountReference': 'YOUR_ACCOUNT_REFERENCE',
        'TransactionDesc': 'Payment description',
        'SecurityCredential': securityCredential,
      }),
    );

    if (response.statusCode == 200) {
      print('Payment initiated successfully');
    } else {
      print('Failed to initiate payment');
    }
  }
}
