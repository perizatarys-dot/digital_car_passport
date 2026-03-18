enum AccidentSeverity { minor, moderate, major }

enum FineStatus { unpaid, paid }

enum RecommendationLevel { safe, caution, risk }

enum PriceLabel { belowMarket, fair, overpriced }

enum AccountType { free, premium, dealership, b2b }

enum PaymentStatus { paid, pending, failed }

class VehicleBasic {
  final String vin;
  final String brand;
  final String model;
  final int year;
  final String bodyType;
  final String engineType;
  final String engineVolume;
  final String transmission;
  final String drivetrain;
  final String color;
  final int mileage;
  final String registrationRegion;

  const VehicleBasic({
    required this.vin,
    required this.brand,
    required this.model,
    required this.year,
    required this.bodyType,
    required this.engineType,
    required this.engineVolume,
    required this.transmission,
    required this.drivetrain,
    required this.color,
    required this.mileage,
    required this.registrationRegion,
  });
}

class AccidentRecord {
  final String id;
  final String date;
  final String city;
  final AccidentSeverity severity;
  final String description;
  final bool airbagsDeployed;
  final bool repaired;

  const AccidentRecord({
    required this.id,
    required this.date,
    required this.city,
    required this.severity,
    required this.description,
    required this.airbagsDeployed,
    required this.repaired,
  });
}

class MileageRecord {
  final int year;
  final int mileage;
  final String source;

  const MileageRecord({
    required this.year,
    required this.mileage,
    required this.source,
  });
}

class OwnerRecord {
  final int order;
  final String periodFrom;
  final String periodTo;
  final int durationYears;
  final String ownershipType;

  const OwnerRecord({
    required this.order,
    required this.periodFrom,
    required this.periodTo,
    required this.durationYears,
    required this.ownershipType,
  });
}

class FineRecord {
  final String id;
  final String type;
  final int amount;
  final String date;
  final String location;
  final FineStatus status;

  const FineRecord({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.location,
    required this.status,
  });
}

class ServiceRecord {
  final String date;
  final String title;
  final String provider;
  final int mileage;

  const ServiceRecord({
    required this.date,
    required this.title,
    required this.provider,
    required this.mileage,
  });
}

class PriceFactor {
  final String label;
  final String impact;
  final bool positive;

  const PriceFactor({
    required this.label,
    required this.impact,
    required this.positive,
  });
}

class MarketPrice {
  final int estimated;
  final int rangeMin;
  final int rangeMax;
  final int marketAverage;
  final PriceLabel label;
  final int savingAmount;
  final List<PriceFactor> factors;

  const MarketPrice({
    required this.estimated,
    required this.rangeMin,
    required this.rangeMax,
    required this.marketAverage,
    required this.label,
    required this.savingAmount,
    required this.factors,
  });
}

class CarReport {
  final String id;
  final String generatedAt;
  final VehicleBasic vehicle;
  final int trustScore;
  final List<AccidentRecord> accidents;
  final List<MileageRecord> mileageHistory;
  final List<OwnerRecord> owners;
  final List<FineRecord> fines;
  final List<ServiceRecord> serviceHistory;
  final MarketPrice marketPrice;
  final RecommendationLevel recommendation;
  final String recommendationText;
  final bool transitPlateWarning;
  final bool stolenCheckClear;
  final String transitPlateNote;
  final String sourceSummary;

  const CarReport({
    required this.id,
    required this.generatedAt,
    required this.vehicle,
    required this.trustScore,
    required this.accidents,
    required this.mileageHistory,
    required this.owners,
    required this.fines,
    required this.serviceHistory,
    required this.marketPrice,
    required this.recommendation,
    required this.recommendationText,
    required this.transitPlateWarning,
    required this.stolenCheckClear,
    required this.transitPlateNote,
    required this.sourceSummary,
  });

  List<FineRecord> get unpaidFines =>
      fines.where((f) => f.status == FineStatus.unpaid).toList();

  int get totalOwed => unpaidFines.fold(0, (sum, fine) => sum + fine.amount);
}

class SavedReportPreview {
  final String vin;
  final String brand;
  final String model;
  final int year;
  final int trustScore;
  final String status;
  final String savedAt;

  const SavedReportPreview({
    required this.vin,
    required this.brand,
    required this.model,
    required this.year,
    required this.trustScore,
    required this.status,
    required this.savedAt,
  });

  factory SavedReportPreview.fromReport(CarReport report, {String? savedAt}) {
    return SavedReportPreview(
      vin: report.vehicle.vin,
      brand: report.vehicle.brand,
      model: report.vehicle.model,
      year: report.vehicle.year,
      trustScore: report.trustScore,
      status: report.recommendation.name,
      savedAt: savedAt ?? DateTime.now().toIso8601String().split('T').first,
    );
  }

  factory SavedReportPreview.fromJson(Map<String, dynamic> json) {
    return SavedReportPreview(
      vin: json['vin'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      trustScore: (json['trustScore'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'safe',
      savedAt: json['savedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vin': vin,
      'brand': brand,
      'model': model,
      'year': year,
      'trustScore': trustScore,
      'status': status,
      'savedAt': savedAt,
    };
  }
}

class PaymentRecord {
  final String id;
  final String title;
  final int amount;
  final String date;
  final PaymentStatus status;

  const PaymentRecord({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.status,
  });
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final AccountType accountType;
  final List<String> savedReportIds;
  final List<String> searchHistory;
  final List<PaymentRecord> payments;
  final int freeChecks;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.accountType,
    required this.savedReportIds,
    required this.searchHistory,
    required this.payments,
    required this.freeChecks,
  });

  String get initials => name
      .split(' ')
      .map((word) => word.isNotEmpty ? word[0] : '')
      .take(2)
      .join();
}
