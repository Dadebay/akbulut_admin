import 'dart:async';

import 'package:akbulut_admin/app/data/models/attendence_record.dart';
import 'package:akbulut_admin/app/product/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class DahuaService {
  final String _path = "/api/records";

  Future<List<AttendanceRecord>> fetchAttendanceRecords(
    DateTime startTime,
    DateTime endTime, {
    String location = 'merkez',
  }) async {
    final int startTimestamp = startTime.millisecondsSinceEpoch ~/ 1000;
    final int endTimestamp = endTime.millisecondsSinceEpoch ~/ 1000;

    final url = Uri.parse('${ApiConstants.serverBaseUrl}$_path')
        .replace(queryParameters: {
      'StartTime': startTimestamp.toString(),
      'EndTime': endTimestamp.toString(),
      'location': location,
    });
    print("Sunucuya istek gönderiliyor: $url");
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 60));
      print("Sunucudan gelen yanıt durumu: ${response.statusCode}");
      if (response.statusCode == 200) {
        return _parseResponse(response.body);
      } else {
        throw Exception(
            'Sunucudan hata alındı: ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException catch (e) {
      print("İstek zaman aşımına uğradı: $e");
      throw Exception('Sunucuya bağlanılamadı. Zaman aşımı.');
    } on Exception catch (e) {
      print("API Hatası: $e");
      throw Exception('Bir hata oluştu: ${e.toString()}');
    }
  }

  List<AttendanceRecord> _parseResponse(String responseBody) {
    final lines = responseBody.split('\n');
    final Map<int, Map<String, String>> recordsMap = {};
    final RegExp regExp = RegExp(r'records\[(\d+)\]\.(\w+)=(.*)');
    for (final line in lines) {
      final trimmedLine = line.trim();
      final match = regExp.firstMatch(trimmedLine);
      if (match != null) {
        final index = int.parse(match.group(1)!);
        final key = match.group(2)!;
        final value = match.group(3)!.trim();

        recordsMap.putIfAbsent(index, () => {});
        recordsMap[index]![key] = value;
      } else if (trimmedLine.isNotEmpty && !trimmedLine.startsWith('found=')) {
        print("Line does not match regex: '$trimmedLine'");
      }
    }
    final List<AttendanceRecord> attendanceRecords = [];
    recordsMap.forEach((index, data) {
      try {
        if (data['UserID'] == null || data['CreateTime'] == null) {
          print(
              "Skipping record $index due to missing UserID or CreateTime. Data: $data");
          return;
        }

        final record = AttendanceRecord(
          userId: data['UserID']!,
          cardName: data['CardName'] ?? 'N/A',
          createTime: DateTime.fromMillisecondsSinceEpoch(
              int.parse(data['CreateTime']!) * 1000),
          type: (data['Type'] == 'Entry') ? EventType.entry : EventType.unknown,
          roomNumber: data['RoomNumber'],
        );
        attendanceRecords.add(record);
      } catch (e) {
        print("Parsing error for record $index: $e");
        print("Problematic data for record $index: $data");
      }
    });
    attendanceRecords.sort((a, b) => b.createTime.compareTo(a.createTime));
    return attendanceRecords;
  }
}
