import 'package:http/http.dart' as http;
import '../../models/dispute.dart';

class DisputeService {
  final http.Client _client;

  DisputeService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Dispute>> getDisputesList() async {
    return [];
  }
}