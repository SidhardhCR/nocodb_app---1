class TableRecord {
  final String? id;
  final String name;

  TableRecord({this.id, required this.name});

  factory TableRecord.fromJson(Map<String, dynamic> json) {
    return TableRecord(
      id: json['id'],
      name: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": name,
      "table_name": name,
      "description": "",
      "columns": [
        {
          "column_name": "id",
          "title": "Id",
          "dt": "int4",
          "dtx": "integer",
          "ct": "int(11)",
          "nrqd": false,
          "rqd": true,
          "ck": false,
          "pk": true,
          "un": false,
          "ai": true,
          "cdf": null,
          "clen": null,
          "np": 11,
          "ns": 0,
          "dtxp": "11",
          "dtxs": "",
          "altered": 1,
          "uidt": "ID",
          "uip": "",
          "uicn": ""
        },
        {
          "column_name": "title",
          "title": "Title",
          "dt": "TEXT",
          "dtx": "specificType",
          "ct": null,
          "nrqd": true,
          "rqd": false,
          "ck": false,
          "pk": false,
          "un": false,
          "ai": false,
          "cdf": null,
          "clen": null,
          "np": null,
          "ns": null,
          "dtxp": "",
          "dtxs": "",
          "altered": 1,
          "uidt": "SingleLineText",
          "uip": "",
          "uicn": ""
        },
        {
          "column_name": "created_at",
          "title": "CreatedAt",
          "dt": "timestamp",
          "dtx": "specificType",
          "ct": "timestamp",
          "nrqd": true,
          "rqd": false,
          "ck": false,
          "pk": false,
          "un": false,
          "ai": false,
          "clen": 45,
          "np": null,
          "ns": null,
          "dtxp": "",
          "dtxs": "",
          "altered": 1,
          "uidt": "CreatedTime",
          "uip": "",
          "uicn": "",
          "system": true
        },
        {
          "column_name": "updated_at",
          "title": "UpdatedAt",
          "dt": "timestamp",
          "dtx": "specificType",
          "ct": "timestamp",
          "nrqd": true,
          "rqd": false,
          "ck": false,
          "pk": false,
          "un": false,
          "ai": false,
          "clen": 45,
          "np": null,
          "ns": null,
          "dtxp": "",
          "dtxs": "",
          "altered": 1,
          "uidt": "LastModifiedTime",
          "uip": "",
          "uicn": "",
          "system": true
        }
      ],
      "is_hybrid": true
    };
  }
}
