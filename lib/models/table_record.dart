import 'package:hive/hive.dart';

part 'table_record.g.dart';

@HiveType(typeId: 3)
class TableRecord extends HiveObject { // Extend HiveObject
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final List<String> columns;
  @HiveField(3)
  final List<Map<String, dynamic>> rows;

  TableRecord({required this.id, required this.name, required this.columns, required this.rows});
}
