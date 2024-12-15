import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nocodb_app/models/base_data.dart';
import 'package:nocodb_app/models/table_record.dart';
import 'package:nocodb_app/models/table_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final baseUrl = 'http://projects-nocodb-bb16f8-107-155-122-26.traefik.me';

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('xcAuthToken');
  }

  // Fetches bases from the API
  Future<List<Base>> fetchBases() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Token not found');
      }
      final response =
          await http.get(Uri.parse('$baseUrl/api/v2/meta/bases'), headers: {
        'Content-type': 'application/json',
        'xc-auth': token,
      });

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      
        final List<dynamic> baseList = jsonResponse['list'] ?? [];

      
        return baseList.map((e) => Base.fromJson(e)).toList();
      } else {
        
        throw Exception('Failed to fetch bases');
      }
    } catch (error) {
     
      throw Exception('Error fetching bases: $error');
    }
  }

  // Method to create a new base (you will need to implement the backend API for this)
  Future<void> createBase(Base newBase) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Token not found');
      }
      final response = await http.post(
        Uri.parse('$baseUrl/api/v2/meta/bases'),
        headers: {
          'Content-type': 'application/json',
          'xc-auth': token,
        },
        body: jsonEncode(newBase.toJson()),
      );

      if (response.statusCode != 200) {
        
        throw Exception('Failed to create base');
      }
    } catch (error) {
     
      throw Exception('Error creating base: $error');
    }
  }

  Future<List<TableRecord>> fetchTables(String baseId) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Token not found');
      }
      final response = await http.get(
        Uri.parse('$baseUrl/api/v2/meta/bases/$baseId/tables'),
        headers: {
          'Content-Type': 'application/json',
          'xc-auth': token,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> tableList = jsonResponse['list'] ?? [];

        return tableList.map((e) => TableRecord.fromJson(e)).toList();
      } else {
       
        throw Exception('Failed to fetch tables');
      }
    } catch (error) {
     
      throw Exception('Error fetching tables: $error');
    }
  }

  Future<void> createTable(String baseId, TableRecord table) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Token not found');
      }
      final response = await http.post(
        Uri.parse('$baseUrl/api/v2/meta/bases/$baseId/tables'),
        headers: {
          'Content-type': 'application/json',
          'xc-auth': token,
        },
        body: jsonEncode(table.toJson()),
      );
      if (response.statusCode != 200) { 
        
        throw Exception('Failed to create base');
      }
    } catch (error) {
      throw Exception('failed to create table: $error');
    }
  }

  Future<List<TableData>> fetchTableRecords(String tableID) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Token not found');
      }
      final response = await http.get(
        Uri.parse('$baseUrl/api/v2/tables/$tableID/records'),
        headers: {
          'Content-type': 'application/json',
          'xc-auth': token,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> recordList = jsonResponse['list'] ?? [];
        return recordList.map((e) => TableData.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch Table Data');
      }
    } catch (error) {
      throw Exception('Error fetching Table Data: $error');
    }
  }

  Future<Map> getColumnsId(String tableId) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Token not found');
      }
      final response = await http.get(
        Uri.parse('$baseUrl/api/v2/meta/tables/$tableId'),
        headers: {
          'Content-Type': 'application/json',
          'xc-auth': token,
        },
      );
      if (response.statusCode == 200) {
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
        return idTitleList;
      } else {
        throw Exception('Error loading column id ');
      }
    } catch (error) {
      throw Exception('Error fetching column id : $error');
    }
  }

  Future<void> deleteRow(String tableId, id) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Token not found');
      }
      final response = await http.delete(
          Uri.parse('$baseUrl/api/v2/tables/$tableId/records'),
          headers: {
            'Content-Type': 'application/json',
            'xc-auth': token,
          },
          body: jsonEncode([
            {'Id': id}
          ]));
      if (response.statusCode != 200) {
        
        throw Exception('error in delete row');
      }
    } catch (error) {
      throw Exception('Failed to delete row: $error');
    }
  }
}
