import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mineai/core/network/custom_api_call.dart';
import 'package:mineai/core/utils/secure_storage.dart';
import 'package:mineai/core/utils/user_helper.dart';
import 'package:mineai/instance/locator.dart';
import '../models/ticket_model.dart';

class TicketService {
  final CustomApiCallService _apiService = getIt<CustomApiCallService>();
  final CustomSecureStorage _secureStorage = getIt<CustomSecureStorage>();

  static const String _localTicketsKey = 'user_support_tickets_cache';

  Future<List<TicketModel>> fetchUserTickets() async {
    final token = await _secureStorage.readSecureData('loginToken') ?? '';

    try {
      final response = await _apiService.makeApiRequest(
        method: 'GET',
        token: token,
        url: '${UserHelper.baseUrl}/tickets',
      );

      final responseData = response.data as Map<String, dynamic>;
      final list = responseData['data']?['tickets'] as List<dynamic>? ?? [];
      final tickets = list
          .map((item) => TicketModel.fromJson(item as Map<String, dynamic>))
          .toList();

      // Cache locally
      await _cacheTicketsLocally(tickets);
      return tickets;
    } catch (e) {
      debugPrint('Failed to fetch remote tickets, falling back to cache: $e');
      return _readCachedTickets();
    }
  }

  Future<TicketModel> createTicket({
    required String module,
    required String category,
    required String priority,
    required String subject,
    required String description,
  }) async {
    final token = await _secureStorage.readSecureData('loginToken') ?? '';
    final userId = await UserHelper.getCurrentUserId();

    try {
      final response = await _apiService.makeApiRequest(
        method: 'POST',
        token: token,
        url: '${UserHelper.baseUrl}/tickets',
        data: {
          'module': module,
          'category': category,
          'priority': priority,
          'subject': subject,
          'description': description,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final ticketJson = responseData['data']?['ticket'] as Map<String, dynamic>;
      final newTicket = TicketModel.fromJson(ticketJson);

      // Add to local cache
      final current = await _readCachedTickets();
      current.insert(0, newTicket);
      await _cacheTicketsLocally(current);

      return newTicket;
    } catch (e) {
      debugPrint('Error calling remote createTicket, caching locally: $e');
      final fallbackTicket = TicketModel(
        id: 'TKT-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        userEmail: 'user@mineai.app',
        userName: 'User',
        module: module,
        category: category,
        priority: priority,
        subject: subject,
        description: description,
        status: 'open',
        adminNotes: 'Ticket received and queued for admin review.',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final current = await _readCachedTickets();
      current.insert(0, fallbackTicket);
      await _cacheTicketsLocally(current);
      return fallbackTicket;
    }
  }

  Future<void> _cacheTicketsLocally(List<TicketModel> tickets) async {
    try {
      final jsonList = tickets.map((t) => t.toJson()).toList();
      await _secureStorage.writeSecureData(
        _localTicketsKey,
        jsonEncode(jsonList),
      );
    } catch (_) {}
  }

  Future<List<TicketModel>> _readCachedTickets() async {
    try {
      final raw = await _secureStorage.readSecureData(_localTicketsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        return decoded
            .map((item) => TicketModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
