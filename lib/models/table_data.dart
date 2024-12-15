class TableData {
  // ignore: prefer_typing_uninitialized_variables
  final id;
  final List<String> columns;
  final List<Map<String, dynamic>> rows;

  TableData({
    required this.id,
    required this.columns,
    required this.rows,
  });

  factory TableData.fromJson(Map<String, dynamic> json) {
    // ignore: prefer_typing_uninitialized_variables
    var id;
    List<String> columns = [];
    List<Map<String, dynamic>> rows = [];
    Map<String, dynamic> data = {};

    json.forEach((key, value) {
      if (key == 'Id') {
        id = value;
      } else if (key != "CreatedAt" && key != "UpdatedAt") {
        columns.add(key);
        data[key] = value ?? '';
      }
    });

    rows.add(data);

    return TableData(
      id: id,
      columns: columns,
      rows: rows,
    );
  }
}
