import 'dart:async';

import '../models/car_report.dart';
import 'mock_data.dart';

/// API-ready service layer.
/// The current build returns realistic Kazakhstan demo data while keeping the
/// same async boundaries we would use with a real backend.
class CarService {
  /// Validate VIN: 17 chars, no I / O / Q.
  static bool validateVin(String vin) {
    return RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(vin.toUpperCase());
  }

  /// Fetch full report for a VIN.
  static Future<CarReport> getReport(String vin) async {
    await Future.delayed(const Duration(milliseconds: 1400));
    return MockData.reportForVin(vin);
  }

  static Future<List<AccidentRecord>> getAccidents(String vin) async {
    final report = await getReport(vin);
    return report.accidents;
  }

  static Future<List<FineRecord>> getFines(String vin) async {
    final report = await getReport(vin);
    return report.fines;
  }

  static Future<MarketPrice> getPrice(String vin) async {
    final report = await getReport(vin);
    return report.marketPrice;
  }
}
