import 'package:alkami_core_dev_dependencies/alkami_core_dev_dependencies.dart';
import 'package:alkami_core_dependencies/alkami_core_dependencies.dart';

void main() {
  const MethodChannel channel = MethodChannel('apptentive_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    // expect(await ApptentiveFlutter.platformVersion, '42');
  });
}
