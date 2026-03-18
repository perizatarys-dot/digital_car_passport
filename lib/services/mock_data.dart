import '../models/car_report.dart';

/// Rich demo content for the Kazakhstan MVP presentation build.
abstract class MockData {
  static const sampleVin = 'XTA21140002345678';
  static const bmwVin = 'WBA52FF000CHX1234';
  static const hyundaiVin = 'KMHE341AA2A100099';
  static const subaruVin = 'JF1GJ7KC0EG012345';

  static final CarReport sampleReport = CarReport(
    id: 'rpt_kz_001',
    generatedAt: '2026-03-15T10:30:00Z',
    vehicle: const VehicleBasic(
      vin: sampleVin,
      brand: 'Toyota',
      model: 'Camry',
      year: 2019,
      bodyType: 'Sedan',
      engineType: 'Petrol',
      engineVolume: '2.5L',
      transmission: 'Automatic',
      drivetrain: 'FWD',
      color: 'Pearl White',
      mileage: 78200,
      registrationRegion: 'Almaty',
    ),
    trustScore: 84,
    accidents: const [
      AccidentRecord(
        id: 'acc_001',
        date: '2022-03-10',
        city: 'Almaty',
        severity: AccidentSeverity.minor,
        description: 'Minor rear collision. Rear bumper and parking sensor replaced.',
        airbagsDeployed: false,
        repaired: true,
      ),
      AccidentRecord(
        id: 'acc_002',
        date: '2024-01-18',
        city: 'Astana',
        severity: AccidentSeverity.minor,
        description: 'Front-right fender repair reported by insurer claim reference.',
        airbagsDeployed: false,
        repaired: true,
      ),
    ],
    mileageHistory: const [
      MileageRecord(year: 2019, mileage: 8500, source: 'Dealer registration'),
      MileageRecord(year: 2020, mileage: 24100, source: 'Official service center'),
      MileageRecord(year: 2021, mileage: 41900, source: 'Annual inspection'),
      MileageRecord(year: 2022, mileage: 55700, source: 'Insurance assessment'),
      MileageRecord(year: 2023, mileage: 68400, source: 'Official service center'),
      MileageRecord(year: 2024, mileage: 74200, source: 'Registration renewal'),
      MileageRecord(year: 2025, mileage: 78200, source: 'Marketplace listing import'),
    ],
    owners: const [
      OwnerRecord(
        order: 1,
        periodFrom: '2019',
        periodTo: '2021',
        durationYears: 2,
        ownershipType: 'Private owner',
      ),
      OwnerRecord(
        order: 2,
        periodFrom: '2021',
        periodTo: '2023',
        durationYears: 2,
        ownershipType: 'Corporate fleet',
      ),
      OwnerRecord(
        order: 3,
        periodFrom: '2023',
        periodTo: 'present',
        durationYears: 3,
        ownershipType: 'Private owner',
      ),
    ],
    fines: const [
      FineRecord(
        id: 'fine_001',
        type: 'Speeding 92 km/h in 60 zone',
        amount: 18000,
        date: '2025-02-06',
        location: 'Al-Farabi Street, Almaty',
        status: FineStatus.unpaid,
      ),
      FineRecord(
        id: 'fine_002',
        type: 'Parking violation',
        amount: 14000,
        date: '2024-11-22',
        location: 'Dostyk Street, Almaty',
        status: FineStatus.unpaid,
      ),
      FineRecord(
        id: 'fine_003',
        type: 'Red light violation',
        amount: 20000,
        date: '2023-09-14',
        location: 'Turan Street, Astana',
        status: FineStatus.paid,
      ),
    ],
    serviceHistory: const [
      ServiceRecord(
        date: '2020-05-16',
        title: 'Scheduled oil and filter service',
        provider: 'Toyota Center Almaty',
        mileage: 22800,
      ),
      ServiceRecord(
        date: '2022-03-26',
        title: 'Rear bumper repair and paintwork',
        provider: 'Alem Auto Body',
        mileage: 56100,
      ),
      ServiceRecord(
        date: '2024-02-02',
        title: 'Brake pads and fluid replacement',
        provider: 'Toyota Center Astana',
        mileage: 74900,
      ),
    ],
    marketPrice: const MarketPrice(
      estimated: 8450000,
      rangeMin: 7600000,
      rangeMax: 9800000,
      marketAverage: 9150000,
      label: PriceLabel.belowMarket,
      savingAmount: 700000,
      factors: [
        PriceFactor(label: 'Above-average spec', impact: '+250K ₸', positive: true),
        PriceFactor(label: 'Minor accident history', impact: '-420K ₸', positive: false),
        PriceFactor(label: 'Mileage vs peers', impact: '+110K ₸', positive: true),
        PriceFactor(label: 'Unpaid fines', impact: '-32K ₸', positive: false),
      ],
    ),
    recommendation: RecommendationLevel.caution,
    recommendationText:
        'Check carefully. Mileage is consistent and theft data is clear, but two minor accident records and unpaid fines should be resolved before purchase.',
    transitPlateWarning: true,
    stolenCheckClear: true,
    transitPlateNote:
        'Historic transit plate registration found in 2021. Verify import and re-registration paperwork with seller.',
    sourceSummary:
        'Data combined from registration events, insurer claims, service records, fines registry, and market listings. Previous owner identities remain hidden.',
  );

