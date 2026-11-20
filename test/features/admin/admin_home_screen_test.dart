import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:bankos_frontend/core/localization/app_locale_provider.dart';
import 'package:bankos_frontend/features/admin/presentation/screens/admin_home_screen.dart';
import 'package:bankos_frontend/features/auth/domain/entities/user_entity.dart';
import 'package:bankos_frontend/features/auth/presentation/providers/auth_notifier.dart';
import 'package:bankos_frontend/features/auth/presentation/providers/auth_providers.dart';
import 'package:bankos_frontend/features/auth/presentation/providers/auth_state.dart';

void main() {
  testWidgets(
      'AdminHomeScreen - Perfil del Administrador diseño limpio idéntico al mockup (Foto 5)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AdminHomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on Profile nav item
    final perfilNavFinder = find.text('Perfil');
    expect(perfilNavFinder, findsOneWidget);
    await tester.tap(perfilNavFinder);
    await tester.pumpAndSettle();

    // Verify title and identity elements
    expect(find.text('Mi Perfil'), findsOneWidget);
    expect(find.text('Luigui Garizado'), findsOneWidget);
    expect(find.text('admin@bankos.com'), findsOneWidget);
    expect(find.text('Cuenta Verificada'), findsOneWidget);

    // Verify Menu List items
    expect(find.text('Datos Institucionales'), findsOneWidget);
    expect(find.text('Seguridad'), findsOneWidget);
    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('Ayuda y Soporte'), findsOneWidget);

    // Verify Logout button
    expect(find.text('Cerrar sesión'), findsOneWidget);

    // Verify opening Datos Institucionales modal
    await tester.tap(find.text('Datos Institucionales'));
    await tester.pumpAndSettle();

    expect(find.text('ID de Matrícula'), findsOneWidget);
    expect(find.text('ADM-88392-COL'), findsOneWidget);
    expect(find.text('Entidad Asignada'), findsOneWidget);
    expect(find.text('Código Institucional'), findsOneWidget);
    expect(find.text('Nivel de Acceso'), findsOneWidget);
    expect(find.text('Protocolo de Seguridad'), findsOneWidget);

    // Close modal
    await tester.tap(find.text('Cerrar'));
    await tester.pumpAndSettle();
  });

  testWidgets(
      'AdminHomeScreen - Solo SuperAdmin puede crear nuevos bancos; Admin de banco NO ve crear',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Caso SuperAdmin (admin@bankos.com) -> Sí tiene pestaña Crear
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => _MockSuperAdminNotifier()),
        ],
        child: const MaterialApp(
          home: AdminHomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Crear'), findsOneWidget);

    // 2. Caso Admin de Banco Nu (admin@nu.com) -> NO TIENE pestaña Crear
    await tester.pumpWidget(
      ProviderScope(
        key: const ValueKey('nu_scope'),
        overrides: [
          authNotifierProvider.overrideWith(() => _MockNuAdminNotifier()),
        ],
        child: const MaterialApp(
          home: AdminHomeScreen(key: ValueKey('nu_admin')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Pestaña "Crear" NO debe existir para el administrador de banco local
    expect(find.text('Crear'), findsNothing);
    expect(find.text('Auditoría'), findsOneWidget);
    expect(find.text('Operaciones'), findsOneWidget);
  });

  testWidgets(
      'AdminHomeScreen - Operaciones de la Institución con Panel Desplegable y sin banners descriptivos',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AdminHomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on Operaciones
    final opsNavFinder = find.text('Operaciones');
    expect(opsNavFinder, findsOneWidget);
    await tester.tap(opsNavFinder);
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Operaciones de la Institución'), findsOneWidget);

    // Verify NO existe el banner morado descriptivo
    expect(find.textContaining('Tu perfil tiene permisos para auditar logs'), findsNothing);

    // Verify Libro Mayor visible directamente
    expect(find.textContaining('Libro Mayor:'), findsOneWidget);
    expect(find.text('Todas'), findsOneWidget);
    expect(find.text('Depósitos'), findsOneWidget);
    expect(find.text('Retiros'), findsOneWidget);
    expect(find.text('Transferencias'), findsOneWidget);

    // Verify botón desplegable de marca
    final toggleBrandingFinder = find.textContaining('Personalizar Marca y Colores');
    expect(toggleBrandingFinder, findsOneWidget);

    // Inicialmente los controles de edición de tarjeta están ocultos
    expect(find.text('••••   ••••   ••••   8821'), findsNothing);

    // Al presionar el botón desplegable, se expande
    await tester.tap(toggleBrandingFinder);
    await tester.pumpAndSettle();

    expect(find.text('••••   ••••   ••••   8821'), findsOneWidget);
    expect(find.text('Guardar y Aplicar Identidad de Marca'), findsOneWidget);
  });

  testWidgets(
      'AdminHomeScreen - Admin de banco local (ej. Nu) TAMBIÉN puede personalizar colores y marca de su entidad',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => _MockNuAdminNotifier()),
        ],
        child: const MaterialApp(
          home: AdminHomeScreen(key: ValueKey('nu_admin_ops')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on Operaciones (index 1 for local admin)
    final opsNavFinder = find.text('Operaciones');
    expect(opsNavFinder, findsOneWidget);
    await tester.tap(opsNavFinder);
    await tester.pumpAndSettle();

    // Verify botón desplegable de marca está disponible para el admin local
    final toggleBrandingFinder =
        find.textContaining('Personalizar Marca y Colores');
    expect(toggleBrandingFinder, findsOneWidget);

    // Expandir personalización de marca
    await tester.tap(toggleBrandingFinder);
    await tester.pumpAndSettle();

    // Admin local puede guardar y aplicar identidad de marca
    expect(find.text('Guardar y Aplicar Identidad de Marca'), findsOneWidget);
  });

  testWidgets(
      'AdminHomeScreen - Cambio de idioma a inglés reactivo en toda la interfaz',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    late WidgetRef capturedRef;
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, child) {
            capturedRef = ref;
            return const MaterialApp(
              home: AdminHomeScreen(),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Cambiar idioma a inglés
    capturedRef.read(localeNotifierProvider.notifier).setLanguage(AppLanguage.en);
    await tester.pumpAndSettle();

    // Verificar que los botones de navegación cambiaron a inglés
    expect(find.text('Create'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Audit'), findsOneWidget);
    expect(find.text('Operations'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Navegar a perfil en inglés
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Verified Account'), findsOneWidget);
    expect(find.text('Institutional Data'), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);
  });
}

class _MockSuperAdminNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState(
        status: AuthStatus.authenticated,
        user: UserEntity(
          id: 'user_super_admin',
          email: 'admin@bankos.com',
          name: 'Luigui Garizado',
          role: UserRole.admin,
        ),
      );
}

class _MockNuAdminNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState(
        status: AuthStatus.authenticated,
        user: UserEntity(
          id: 'user_nu_admin',
          email: 'admin@nu.com',
          name: 'Admin Banco Nu',
          role: UserRole.admin,
        ),
      );
}
