import 'package:drift/drift.dart';

part 'database.g.dart';

// Ticket status constants
abstract class TicketStatusValues {
  static const int waiting = 0;
  static const int serving = 1;
  static const int served = 2;
  static const int cancelled = 3;
  static const int noShow = 4;
}

// Audit event types
abstract class AuditEventType {
  static const String ticketCreated = 'ticket_created';
  static const String ticketCalled = 'ticket_called';
  static const String ticketServed = 'ticket_served';
  static const String ticketCancelled = 'ticket_cancelled';
  static const String ticketNoShow = 'ticket_no_show';
  static const String ticketRecovered = 'ticket_recovered';
  static const String appointmentCreated = 'appointment_created';
  static const String appointmentCancelled = 'appointment_cancelled';
  static const String appointmentArrived = 'appointment_arrived';
  static const String syncCompleted = 'sync_completed';
  static const String syncFailed = 'sync_failed';
}

class Tickets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ticketId => text().unique()();
  IntColumn get number => integer()();
  TextColumn get name => text().nullable()();
  TextColumn get reason => text().nullable()();
  TextColumn get phone => text().nullable()();
  IntColumn get partySize => integer().withDefault(const Constant(1))();
  IntColumn get ticketStatus => integer().withDefault(const Constant(0))();
  DateTimeColumn get joinedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get servedAt => dateTime().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  TextColumn get operatorId => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  // Phase 2: appointment link
  TextColumn get appointmentId => text().nullable()();
}

class OfflineActions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get actionType => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isProcessed => boolean().withDefault(const Constant(false))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}

// Phase 2: Audit log table
class AuditEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get eventType => text()();
  TextColumn get ticketId => text().nullable()();
  TextColumn get payloadJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get operatorId => text().nullable()();
}

// Phase 2: Appointments table
class Appointments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get appointmentId => text().unique()();
  TextColumn get customerName => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get reason => text().nullable()();
  DateTimeColumn get scheduledAt => dateTime()();
  IntColumn get durationMinutes => integer().withDefault(const Constant(15))();
  IntColumn get partySize => integer().withDefault(const Constant(1))();
  // 0=scheduled, 1=arrived, 2=completed, 3=cancelled, 4=noShow
  IntColumn get status => integer().withDefault(const Constant(0))();
  TextColumn get ticketId => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