  static final CarReport bmwReport = CarReport(
    id: 'rpt_kz_002',
    generatedAt: '2026-03-15T11:10:00Z',
    vehicle: const VehicleBasic(
      vin: bmwVin,
      brand: 'BMW',
      model: '5 Series',
      year: 2021,
      bodyType: 'Sedan',
      engineType: 'Petrol Hybrid',
      engineVolume: '2.0L',
      transmission: 'Automatic',
      drivetrain: 'RWD',
      color: 'Black Sapphire',
      mileage: 113400,
      registrationRegion: 'Astana',
    ),
    trustScore: 61,
    accidents: const [
      AccidentRecord(
        id: 'acc_bmw_001',
        date: '2023-06-21',
        city: 'Karaganda',
        severity: AccidentSeverity.moderate,
        description: 'Front-left accident with headlamp and bumper replacement.',
        airbagsDeployed: false,
        repaired: true,
      ),
    ],
    mileageHistory: const [
      MileageRecord(year: 2021, mileage: 12400, source: 'Dealer registration'),
      MileageRecord(year: 2022, mileage: 28700, source: 'Official BMW service'),
      MileageRecord(year: 2023, mileage: 46300, source: 'Insurance assessment'),
      MileageRecord(year: 2024, mileage: 46800, source: 'Marketplace export record'),
      MileageRecord(year: 2025, mileage: 96200, source: 'Independent service center'),
      MileageRecord(year: 2026, mileage: 113400, source: 'Marketplace listing import'),
    ],
    owners: const [
      OwnerRecord(
        order: 1,
        periodFrom: '2021',
        periodTo: '2022',
        durationYears: 1,
        ownershipType: 'Corporate lease',
      ),
      OwnerRecord(
        order: 2,
        periodFrom: '2022',
        periodTo: 'present',
        durationYears: 4,
        ownershipType: 'Private owner',
      ),
    ],
    fines: const [
      FineRecord(
        id: 'fine_bmw_001',
        type: 'Speeding 118 km/h in 80 zone',
        amount: 24000,
        date: '2025-12-09',
        location: 'Kabanbay Batyr Street, Astana',
        status: FineStatus.unpaid,
      ),
      FineRecord(
        id: 'fine_bmw_002',
        type: 'Improper lane change',
        amount: 12000,
        date: '2024-08-04',
        location: 'Bukhar Zhyrau Blvd, Karaganda',
        status: FineStatus.paid,
      ),
    ],
    serviceHistory: const [
      ServiceRecord(
        date: '2022-11-30',
        title: 'Routine oil service',
        provider: 'BMW Premium Astana',
        mileage: 30100,
      ),
      ServiceRecord(
        date: '2023-07-05',
        title: 'Front-left body repair',
        provider: 'Bavaria Body Shop',
        mileage: 47200,
      ),
      ServiceRecord(
        date: '2025-10-19',
        title: 'Transmission software and brake service',
        provider: 'Munich Auto Lab',
        mileage: 101800,
      ),
    ],
    marketPrice: const MarketPrice(
      estimated: 16700000,
      rangeMin: 15400000,
      rangeMax: 18900000,
      marketAverage: 17650000,
      label: PriceLabel.belowMarket,
      savingAmount: 950000,
      factors: [
        PriceFactor(label: 'Premium trim', impact: '+820K ₸', positive: true),
        PriceFactor(label: 'Mileage gap risk', impact: '-1.1M ₸', positive: false),
        PriceFactor(label: 'Accident repair', impact: '-450K ₸', positive: false),
        PriceFactor(label: 'Fresh service record', impact: '+220K ₸', positive: true),
      ],
    ),
    recommendation: RecommendationLevel.caution,
    recommendationText:
        'Check carefully. The specification is attractive, but the large mileage jump between 2024 and 2025 should be explained with service invoices and export records.',
    transitPlateWarning: false,
    stolenCheckClear: true,
    transitPlateNote: 'No transit plate registration found in available records.',
    sourceSummary:
        'Data combined from registration records, BMW service visits, insurer claims, and market imports. Personal identities remain hidden.',
  );

