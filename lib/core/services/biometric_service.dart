import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Servicio centralizado de Biometría (Huella Dactilar y Face ID)
/// - Utiliza `local_auth` para invocar el sensor nativo del sistema operativo (Android / iOS).
/// - Si el dispositivo no tiene hardware biométrico enrolado o corre en Web/escritorio,
///   retorna `false` para que la UI use el modal interactivo de contingencia bancaria.
class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Verifica si el dispositivo cuenta con soporte y hardware biométrico activo
  static Future<bool> canAuthenticateWithBiometrics() async {
    try {
      if (kIsWeb) return false;
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return isSupported && canCheck;
    } catch (_) {
      return false;
    }
  }

  /// Intenta autenticar con el sensor nativo de huella / Face ID del dispositivo
  static Future<bool> authenticate({required String localizedReason}) async {
    try {
      if (kIsWeb) return false;
      final canAuth = await canAuthenticateWithBiometrics();
      if (!canAuth) return false;

      return await _auth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}