// Phase 2: Brand config (stored as key-value)
class BrandConfig extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Tickets, OfflineActions, AuditEvents, Appointments, BrandConfig])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(auditEvents);
          await m.createTable(appointments);
          await m.createTable(brandConfig);
          await m.addColumn(tickets, tickets.appointmentId);
          await m.addColumn(offlineActions, offlineActions.retryCount);
        }
      },
    );
  }

  // ── Ticket queries ──

  Stream<List<Ticket>> watchWaitingTickets() {
    return (select(tickets)
          ..where((t) => t.ticketStatus.equals(TicketStatusValues.waiting))
          ..orderBy([(t) => OrderingTerm.desc(t.priority), (t) => OrderingTerm.asc(t.joinedAt)])
        )
        .watch();
  }

  Future<Ticket?> getTicketByTicketId(String ticketId) {
    return (select(tickets)..where((t) => t.ticketId.equals(ticketId)))
        .getSingleOrNull();
  }

  Future<int> insertTicket(TicketsCompanion ticket) {
    return into(tickets).insert(ticket);
  }

  Future<bool> updateTicket(TicketsCompanion ticket) {
    return update(tickets).replace(ticket);
  }

  Future<int> getNextNumber() async {
    final result = await customSelect(
      'SELECT COALESCE(MAX(number), 0) as max_num FROM tickets',
      readsFrom: {tickets},
    ).getSingle();
    return (result.read<int>('max_num')) + 1;
  }

  Future<int> getWaitingCount() {
    return (select(tickets)
          ..where((t) => t.ticketStatus.equals(TicketStatusValues.waiting)))
        .get()
        .then((list) => list.length);
  }

  Future<List<Ticket>> getHistory({int limit = 50}) {
    return (select(tickets)
          ..orderBy([(t) => OrderingTerm.desc(t.joinedAt)])
          ..limit(limit)
        )
        .get();
  }

  // ── Recovery queries ──

  Future<Ticket?> findActiveTicketByPhone(String phone) {
    return (select(tickets)
          ..where((t) =>
            t.phone.equals(phone) &
            t.ticketStatus.isIn([TicketStatusValues.waiting, TicketStatusValues.serving]))
          ..orderBy([(t) => OrderingTerm.desc(t.joinedAt)])
          ..limit(1)
        )
        .getSingleOrNull();
  }

  Future<Ticket?> findTicketByPartialCode(String partialCode) {
    return (select(tickets)
          ..where((t) =>
            t.ticketId.like('%$partialCode%') &
            t.ticketStatus.isIn([TicketStatusValues.waiting, TicketStatusValues.serving]))
          ..limit(1)
        )
        .getSingleOrNull();
  }

  // ── Offline actions ──

  Future<int> insertOfflineAction(OfflineActionsCompanion action) {
    return into(offlineActions).insert(action);
  }

  Future<List<OfflineAction>> getPendingActions() {
    return (select(offlineActions)
          ..where((a) => a.isProcessed.equals(false))
          ..orderBy([(a) => OrderingTerm.asc(a.createdAt)])
        )
        .get();
  }

  Future<void> markActionProcessed(int id) {
    return (update(offlineActions)..where((a) => a.id.equals(id)))
        .write(const OfflineActionsCompanion(isProcessed: Value(true)));
  }

  Future<void> incrementRetryCount(int id) {
    return customUpdate(
      'UPDATE offline_actions SET retry_count = retry_count + 1 WHERE id = ?',
      variables: [Variable.withInt(id)],
      updates: {offlineActions},
    );
  }

  // ── Audit events ──

  Future<int> insertAuditEvent(AuditEventsCompanion event) {
    return into(auditEvents).insert(event);
  }

  Future<List<AuditEvent>> getAuditEvents({
    int limit = 100,
    String? ticketId,
    String? eventType,
    DateTime? since,
  }) {
    final query = select(auditEvents);
    query.where((e) {
      Expression<bool> condition = const Constant(true);
      if (ticketId != null) {
        condition = condition & e.ticketId.equals(ticketId);
      }
      if (eventType != null) {
        condition = condition & e.eventType.equals(eventType);
      }
      if (since != null) {
        condition = condition & e.createdAt.isBiggerOrEqualValue(since);
      }
      return condition;
    });
    query.orderBy([(e) => OrderingTerm.desc(e.createdAt)]);
    query.limit(limit);
    return query.get();
  }

  Stream<List<AuditEvent>> watchRecentAuditEvents({int limit = 50}) {
    return (select(auditEvents)
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)])
          ..limit(limit)
        )
        .watch();
  }

  // ── Appointments ──

  Future<int> insertAppointment(AppointmentsCompanion appt) {
    return into(appointments).insert(appt);
  }

  Future<Appointment?> getAppointmentById(String appointmentId) {
    return (select(appointments)
          ..where((a) => a.appointmentId.equals(appointmentId)))
        .getSingleOrNull();
  }

  Future<List<Appointment>> getUpcomingAppointments() {
    return (select(appointments)
          ..where((a) => a.status.equals(0)) // scheduled
          ..orderBy([(a) => OrderingTerm.asc(a.scheduledAt)])
        )
        .get();
  }

  Future<List<Appointment>> getAppointmentsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(appointments)
          ..where((a) =>
            a.scheduledAt.isBiggerOrEqualValue(start) &
            a.scheduledAt.isSmallerThanValue(end))
          ..orderBy([(a) => OrderingTerm.asc(a.scheduledAt)])
        )
        .get();
  }

  Future<bool> updateAppointment(AppointmentsCompanion appt) {
    return update(appointments).replace(appt);
  }

  Future<bool> hasConflict(DateTime scheduledAt, int durationMinutes) async {
    final end = scheduledAt.add(Duration(minutes: durationMinutes));
    final conflicts = await (select(appointments)
          ..where((a) =>
            a.status.equals(0) & // only check scheduled
            a.scheduledAt.isSmallerThanValue(end) &
            a.scheduledAt.isBiggerOrEqualValue(
              scheduledAt.subtract(Duration(minutes: durationMinutes)),
            ))
        )
        .get();
    return conflicts.isNotEmpty;
  }

  // ── Analytics ──

  Future<Map<String, dynamic>> getTodayStats() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final allToday = await (select(tickets)
          ..where((t) => t.joinedAt.isBiggerOrEqualValue(startOfDay))
        )
        .get();

    final served = allToday.where((t) => t.ticketStatus == TicketStatusValues.served).toList();
    final noShows = allToday.where((t) => t.ticketStatus == TicketStatusValues.noShow).toList();
    final waiting = allToday.where((t) => t.ticketStatus == TicketStatusValues.waiting).length;

    // Average wait time for served tickets
    double avgWaitMin = 0;
    if (served.isNotEmpty) {
      final totalWait = served.fold<int>(0, (sum, t) {
        if (t.servedAt != null) {
          return sum + t.servedAt!.difference(t.joinedAt).inMinutes;
        }
        return sum;
      });
      avgWaitMin = totalWait / served.length;
    }

    return {
      'totalCreated': allToday.length,
      'served': served.length,
      'waiting': waiting,
      'noShows': noShows.length,
      'avgWaitMinutes': avgWaitMin.round(),
    };
  }

  // ── Brand config ──

  Future<String?> getBrandValue(String key) {
    return (select(brandConfig)..where((b) => b.key.equals(key)))
        .getSingleOrNull()
        .then((r) => r?.value);
  }

  Future<void> setBrandValue(String key, String value) {
    return into(brandConfig).insertOnConflictUpdate(
      BrandConfigCompanion.insert(key: key, value: value),
    );
  }
}
