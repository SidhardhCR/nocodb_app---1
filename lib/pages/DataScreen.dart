import 'package:flutter/material.dart';
import 'package:nocodb_app/api/ApiServices.dart';
import 'package:nocodb_app/models/Base.dart';
import 'package:nocodb_app/models/TableRecord.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false; 
      });
      print('Error fetching data: $error');
    }
    
  }

  void _addNewRow() {
    setState(() {
      
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
            'xc-token': dotenv.env['API_KEY']!,
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
            'xc-token': dotenv.env['API_KEY']!,
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
            'xc-token': dotenv.env['API_KEY']!,
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
                        .pop(); 
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
          'xc-token': dotenv.env['API_KEY']!,
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
          'xc-token': dotenv.env['API_KEY']!,
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
                final index = entry.key; 
                final col = entry.value; 

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
                                index, columnid[col]); 
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
                                  '${rowIndex + 1}', 
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
