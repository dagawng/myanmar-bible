import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myanmar_bible_audio/core/network/network_info.dart';

class MockConnectivity extends Mock implements Connectivity {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() => super.noSuchMethod(
        Invocation.method(#checkConnectivity, []),
        returnValue: Future.value([ConnectivityResult.none]),
        returnValueForMissingStub: Future.value([ConnectivityResult.none]),
      );
}

void main() {
  late NetworkInfoImpl networkInfo;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockConnectivity = MockConnectivity();
    networkInfo = NetworkInfoImpl(connectivity: mockConnectivity);
  });

  group('isConnected', () {
    test('should return true when connectivity is wifi', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      final result = await networkInfo.isConnected;

      expect(result, isTrue);
    });

    test('should return false when connectivity is none', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      final result = await networkInfo.isConnected;

      expect(result, isFalse);
    });
  });
}
