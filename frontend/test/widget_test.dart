import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/home/presentation/controllers/home_controller.dart';
import 'package:frontend/main.dart';
import 'package:quikfly_core/quikfly_core.dart';

void main() {
  testWidgets('QuikFlyApp smoke test renders home screen elements', (WidgetTester tester) async {
    const mockFeed = HomeFeedDTO(
      user: UserModel(
        id: 1,
        phone: '+919876543210',
        fullName: 'Akhil R S',
        activeLocality: 'Indiranagar',
        activeCity: 'Bengaluru',
      ),
      heroBanners: [],
      services: [
        ServiceItem(
          id: 1,
          code: 'bike_taxi',
          title: 'Bike Taxi',
          subtitle: 'Fast pickup',
          iconName: 'two_wheeler',
          category: ServiceCategory.everyday,
        ),
      ],
      popularMerchants: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeFeedProvider.overrideWith((ref) => Future.value(mockFeed)),
        ],
        child: const QuikFlyApp(),
      ),
    );

    await tester.pump();

    // Verify brand name & delivery location
    expect(find.text('QuikFly'), findsOneWidget);
    expect(find.text('Delivering to'), findsOneWidget);
    expect(find.text('Indiranagar, Bengaluru'), findsNWidgets(2));
    expect(find.text('What do you need?'), findsOneWidget);
  });
}
