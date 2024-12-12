class TableData {
  final id;
  final List<String> columns; 
  final List<Map<String, dynamic>>
      rows; 

  TableData({
    required this.id,
    required this.columns,
    required this.rows,
  });


  factory TableData.fromJson(Map<String, dynamic> json) {
    var id;
    List<String> columns = [];
    List<Map<String, dynamic>> rows = [];
    Map<String, dynamic> data = {};
    bool betweenKeys = false;

    
    json.forEach((key, value) {
      if (key == 'Id') {
        id = value;
        betweenKeys = true; 
      } else if (key == 'CreatedAt') {
        betweenKeys = false;
      } else if (betweenKeys) {
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