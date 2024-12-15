import 'package:flutter/material.dart';
import 'package:nocodb_app/api/api_services.dart';
import 'package:nocodb_app/models/base_data.dart';
import 'package:nocodb_app/pages/splash_screen.dart';
import 'package:nocodb_app/pages/table_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseScreen extends StatelessWidget {
  final ValueNotifier<List<Base>> basesNotifier;
  final ValueNotifier<bool> showBottomSheetBase = ValueNotifier(false);
  final TextEditingController baseTextController = TextEditingController();
  final ApiService apiService;
  final ValueNotifier<bool> isLoding = ValueNotifier(false);

  BaseScreen({super.key})
      : apiService = ApiService(),
        basesNotifier = ValueNotifier<List<Base>>([]) {
    _loadBases();
  }

  Future<void> _loadBases() async {
    isLoding.value = true;
    try {
      final bases = await apiService.fetchBases();
      basesNotifier.value = bases;
    } catch (e) {
      throw Exception("Failed to load bases: $e");
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
      await apiService.createBase(newBase);

      baseTextController.clear();
      showBottomSheetBase.value = false;
      await _loadBases();
    } catch (e) {
      throw Exception("Failed to create base: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'NOCODB',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushReplacement(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
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
