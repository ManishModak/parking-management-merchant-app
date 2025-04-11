import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService {
  static const String baseUrl = 'YOUR_BACKEND_URL'; // e.g., 'https://your-backend.com'

  Future<Map<String, dynamic>> generateUpiQrCode(String ticketId, double amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/generate-upi-qr'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ticketId': ticketId, 'amount': amount}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate QR code: ${response.body}');
    }
  }
}