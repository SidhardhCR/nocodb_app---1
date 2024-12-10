import 'package:hive/hive.dart';
import 'base.dart';

part 'workspace.g.dart';

@HiveType(typeId: 1)
class Workspace extends HiveObject { // Extend HiveObject
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final List<Base> bases;

  Workspace({required this.id, required this.name, required this.bases});
}
