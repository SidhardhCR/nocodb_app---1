import 'package:flutter/material.dart';
import 'package:nocodb_app/api/ApiServices.dart';
import 'package:nocodb_app/models/Base.dart';
import 'package:nocodb_app/models/TableRecord.dart';
import 'DataScreen.dart';

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
                  print(table.id);
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
