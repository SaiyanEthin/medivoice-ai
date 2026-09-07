import 'package:flutter_test/flutter_test.dart';
import 'package:medivoice_ai/models/health_profile.dart';
import 'package:medivoice_ai/services/health_profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('storage round trip', () {
    test('a saved profile comes back intact', () async {
      final service = HealthProfileService();
      await service.save(const HealthProfile(
        name: 'Ethin Issac Gerald',
        age: 22,
        sex: 'Male',
        conditions: ['Asthma'],
        allergies: ['Penicillin', 'Dust'],
      ));

      final loaded = (await service.load())!;
      expect(loaded.name, 'Ethin Issac Gerald');
      expect(loaded.age, 22);
      expect(loaded.sex, 'Male');
      expect(loaded.conditions, ['Asthma']);
      expect(loaded.allergies, ['Penicillin', 'Dust']);
    });

    test('a name-only profile is valid', () async {
      final service = HealthProfileService();
      await service.save(const HealthProfile(name: 'Ethin'));

      final loaded = (await service.load())!;
      expect(loaded.name, 'Ethin');
      expect(loaded.age, isNull);
      expect(loaded.conditions, isEmpty);
    });

    test('load returns null when nothing is stored', () async {
      expect(await HealthProfileService().load(), isNull);
    });

    test('corrupt stored data is treated as absent, not thrown', () async {
      SharedPreferences.setMockInitialValues(
          {'health_profile': 'not valid json'});
      expect(await HealthProfileService().load(), isNull);
    });
  });

  group('setup prompting', () {
    test('offered on a fresh install', () async {
      expect(await HealthProfileService().shouldOfferSetup(), isTrue);
    });

    test('not offered again once skipped', () async {
      final service = HealthProfileService();
      await service.markSetupSkipped();
      expect(await service.shouldOfferSetup(), isFalse);
    });

    test('not offered once a profile exists', () async {
      final service = HealthProfileService();
      await service.save(const HealthProfile(name: 'Ethin'));
      expect(await service.shouldOfferSetup(), isFalse);
    });

    test('saving clears an earlier skip', () async {
      final service = HealthProfileService();
      await service.markSetupSkipped();
      await service.save(const HealthProfile(name: 'Ethin'));
      expect(await service.wasSetupSkipped(), isFalse);
    });
  });

  group('greeting name', () {
    test('uses the first name only', () {
      const profile = HealthProfile(name: 'Ethin Issac Gerald');
      expect(profile.greetingName, 'Ethin');
    });

    test('handles a single name', () {
      const profile = HealthProfile(name: 'Ethin');
      expect(profile.greetingName, 'Ethin');
    });

    test('handles surrounding whitespace', () {
      const profile = HealthProfile(name: '  Ethin  Gerald ');
      expect(profile.greetingName, 'Ethin');
    });

    test('empty name yields an empty greeting', () {
      const profile = HealthProfile(name: '');
      expect(profile.greetingName, '');
    });
  });

  test('clear removes both the profile and the skip flag', () async {
    final service = HealthProfileService();
    await service.save(const HealthProfile(name: 'Ethin'));
    await service.clear();
    expect(await service.load(), isNull);
    expect(await service.wasSetupSkipped(), isFalse);
  });
}
