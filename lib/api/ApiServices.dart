import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nocodb_app/models/Base.dart';
import 'package:nocodb_app/models/TableRecord.dart';
import 'package:nocodb_app/models/TableData.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final baseUrl = 'https://app.nocodb.com';

  // Fetches bases from the API
  Future<List<Base>> fetchBases(String workspaceId) async {
    try {
      final response = await http.get(
          Uri.parse('$baseUrl/api/v2/meta/workspaces/$workspaceId/bases'),
          headers: {
            'Content-type': 'application/json',
            'xc-token': dotenv.env['API_KEY']!,
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
          'xc-token': dotenv.env['API_KEY']!,
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
          'xc-token': dotenv.env['API_KEY']!, // Replace with your actual token
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
          'xc-token': dotenv.env['API_KEY']!,
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
          'xc-token': dotenv.env['API_KEY']!,
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
          'xc-token': dotenv.env['API_KEY']!,
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
            'xc-token': dotenv.env['API_KEY']!,
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