  static final CarReport hyundaiReport = CarReport(
    id: 'rpt_kz_003',
    generatedAt: '2026-03-15T11:30:00Z',
    vehicle: const VehicleBasic(
      vin: hyundaiVin,
      brand: 'Hyundai',
      model: 'Sonata',
      year: 2020,
      bodyType: 'Sedan',
      engineType: 'Petrol',
      engineVolume: '2.0L',
      transmission: 'Automatic',
      drivetrain: 'FWD',
      color: 'Silver',
      mileage: 146800,
      registrationRegion: 'Shymkent',
    ),
    trustScore: 34,
    accidents: const [
      AccidentRecord(
        id: 'acc_hyu_001',
        date: '2021-12-14',
        city: 'Shymkent',
        severity: AccidentSeverity.major,
        description: 'Insurer total-loss style claim with front structural repair indicators.',
        airbagsDeployed: true,
        repaired: true,
      ),
      AccidentRecord(
        id: 'acc_hyu_002',
        date: '2024-04-03',
        city: 'Taraz',
        severity: AccidentSeverity.minor,
        description: 'Rear-left paint and lamp repair listed by service center.',
        airbagsDeployed: false,
        repaired: true,
      ),
    ],
    mileageHistory: const [
      MileageRecord(year: 2020, mileage: 9800, source: 'Dealer registration'),
      MileageRecord(year: 2021, mileage: 35600, source: 'Official service center'),
      MileageRecord(year: 2022, mileage: 61200, source: 'Inspection record'),
      MileageRecord(year: 2023, mileage: 61500, source: 'Marketplace listing'),
      MileageRecord(year: 2024, mileage: 121400, source: 'Independent service center'),
      MileageRecord(year: 2025, mileage: 146800, source: 'Marketplace listing import'),
    ],
    owners: const [
      OwnerRecord(
        order: 1,
        periodFrom: '2020',
        periodTo: '2021',
        durationYears: 1,
        ownershipType: 'Private owner',
      ),
      OwnerRecord(
        order: 2,
        periodFrom: '2021',
        periodTo: '2024',
        durationYears: 3,
        ownershipType: 'Taxi / fleet use',
      ),
      OwnerRecord(
        order: 3,
        periodFrom: '2024',
        periodTo: 'present',
        durationYears: 2,
        ownershipType: 'Private owner',
      ),
    ],
    fines: const [
      FineRecord(
        id: 'fine_hyu_001',
        type: 'Bus lane violation',
        amount: 18000,
        date: '2025-07-16',
        location: 'Tauke Khan Street, Shymkent',
        status: FineStatus.unpaid,
      ),
      FineRecord(
        id: 'fine_hyu_002',
        type: 'Speeding 87 km/h in 60 zone',
        amount: 18000,
        date: '2025-05-11',
        location: 'Ryskulov St, Taraz',
        status: FineStatus.unpaid,
      ),
    ],
    serviceHistory: const [
      ServiceRecord(
        date: '2021-12-28',
        title: 'Front structural repair and airbags replacement',
        provider: 'South Auto Repair',
        mileage: 36200,
      ),
      ServiceRecord(
        date: '2024-04-09',
        title: 'Rear-left body and lamp repair',
        provider: 'Taraz Color Lab',
        mileage: 122100,
      ),
    ],
    marketPrice: const MarketPrice(
      estimated: 6600000,
      rangeMin: 6400000,
      rangeMax: 8200000,
      marketAverage: 7480000,
      label: PriceLabel.belowMarket,
      savingAmount: 880000,
      factors: [
        PriceFactor(label: 'High mileage', impact: '-540K ₸', positive: false),
        PriceFactor(label: 'Major loss record', impact: '-1.2M ₸', positive: false),
        PriceFactor(label: 'Popular trim in market', impact: '+210K ₸', positive: true),
        PriceFactor(label: 'Open fines', impact: '-36K ₸', positive: false),
      ],
    ),
    recommendation: RecommendationLevel.risk,
    recommendationText:
        'High risk. Prior severe damage, fleet-style usage, and a sharp mileage increase make this car risky without full repair invoices and expert inspection.',
    transitPlateWarning: true,
    stolenCheckClear: true,
    transitPlateNote:
        'Historic transit plate registration found after insurer loss record. Confirm re-registration paperwork carefully.',
    sourceSummary:
        'Data combined from registration changes, insurer claims, inspection records, service events, and market listings. Personal identities remain hidden.',
  );

