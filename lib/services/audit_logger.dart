import 'package:drift/drift.dart' show Value;
import '../data/local/database.dart';
import '../data/local/database_provider.dart';

/// Audit log helper — records all significant events
class AuditLogger {
  final AppDatabase _db;
  AuditLogger(this._db);

  Future<void> log(String eventType, {String? ticketId, String? operatorId, Map<String, dynamic>? payload}) async {
    String? payloadJson;
    if (payload != null) {
      // Simple JSON serialization without dart:convert dependency issues
      final entries = payload.entries.map((e) => '"${e.key}":"${e.value}"').join(',');
      payloadJson = '{$entries}';
    }
    await _db.insertAuditEvent(AuditEventsCompanion(
      eventType: Value(eventType),
      ticketId: ticketId == null ? const Value.absent() : Value(ticketId),
      operatorId: operatorId == null ? const Value.absent() : Value(operatorId),
      payloadJson: payloadJson == null ? const Value.absent() : Value(payloadJson),
    ));
  }

  Future<void> ticketCreated(String ticketId, int number) =>
    log(AuditEventType.ticketCreated, ticketId: ticketId, payload: {'number': '$number'});

  Future<void> ticketCalled(String ticketId, int number, {String? operatorId}) =>
    log(AuditEventType.ticketCalled, ticketId: ticketId, operatorId: operatorId, payload: {'number': '$number'});

  Future<void> ticketServed(String ticketId, int number) =>
    log(AuditEventType.ticketServed, ticketId: ticketId, payload: {'number': '$number'});

  Future<void> ticketCancelled(String ticketId, int number) =>
    log(AuditEventType.ticketCancelled, ticketId: ticketId, payload: {'number': '$number'});

  Future<void> ticketNoShow(String ticketId, int number) =>
    log(AuditEventType.ticketNoShow, ticketId: ticketId, payload: {'number': '$number'});

  Future<void> ticketRecovered(String ticketId) =>
    log(AuditEventType.ticketRecovered, ticketId: ticketId);

  Future<void> appointmentCreated(String appointmentId) =>
    log(AuditEventType.appointmentCreated, payload: {'appointmentId': appointmentId});

  Future<void> appointmentCancelled(String appointmentId) =>
    log(AuditEventType.appointmentCancelled, payload: {'appointmentId': appointmentId});

  Future<void> syncCompleted(int count) =>
    log(AuditEventType.syncCompleted, payload: {'itemsSynced': '$count'});

  Future<void> syncFailed(String error) =>
    log(AuditEventType.syncFailed, payload: {'error': error});
}
