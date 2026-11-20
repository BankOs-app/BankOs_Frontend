# BankOS Frontend

Aplicación de banca digital construida con Flutter. Incluye autenticación por institución, perfiles de cliente y administración, consulta de cuentas, retiros, transferencias, historial y selección de idioma.

## Requisitos

- Git.
- Flutter estable compatible con Dart `3.13.7` o posterior, según `pubspec.yaml`.
- Google Chrome para ejecutar la versión web.
- Backend BankOS en ejecución para validar autenticación y operaciones contra datos persistentes.

Flutter puede instalarse en Windows, macOS o Linux. Consulta la [guía oficial de instalación](https://docs.flutter.dev/get-started/install) para el sistema operativo correspondiente y valida la instalación con `flutter doctor`.

## Clonar el repositorio

Ejecuta los comandos desde PowerShell en Windows, o desde Terminal en macOS/Linux:

```sh
git clone https://github.com/BankOs-app/BankOs_Frontend.git
cd BankOs_Frontend
```

Para descargar los paquetes y preparar el proyecto:

```sh
flutter pub get
```

## Ejecutar en Chrome

Inicia primero el backend en `http://localhost:3000` y luego ejecuta:

```sh
flutter run -d chrome
```

La URL predeterminada de la API web es `http://localhost:3000/api/v1`. Para usar otra dirección, configura `API_BASE_URL` al ejecutar Flutter:

```sh
flutter run -d chrome --dart-define=API_BASE_URL=https://api.example.com/api/v1
```

La API debe permitir solicitudes CORS desde el origen usado por Flutter Web.

## Ejecutar en dispositivos

Consulta los dispositivos detectados:

```sh
flutter devices
```

En Android, inicia un emulador o conecta un dispositivo con depuración USB y ejecuta `flutter run -d <device_id>`. En iOS, usa macOS con Xcode instalado y ejecuta el mismo comando con el identificador del simulador o dispositivo. Para un dispositivo físico, configura `API_BASE_URL` con una dirección del backend accesible desde la red del dispositivo.

## Estructura

```text
lib/
├── core/        Configuración compartida, rutas, red, tema, errores e idioma
└── features/    Funcionalidades por área: autenticación, cuentas, operaciones,
                 dashboard, inicio y administración
test/            Pruebas unitarias y de widgets
web/             Configuración y recursos de Flutter Web
android/         Proyecto nativo Android
ios/             Proyecto nativo iOS
linux/           Proyecto de escritorio Linux
```

En cada funcionalidad, `domain` contiene entidades y casos de uso, `data` integra las fuentes de datos y `presentation` implementa pantallas y estado.

## Comprobaciones y compilación

```sh
flutter analyze
flutter test
flutter build web --release
```

Para una compilación Android: `flutter build apk --release`. Para iOS se requiere macOS y Xcode: `flutter build ios --release`.

## Repositorio relacionado

El servicio API y la configuración local de PostgreSQL y Redis están en [BankOS Backend](https://github.com/BankOs-app/BankOS_Backend). Sigue su README para iniciar el backend y cargar datos locales.
