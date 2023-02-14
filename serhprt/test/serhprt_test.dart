import 'package:flutter_test/flutter_test.dart';
import 'package:serhprt/serhprt.dart';
import 'package:serhprt/serhprt_platform_interface.dart';
import 'package:serhprt/serhprt_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSerhprtPlatform
    with MockPlatformInterfaceMixin
    implements SerhprtPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SerhprtPlatform initialPlatform = SerhprtPlatform.instance;

  test('$MethodChannelSerhprt is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSerhprt>());
  });

  test('getPlatformVersion', () async {
    Serhprt serhprtPlugin = Serhprt();
    MockSerhprtPlatform fakePlatform = MockSerhprtPlatform();
    SerhprtPlatform.instance = fakePlatform;

    expect(await serhprtPlugin.getPlatformVersion(), '42');
  });
}
