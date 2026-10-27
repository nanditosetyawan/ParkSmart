import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_parking/core/services/maintenance_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await MaintenanceService.instance.init();
  });

  group('PENGUJIAN A — GLOBAL MAINTENANCE', () {
    test('Saat dinonaktifkan, platform dalam kondisi normal', () {
      final s = MaintenanceService.instance;
      expect(s.isGlobalMaintenance, false);
      expect(s.isWarningOnly, false);
    });

    test('Saat diaktifkan, nilai judul, pesan, dan eta tersimpan dengan benar', () async {
      final s = MaintenanceService.instance;
      await s.setGlobalMaintenance(
        true,
        title: 'Sistem Sedang Dalam Pemeliharaan Terjadwal',
        message: 'Sedang peningkatan server.',
        eta: '2 Jam (Selesai pukul 05:00 WIB)',
        warningOnly: false,
        notifyPush: false,
      );

      expect(s.isGlobalMaintenance, true);
      expect(s.isWarningOnly, false);
      expect(s.maintenanceTitle, 'Sistem Sedang Dalam Pemeliharaan Terjadwal');
      expect(s.maintenanceMessage, 'Sedang peningkatan server.');
      expect(s.maintenanceEta, '2 Jam (Selesai pukul 05:00 WIB)');
    });
  });

  group('PENGUJIAN B — MODE PERINGATAN SAJA (WARNING ONLY MODE)', () {
    test('Saat mode peringatan aktif, judul dan pesan peringatan tersimpan', () async {
      final s = MaintenanceService.instance;
      await s.setWarningOnlySettings(
        true,
        title: 'Pemberitahuan Pemeliharaan Sistem',
        message: 'Layanan tetap beroperasi normal.',
      );

      expect(s.isWarningOnly, true);
      expect(s.warningTitle, 'Pemberitahuan Pemeliharaan Sistem');
      expect(s.warningMessage, 'Layanan tetap beroperasi normal.');
    });
  });

  group('PENGUJIAN C — MAINTENANCE PER MODUL SISTEM', () {
    test('Toggle modular booking, ai, kyc, dan push bekerja independen', () async {
      final s = MaintenanceService.instance;

      // Awalnya semua modul normal
      expect(s.isModuleInMaintenance('booking'), false);
      expect(s.isModuleInMaintenance('ai'), false);
      expect(s.isModuleInMaintenance('kyc'), false);
      expect(s.isModuleInMaintenance('push'), false);

      // Aktifkan maintenance modul booking saja
      await s.setModuleMaintenance('booking', true);
      expect(s.isModuleInMaintenance('booking'), true);
      expect(s.isBookingMaintenance, true);

      // Modul lain harus tetap normal
      expect(s.isModuleInMaintenance('ai'), false);
      expect(s.isModuleInMaintenance('kyc'), false);
      expect(s.isModuleInMaintenance('push'), false);

      // Aktifkan modul kyc
      await s.setModuleMaintenance('kyc', true);
      expect(s.isModuleInMaintenance('kyc'), true);
      expect(s.isModuleInMaintenance('ai'), false);

      // Nonaktifkan kembali modul booking
      await s.setModuleMaintenance('booking', false);
      expect(s.isModuleInMaintenance('booking'), false);
      expect(s.isModuleInMaintenance('kyc'), true);
    });
  });
}
