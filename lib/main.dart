import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/workspace.dart';
import 'models/base.dart';
import 'models/table_record.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(WorkspaceAdapter());
  Hive.registerAdapter(BaseAdapter());
  Hive.registerAdapter(TableRecordAdapter());

  await Hive.openBox<Workspace>('workspaces');
  await Hive.openBox<Base>('bases');
  await Hive.openBox<TableRecord>('table_record');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NocoDB App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BaseScreen(workspaceId: 'wabuzafi'),
    );
  }
}

class Base {
  final String? id;
  final String name;

  Base({this.id, required this.name});

  // Adjusted to correctly map the response fields
  factory Base.fromJson(Map<String, dynamic> json) {
    return Base(
      id: json['id'] as String,
      name: json['title'] as String, // API response uses 'title' for name
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

class TableData {
  final id;
  final List<String> columns; // Store the filtered keys as columns
  final List<Map<String, dynamic>>
      rows; // Store the corresponding values as rows

  TableData({
    required this.id,
    required this.columns,
    required this.rows,
  });

  // Factory constructor to create TableData from filtered data
  factory TableData.fromJson(Map<String, dynamic> json) {
    var id;
    List<String> columns = [];
    List<Map<String, dynamic>> rows = [];
    Map<String, dynamic> data = {};
    bool betweenKeys = false;

    // Iterate through the JSON keys in insertion order
    json.forEach((key, value) {
      if (key == 'Id') {
        id = value;
        betweenKeys = true; // Start tracking
      } else if (key == 'CreatedAt') {
        betweenKeys = false; // Stop tracking
      } else if (betweenKeys) {
        columns.add(key);
        data[key] = value ?? ''; // Add keys to columns and handle null values
      }
    });

    rows.add(data); // Add the row of data

    return TableData(
      id: id,
      columns: columns,
      rows: rows,
    );
  }
}

class ApiService {
  final baseUrl = 'https://app.nocodb.com';

  // Fetches bases from the API
  Future<List<Base>> fetchBases(String workspaceId) async {
    try {
      final response = await http.get(
          Uri.parse('$baseUrl/api/v2/meta/workspaces/$workspaceId/bases'),
          headers: {
            'Content-type': 'application/json',
            'xc-token': 'duX8CgfeznG8oERFDD3bjq2ZFLIOwOKbfGerVdHC',
          });

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

        // Extracting the 'list' key to get the bases
        final List<dynamic> baseList = jsonResponse['list'] ?? [];

        // Mapping the 'list' of bases to your Base model
        return baseList.map((e) => Base.fromJson(e)).toList();
      } else {
        print('Error: ${response.body}');
        throw Exception('Failed to fetch bases');
      }
    } catch (error) {
      print('Failed to load bases: $error');
      throw Exception('Error fetching bases: $error');
    }
  }

  // Method to create a new base (you will need to implement the backend API for this)
  Future<void> createBase(String workspaceId, Base newBase) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v2/meta/workspaces/$workspaceId/bases'),
        headers: {
          'Content-type': 'application/json',
          'xc-token': 'duX8CgfeznG8oERFDD3bjq2ZFLIOwOKbfGerVdHC',
        },
        body: jsonEncode(newBase.toJson(workspaceId)),
      );

      if (response.statusCode == 201) {
        print('Base created successfully');
      } else {
        print('Failed to create base: ${response.body}');
        throw Exception('Failed to create base');
      }
    } catch (error) {
      print('Failed to create base: $error');
      throw Exception('Error creating base: $error');
    }
  }

  Future<List<TableRecord>> fetchTables(String baseId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v2/meta/bases/$baseId/tables'),
        headers: {
          'Content-Type': 'application/json',
          'xc-token':
              'duX8CgfeznG8oERFDD3bjq2ZFLIOwOKbfGerVdHC', // Replace with your actual token
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> tableList = jsonResponse['list'] ?? [];

        // Map the API response to a list of TableRecord
        return tableList.map((e) => TableRecord.fromJson(e)).toList();
      } else {
        print('Error: ${response.body}');
        throw Exception('Failed to fetch tables');
      }
    } catch (error) {
      print('Failed to load tables: $error');
      throw Exception('Error fetching tables: $error');
    }
  }

  Future<void> createTable(String baseId, TableRecord table) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v2/meta/bases/$baseId/tables'),
        headers: {
          'Content-type': 'application/json',
          'xc-token': 'duX8CgfeznG8oERFDD3bjq2ZFLIOwOKbfGerVdHC',
        },
        body: jsonEncode(table.toJson()),
      );
      if (response.statusCode == 200) {
        print('Table created successfully');
      } else {
        print('Failed to create base: ${response.body}');
        throw Exception('Failed to create base');
      }
    } catch (error) {
      print('failed to create table: $error');
    }
  }

  Future<List<TableData>> fetchTableRecords(String tableID) async {
    try {
      final response = await http.get(
        Uri.parse('https://app.nocodb.com/api/v2/tables/$tableID/records'),
        headers: {
          'Content-type': 'application/json',
          'xc-token': 'duX8CgfeznG8oERFDD3bjq2ZFLIOwOKbfGerVdHC',
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        print(jsonResponse);
        // Extract the first record from the 'list'
        final List<dynamic> recordList = jsonResponse['list'] ?? [];
        print(recordList);

        // Create a TableData object from filtered data
        return recordList.map((e) => TableData.fromJson(e)).toList();
      } else {
        print('Error: ${response.body}');
        throw Exception('Failed to fetch Table Data');
      }
    } catch (error) {
      print('Failed to load Table Data: $error');
      throw Exception('Error fetching Table Data: $error');
    }
  }

  Future<Map> getColumnsId(String tableId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v2/meta/tables/$tableId'),
        headers: {
          'Content-Type': 'application/json',
          'xc-token': 'duX8CgfeznG8oERFDD3bjq2ZFLIOwOKbfGerVdHC',
        },
      );
      if (response.statusCode == 200) {
        print("Success to fetch columns id");
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> columnList = jsonResponse['columns'] ?? [];
        final List sublist = columnList.sublist(6);
        final titleId = columnList[1]['id'];
        final title = columnList[1]['title'];
        final titleobj = <String, String>{title: titleId};

        Map<String, String> idTitleList = {
          for (var column in sublist)
            column['title']?.toString() ?? '': column['id']?.toString() ?? '',
        };

        idTitleList.addEntries(titleobj.entries);
        print(idTitleList);
        return idTitleList;
      } else {
        print("failed to load columns id");
        throw Exception('Error loading column id ');
      }
    } catch (error) {
      print("failed to fetch columns id: $error");
      throw Exception('Error fetching column id : $error');
    }
  }

  Future<void> deleteRow(String tableId, id) async {
    try {
      final response = await http.delete(
          Uri.parse('$baseUrl/api/v2/tables/$tableId/records'),
          headers: {
            'Content-Type': 'application/json',
            'xc-token': 'duX8CgfeznG8oERFDD3bjq2ZFLIOwOKbfGerVdHC',
          },
          body: jsonEncode([
            {'Id': id}
          ]));
      if (response.statusCode == 200) {
        print("Successfully deleted row: ${response.body}");
      } else {
        print('error in delete row');
      }
    } catch (error) {
      print('Failed to delete row: $error');
    }
  }
}

