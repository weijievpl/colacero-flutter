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
}

class OfflineActions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get actionType => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isProcessed => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Tickets, OfflineActions])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

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
}