  static final CarReport subaruReport = CarReport(
    id: 'rpt_kz_004',
    generatedAt: '2026-03-15T12:00:00Z',
    vehicle: const VehicleBasic(
      vin: subaruVin,
      brand: 'Subaru',
      model: 'XV',
      year: 2018,
      bodyType: 'Crossover',
      engineType: 'Petrol',
      engineVolume: '2.0L',
      transmission: 'CVT',
      drivetrain: 'AWD',
      color: 'Quartz Blue',
      mileage: 88400,
      registrationRegion: 'Almaty',
    ),
    trustScore: 91,
    accidents: const [],
    mileageHistory: const [
      MileageRecord(year: 2018, mileage: 7300, source: 'Dealer registration'),
      MileageRecord(year: 2019, mileage: 18200, source: 'Official service center'),
      MileageRecord(year: 2020, mileage: 30100, source: 'Inspection record'),
      MileageRecord(year: 2021, mileage: 42500, source: 'Official service center'),
      MileageRecord(year: 2022, mileage: 55600, source: 'Registration renewal'),
      MileageRecord(year: 2023, mileage: 69100, source: 'Independent service center'),
      MileageRecord(year: 2025, mileage: 88400, source: 'Marketplace listing import'),
    ],
    owners: const [
      OwnerRecord(
        order: 1,
        periodFrom: '2018',
        periodTo: '2022',
        durationYears: 4,
        ownershipType: 'Private owner',
      ),
      OwnerRecord(
        order: 2,
        periodFrom: '2022',
        periodTo: 'present',
        durationYears: 4,
        ownershipType: 'Private owner',
      ),
    ],
    fines: const [
      FineRecord(
        id: 'fine_sub_001',
        type: 'Parking violation',
        amount: 12000,
        date: '2024-01-19',
        location: 'Satpayev St, Almaty',
        status: FineStatus.paid,
      ),
    ],
    serviceHistory: const [
      ServiceRecord(
        date: '2021-09-12',
        title: 'CVT fluid service',
        provider: 'Subaru Center Almaty',
        mileage: 43100,
      ),
      ServiceRecord(
        date: '2023-11-08',
        title: 'Suspension bushings and alignment',
        provider: 'AWD Garage',
        mileage: 69800,
      ),
    ],
    marketPrice: const MarketPrice(
      estimated: 10300000,
      rangeMin: 9700000,
      rangeMax: 11200000,
      marketAverage: 10450000,
      label: PriceLabel.fair,
      savingAmount: 150000,
      factors: [
        PriceFactor(label: 'Clean accident history', impact: '+380K ₸', positive: true),
        PriceFactor(label: 'Consistent mileage', impact: '+240K ₸', positive: true),
        PriceFactor(label: 'Single paid fine only', impact: '+40K ₸', positive: true),
      ],
    ),
    recommendation: RecommendationLevel.safe,
    recommendationText:
        'Safe to consider. Records are consistent, there are no accident flags, and the service history supports the listed mileage.',
    transitPlateWarning: false,
    stolenCheckClear: true,
    transitPlateNote: 'No transit plate or import mismatch found in available records.',
    sourceSummary:
        'Data combined from service history, registration records, fines registry, and market listings. Personal identities remain hidden.',
  );