class BaseScreen extends StatelessWidget {
  final String workspaceId;
  final ValueNotifier<List<Base>> basesNotifier;
  final ValueNotifier<bool> showBottomSheetBase = ValueNotifier(false);
  final TextEditingController baseTextController = TextEditingController();
  final ApiService apiService; // API Service for backend calls
  final ValueNotifier<bool> isLoding = ValueNotifier(false);

  BaseScreen({super.key, required this.workspaceId})
      : apiService = ApiService(), // Initialize API service
        basesNotifier = ValueNotifier<List<Base>>([]) {
    _loadBases();
  }

  Future<void> _loadBases() async {
    isLoding.value = true;
    try {
      // Fetch bases from the backend
      final bases = await apiService.fetchBases(workspaceId);
      basesNotifier.value = bases;
    } catch (e) {
      // Handle API error
      print("Failed to load bases: $e");
    } finally {
      isLoding.value = false;
    }
  }

  Future<void> _addBase() async {
    final newBase = Base(
        name: baseTextController.text.isNotEmpty
            ? baseTextController.text
            : "Untitled Base");

    try {
      // Send API request to create a new base
      await apiService.createBase(workspaceId, newBase);

      // Fetch the updated list of bases
      baseTextController.clear();
      showBottomSheetBase.value = false;
      await _loadBases();

      // Clear input and close bottom sheet
    } catch (e) {
      // Handle API error
      print("Failed to create base: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Sample',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromRGBO(51, 102, 254, 1)),
      body: ValueListenableBuilder(
          valueListenable: isLoding,
          builder: (context, loading, _) {
            if (loading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return ValueListenableBuilder<List<Base>>(
                valueListenable: basesNotifier,
                builder: (context, bases, _) {
                  if (bases.isEmpty) {
                    return const Center(child: Text("No Bases"));
                  }
                  return ListView.builder(
                    itemCount: bases.length,
                    itemBuilder: (context, index) {
                      final base = bases[index];
                      return ListTile(
                        title: Text(base.name),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => TableScreen(base: base)),
                          );
                        },
                      );
                    },
                  );
                },
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomSheetBase.value = true;
        },
        child: const Icon(Icons.add),
      ),
      bottomSheet: ValueListenableBuilder(
        valueListenable: showBottomSheetBase,
        builder: (context, value, _) {
          if (value) {
            return BottomSheet(
                onClosing: () {},
                elevation: 10,
                backgroundColor: const Color.fromARGB(255, 214, 214, 214),
                enableDrag: false,
                builder: (context) => Container(
                      width: double.infinity,
                      height: 250,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Create Base',
                            style: TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 0),
                            child: TextField(
                                controller: baseTextController,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))))),
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      baseTextController.clear();
                                      showBottomSheetBase.value = false;
                                    },
                                    child: const Text('Cancel')),
                                const SizedBox(width: 30),
                                ElevatedButton(
                                    onPressed: _addBase,
                                    child: const Text('Create Base')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class TableScreen extends StatelessWidget {
  final Base base;
  final ValueNotifier<List<TableRecord>> tablesNotifier = ValueNotifier([]);
  final ValueNotifier<bool> showBottomSheetTable = ValueNotifier(false);
  final TextEditingController tableTextController = TextEditingController();
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ApiService apiService;

  TableScreen({super.key, required this.base}) : apiService = ApiService() {
    _loadTables();
  }

  Future<void> _loadTables() async {
    isLoading.value = true;
    try {
      // Fetch tables from the API
      final tables = await apiService.fetchTables(base.id!);
      tablesNotifier.value = tables;
    } catch (e) {
      print('Failed to load tables: $e');
      tablesNotifier.value = []; // Ensure state is reset in case of error
    } finally {
      isLoading.value = false;
    }
  }

  void _addTable() async {
    final newTable = TableRecord(
      name: tableTextController.text.isNotEmpty
          ? tableTextController.text
          : "Untitled Table",
    );

    try {
      // Save the table locally or via API if needed
      await apiService.createTable(base.id!, newTable);
      showBottomSheetTable.value = false;
      tableTextController.clear();
      await _loadTables();
      // Clear the input and dismiss the bottom sheet
    } catch (error) {
      print("Failed to add table: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          base.name,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(51, 102, 254, 1),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: isLoading,
        builder: (context, loading, _) {
          if (loading) {
            // Show loading indicator while data is being fetched
            return const Center(child: CircularProgressIndicator());
          }
          return ValueListenableBuilder<List<TableRecord>>(
            valueListenable: tablesNotifier,
            builder: (context, tables, _) {
              if (tables.isEmpty) {
                return const Center(child: Text("No Tables"));
              }
              return ListView.builder(
                itemCount: tables.length,
                itemBuilder: (context, index) {
                  final table = tables[index];
                  return ListTile(
                    title: Text(table.name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DataTableScreen(table: table, base: base),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomSheetTable.value = true;
        },
        child: const Icon(Icons.add),
      ),
      bottomSheet: ValueListenableBuilder(
        valueListenable: showBottomSheetTable,
        builder: (context, value, _) {
          if (value) {
            return BottomSheet(
              onClosing: () {},
              elevation: 10,
              backgroundColor: const Color.fromARGB(255, 214, 214, 214),
              enableDrag: false,
              builder: (context) => Container(
                width: double.infinity,
                height: 250,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Create Table',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        controller: tableTextController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (value) {
                          _addTable();
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          labelText: 'Table Name',
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              tableTextController.clear();
                              showBottomSheetTable.value = false;
                            },
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 30),
                          ElevatedButton(
                            onPressed: _addTable,
                            child: const Text('Create Table'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class DataTableScreen extends StatefulWidget {
  final TableRecord table;
  final Base base;

  const DataTableScreen({super.key, required this.table, required this.base});

  @override
  _DataTableScreenState createState() => _DataTableScreenState();
}

class _DataTableScreenState extends State<DataTableScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final ValueNotifier<bool> showBottomSheetData = ValueNotifier(false);
  final TextEditingController dataTextController = TextEditingController();
  List<String> apiColumns = [];
  List<Map<String, dynamic>> apiRows = [];
  List apiId = [];
  bool isLoading = true;
  Map columnid = {};
  final ValueNotifier<bool> isHovered = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    _fetchData();
  }

  Future _fetchData() async {
    try {
      columnid = await ApiService().getColumnsId(widget.table.id!);

      final response = await ApiService().fetchTableRecords(widget.table.id!);
      setState(() {
        apiId = response.map((record) => record.id).toList();
        apiColumns = response[0].columns;
        apiRows = response.expand((record) {
          return record.rows.map((row) => Map<String, dynamic>.from(row));
        }).toList();
        isLoading = false; // Data has been loaded
      });
    } catch (error) {
      setState(() {
        isLoading = false; // Stop loading on error
      });
      print('Error fetching data: $error');
    }
    // Initialize dummy columns and rows
  }

  void _addNewRow() {
    setState(() {
      // Create a new row with empty values for all columns
      final newRow = {for (var column in apiColumns) column: ''};
      apiRows.add(newRow);
    });
  }

  void _addColumn() async {
    print("hi");
    final name =
        dataTextController.text.isEmpty ? "Untitled" : dataTextController.text;
    print(name);
    try {
      final response = await http.post(
          Uri.parse(
              'https://app.nocodb.com/api/v2/meta/tables/${widget.table.id}/columns'),
          headers: {
            'Content-Type': 'application/json',
            'xc-token': 'duX8CgfeznG8oERFDD3bjq2ZFLIOwOKbfGerVdHC',
          },
          body: jsonEncode({"title": name, "uidt": "SingleLineText"}));

      if (response.statusCode == 200) {
        print("Successfully added column");
        setState(() {
          _fetchData();
        });
      } else {
        print("Failed to add column: ${response.body}");
      }
    } catch (error) {
      print("Falied to add column: $error");
    }
  }

  Future<void> _updateCell(int? id, String column, String value) async {
    isLoading = true;
    try {
      if (id == null) {
        // Perform asynchronous work outside of setState
        final response = await http.post(
          Uri.parse(
              'https://app.nocodb.com/api/v2/tables/${widget.table.id}/records'),
          headers: {
            'Content-Type': 'application/json',
            'xc-token': 'duX8CgfeznG8oERFDD3bjq2ZFLIOwOKbfGerVdHC',
          },
          body: jsonEncode([
            {column: value}
          ]),
        );

        if (response.statusCode == 200) {
          print('Row successfully updated: ${response.body}');
          setState(() {
            final List id = jsonDecode(response.body);
            apiId.add(id[0]['Id']);
            _fetchData();
          });
        } else {
          print('Failed to update row: ${response.body}');
        }
      } else {
        final response = await http.patch(
          Uri.parse(
              'https://app.nocodb.com/api/v2/tables/${widget.table.id}/records'),
          headers: {
            'Content-Type': 'application/json',
            'xc-token': 'duX8CgfeznG8oERFDD3bjq2ZFLIOwOKbfGerVdHC',
          },
          body: jsonEncode([
            {'Id': id, column: value}
          ]),
        );

        if (response.statusCode == 200) {
          print('Row successfully updated: ${response.body}');
          setState(() {
            final List id = jsonDecode(response.body);
            apiId.add(id[0]['Id']);
            _fetchData();
          });
        } else {
          print('Failed to update row: ${response.body}');
        }
      }
    } catch (e) {
      print('Error updating cell: $e');
    }
  }

  void _deleteRow(apiId) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete record'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    ApiService().deleteRow(widget.table.id!, apiId);
                    setState(() {
                      isLoading = true;
                      _fetchData();
                    });
                    Navigator.of(context)
                        .pop(); // Close the dialog after deleting
                  },
                  child: const Text(
                    'Delete record',
                    style: TextStyle(color: Colors.red),
                  ))
            ],
          );
        });
  }

  void _updateColumnName(String id, String newName) async {
    isLoading = true;
    try {
      final response = await http.patch(
        Uri.parse('https://app.nocodb.com/api/v2/meta/columns/$id'),
        headers: {
          'Content-Type': 'application/json',
          'xc-token': 'duX8CgfeznG8oERFDD3bjq2ZFLIOwOKbfGerVdHC',
        },
        body: jsonEncode({
          "title": newName,
          "description": null,
          "uidt": "SingleLineText",
          "custom": {},
          "id": id,
          "base_id": widget.base.id,
          "fk_model_id": widget.table.id,
          "column_name": newName,
          "dt": "text",
          "np": null,
          "ns": null,
          "clen": null,
          "cop": null,
          "pk": false,
          "pv": null,
          "rqd": false,
          "un": false,
          "ct": null,
          "ai": false,
          "unique": null,
          "cdf": null,
          "cc": null,
          "csn": null,
          "dtx": "specificType",
          "dtxp": "",
          "dtxs": " ",
          "au": null,
          "validate": "",
          "virtual": null,
          "deleted": null,
          "system": false,
          "order": 7,
          "meta": {"defaultViewColOrder": 7},
          "fk_workspace_id": "wabuzafi",
          "altered": 8,
          "table_name": widget.table.name
        }),
      );
      if (response.statusCode == 200) {
        print('Successfully updated column');
        setState(() {
          _fetchData();
        });
      } else {
        print("failed to update column: ${response.body}");
      }
    } catch (error) {
      print("error $error");
    }
  }

  void _deleteColumn(String? columnId) async {
    try {
      print(columnId);
      final response = await http.delete(
        Uri.parse('https://app.nocodb.com/api/v2/meta/columns/$columnId'),
        headers: {
          'Content-Type': 'application/json',
          'xc-token': 'duX8CgfeznG8oERFDD3bjq2ZFLIOwOKbfGerVdHC',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _fetchData();
        });
      } else {
        print("error");
      }
    } catch (error) {
      print("error: $error");
    }
  }

  void _showEditColumnDialog(int index, String id) {
    TextEditingController columnEditController = TextEditingController();
    columnEditController.text = apiColumns[index];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Column Name"),
          content: TextField(
            controller: columnEditController,
            decoration: const InputDecoration(
              labelText: "New Column Name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _updateColumnName(id, columnEditController.text);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.table.name)),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (apiColumns.isEmpty || apiRows.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.table.name)),
        body: const Center(
          child: Text("No data available"),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.table.name)),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateColor.resolveWith(
            (states) => Colors.grey.shade200,
          ),
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey.shade400),
            verticalInside: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
          columns: [
            const DataColumn(
              label: Center(
                child: Text(
                  '#',
                  style: TextStyle(color: Color.fromARGB(255, 116, 115, 115)),
                ),
              ),
            ),
            ...apiColumns.asMap().entries.map(
              (entry) {
                final index = entry.key; // Column index
                final col = entry.value; // Column name

                return DataColumn(
                  label: Row(
                    children: [
                      Text(
                        col,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 116, 115, 115)),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (String result) {
                          if (result == 'Edit') {
                            _showEditColumnDialog(
                                index, columnid[col]); // Pass index here
                          } else if (result == 'Delete') {
                            print(col);
                            print(columnid[col]);
                            _deleteColumn(columnid[col]);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'Edit',
                            child: Text('Edit Column Name'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'Delete',
                            child: Text(
                              'Delete field ',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                        icon: const Icon(
                          Icons.arrow_drop_down_outlined,
                          color: Color.fromARGB(255, 116, 115, 115),
                        ),
                      )
                    ],
                  ),
                );
              },
            )
          ],
          rows: apiRows.asMap().entries.map((entry) {
            final rowIndex = entry.key;
            final row = entry.value;

            return DataRow(
              cells: [
                DataCell(
                  ValueListenableBuilder<bool>(
                    valueListenable: isHovered,
                    builder: (context, value, child) {
                      return value
                          ? IconButton(
                              icon: const Icon(Icons.check_box_outline_blank,
                                  color: Colors.grey),
                              onPressed: () {
                                if (rowIndex < apiId.length) {
                                  _deleteRow(apiId[rowIndex]);
                                  print(
                                      'Deleting row with ID: ${apiId[rowIndex]}');
                                } else {
                                  print('Cannot delete row without an ID.');
                                }
                              },
                            )
                          : GestureDetector(
                              onTap: () => isHovered.value = true,
                              child: Center(
                                child: Text(
                                  '${rowIndex + 1}', // Display row index
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            );
                    },
                  ),
                ),
                ...apiColumns.map((col) {
                  return DataCell(
                    TextField(
                      style: TextStyle(
                        color: apiColumns.indexOf(col) == 0
                            ? const Color.fromARGB(255, 19, 94, 207)
                            : Colors.black,
                      ),
                      controller: TextEditingController(text: row[col]),
                      onSubmitted: (value) {
                        if (rowIndex < apiId.length) {
                          _updateCell(apiId[rowIndex], col, value);
                        } else {
                          _updateCell(null, col, value);
                        }
                      },
                    ),
                  );
                }).toList(),
              ],
            );
          }).toList(),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _addNewRow,
            tooltip: "Add Row",
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              showBottomSheetData.value = true;
            },
            tooltip: "Add Column",
            child: const Icon(Icons.add_box),
          ),
        ],
      ),
      bottomSheet: ValueListenableBuilder(
        valueListenable: showBottomSheetData,
        builder: (context, value, _) {
          if (value) {
            return BottomSheet(
              onClosing: () {},
              elevation: 10,
              backgroundColor: const Color.fromARGB(255, 214, 214, 214),
              enableDrag: false,
              builder: (context) => Container(
                width: double.infinity,
                height: 250,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Create Column',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        controller: dataTextController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          labelText: 'Column Name',
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              dataTextController.clear();
                              showBottomSheetData.value = false;
                            },
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 30),
                          ElevatedButton(
                            onPressed: _addColumn,
                            child: const Text('Create Column'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
