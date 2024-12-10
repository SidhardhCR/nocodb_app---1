import 'package:hive/hive.dart';
import 'package:nocodb_app/models/table_record.dart';


part 'base.g.dart';

@HiveType(typeId: 2)
class Base extends HiveObject { // Extend HiveObject
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final List<TableRecord> tables;

  Base({required this.id, required this.name, required this.tables});
}