  static final Map<String, CarReport> reportsByVin = {
    sampleVin: sampleReport,
    bmwVin: bmwReport,
    hyundaiVin: hyundaiReport,
    subaruVin: subaruReport,
  };

  static CarReport reportForVin(String vin) {
    return reportsByVin[vin.toUpperCase()] ?? sampleReport;
  }

  static final AppUser sampleUser = AppUser(
    id: 'usr_001',
    name: 'Amir Bekovich',
    email: 'amir.bekovich@gmail.com',
    phone: '+7 701 234 5678',
    accountType: AccountType.free,
    savedReportIds: const ['rpt_kz_001', 'rpt_kz_002'],
    searchHistory: const [
      sampleVin,
      bmwVin,
      hyundaiVin,
      'JN1AZ4EH0DM440987',
    ],
    payments: const [
      PaymentRecord(
        id: 'pay_001',
        title: 'Single VIN Report',
        amount: 2000,
        date: '2026-03-12',
        status: PaymentStatus.paid,
      ),
    ],
    freeChecks: 2,
  );

  static const List<Map<String, dynamic>> recentSearches = [
    {
      'vin': sampleVin,
      'brand': 'Toyota',
      'model': 'Camry',
      'year': 2019,
      'score': 84,
      'status': 'caution',
      'subtitle': '2 accidents · 2 unpaid fines',
    },
    {
      'vin': bmwVin,
      'brand': 'BMW',
      'model': '5 Series',
      'year': 2021,
      'score': 61,
      'status': 'caution',
      'subtitle': 'Mileage gap detected',
    },
    {
      'vin': hyundaiVin,
      'brand': 'Hyundai',
      'model': 'Sonata',
      'year': 2020,
      'score': 34,
      'status': 'risk',
      'subtitle': 'Transit plate and insurance loss record',
    },
  ];

  static const List<SavedReportPreview> savedReports = [
    SavedReportPreview(
      vin: sampleVin,
      brand: 'Toyota',
      model: 'Camry',
      year: 2019,
      trustScore: 84,
      status: 'caution',
      savedAt: '2026-03-15',
    ),
    SavedReportPreview(
      vin: subaruVin,
      brand: 'Subaru',
      model: 'XV',
      year: 2018,
      trustScore: 91,
      status: 'safe',
      savedAt: '2026-03-10',
    ),
  ];

  static const List<Map<String, String>> faqItems = [
    {
      'question': 'What sources are used in the report?',
      'answer':
          'Digital Car Passport combines registration, claims, inspection, service, marketplace, and fines data into one report.',
    },
    {
      'question': 'Do you show previous owner identities?',
      'answer':
          'No. The app is privacy-first. Ownership periods are shown while personal data stays hidden.',
    },
    {
      'question': 'Can I share a report with a buyer or seller?',
      'answer':
          'Yes. Reports can be shared as a secure summary link in the mock product flow.',
    },
  ];
}
