class Base {
  final String? id;
  final String name;

  Base({this.id, required this.name});

  
  factory Base.fromJson(Map<String, dynamic> json) {
    return Base(
      id: json['id'] as String,
      name: json['title'] as String, 
    );
  }

  Map<String, dynamic> toJson(workspaceId) {
    return {
      "title": name,
      "fk_workspace_id": workspaceId,
      "type": "database",
      "meta": "{\"iconColor\":\"#6A7184\"}"
    };
  }
}