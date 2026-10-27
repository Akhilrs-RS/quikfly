import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedLanguage = 'English (US)';
  bool _pushNotifications = true;
  bool _promotionalAlerts = false;
  bool _biometricLock = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Deep Navy Curved Hero Header Card
            _buildCurvedHeader(context),

            const SizedBox(height: 16),

            // 2. Sections Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION 1: MY ACTIVITY ---
                  _buildSectionHeader('MY ACTIVITY'),
                  const SizedBox(height: 10),
                  _buildMenuItem(
                    icon: Icons.calendar_month_outlined,
                    title: 'Bookings',
                    onTap: () => context.go('/bookings'),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.inventory_2_outlined,
                    title: 'Orders',
                    onTap: () => context.go('/orders'),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.favorite_outline_rounded,
                    title: 'Saved items',
                    onTap: () => _showSavedItemsSheet(context),
                  ),

                  const SizedBox(height: 24),

                  // --- SECTION 2: PAYMENTS & OFFERS ---
                  _buildSectionHeader('PAYMENTS & OFFERS'),
                  const SizedBox(height: 10),
                  _buildMenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Payment methods',
                    onTap: () => _showPaymentMethodsSheet(context),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.confirmation_number_outlined,
                    title: 'Offers & coupons',
                    onTap: () => _showOffersSheet(context),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Receipts',
                    onTap: () => _showReceiptsSheet(context),
                  ),

                  const SizedBox(height: 24),

                  // --- SECTION 3: PREFERENCES ---
                  _buildSectionHeader('PREFERENCES'),
                  const SizedBox(height: 10),
                  _buildMenuItem(
                    icon: Icons.translate_rounded,
                    title: 'Language',
                    onTap: () => _showLanguagePickerSheet(context),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    onTap: () => _showNotificationsSheet(context),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.shield_outlined,
                    title: 'Security & privacy',
                    onTap: () => _showSecuritySheet(context),
                  ),

                  const SizedBox(height: 24),

                  // --- SECTION 4: SUPPORT ---
                  _buildSectionHeader('SUPPORT'),
                  const SizedBox(height: 10),
                  _buildMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Help center',
                    onTap: () => _showHelpCenterSheet(context),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Take the app tour',
                    onTap: () => _showAppTourSheet(context),
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. Deep Navy Curved Hero Header ---
  Widget _buildCurvedHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF071426),
            Color(0xFF0A1F3B),
            Color(0xFF0D2E5C),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Logo & Settings/Tune Button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.electric_bolt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'QuikFly',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showSettingsSheet(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Profile Info Row (Avatar, Name, Phone/City, Chevron)
              GestureDetector(
                onTap: () => _showEditProfileSheet(context),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    // White Circular Avatar
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'AK',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Arjun Kumar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+91 ••••• 48219 • Bengaluru',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white.withOpacity(0.7),
                      size: 22,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // "Account protected" Security Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: Color(0xFF38BDF8),
                      size: 17,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Account protected',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'VERIFIED',
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Section Header ---
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0F172A),
        letterSpacing: 0.3,
      ),
    );
  }

  // --- Menu Item Row ---
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
        child: Row(
          children: [
            // Peach/Cream rounded square with Coral-Orange icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFF95738),
                size: 21,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF64748B),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // --- Thin Divider ---
  Widget _buildDivider() {
    return const Divider(
      color: Color(0xFFF1F5F9),
      height: 1,
      thickness: 1,
      indent: 54,
    );
  }

  // --- Modal Sheets & Actions ---

  void _showEditProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Personal Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            _buildInfoTile('Full Name', 'Arjun Kumar', Icons.person_outline_rounded),
            _buildInfoTile('Phone Number', '+91 98765 48219', Icons.phone_outlined),
            _buildInfoTile('Email Address', 'arjun.kumar@gmail.com', Icons.mail_outline_rounded),
            _buildInfoTile('Current Location', 'Indiranagar, Bengaluru', Icons.location_on_outlined),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Edit Profile Info', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  void _showSavedItemsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saved Items & Wishlist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.restaurant_rounded, color: Color(0xFFF95738)),
              title: const Text('Spice & Co. (Butter Chicken)'),
              subtitle: const Text('Favorite North Indian restaurant'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.hotel_rounded, color: Color(0xFFF95738)),
              title: const Text('Hills Resort, Coorg'),
              subtitle: const Text('Weekend getaways wishlist'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Methods', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.account_balance_rounded, color: AppColors.primary),
              title: const Text('Google Pay / UPI'),
              subtitle: const Text('arjun@okaxis • Default'),
              trailing: const Icon(Icons.check_circle_rounded, color: AppColors.accentGreen),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.credit_card_rounded, color: AppColors.accentPurple),
              title: const Text('HDFC Regalia Credit Card'),
              subtitle: const Text('•••• 8821'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.wallet_rounded, color: Color(0xFFF95738)),
              title: const Text('QuikFly Wallet'),
              subtitle: const Text('Balance: ₹1,450.00'),
              trailing: const Text('Top up', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showOffersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Offers & Promo Coupons', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            _buildCouponCard('WELCOME50', 'Flat 50% off up to ₹100 on your first food order'),
            const SizedBox(height: 10),
            _buildCouponCard('FLYRIDE', 'Flat ₹40 off on 3 bike or car taxi rides'),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponCard(String code, String desc) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF95738).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF95738),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(code, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(desc, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  void _showReceiptsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Download Tax Receipts & Invoices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.receipt_outlined, color: AppColors.primary),
              title: const Text('Invoice #QF-071833'),
              subtitle: const Text('Spice & Co. • ₹436 • 22 Oct 2026'),
              trailing: const Icon(Icons.download_rounded),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_outlined, color: AppColors.primary),
              title: const Text('Invoice #QF-068912'),
              subtitle: const Text('Fresh Basket • ₹782 • 16 Jul 2026'),
              trailing: const Icon(Icons.download_rounded),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePickerSheet(BuildContext context) {
    final languages = ['English (US)', 'Hindi (हिंदी)', 'Kannada (ಕನ್ನಡ)', 'Tamil (தமிழ்)', 'Telugu (తెలుగు)'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select App Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...languages.map(
              (lang) => ListTile(
                title: Text(lang, style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: _selectedLanguage == lang ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                onTap: () {
                  setState(() => _selectedLanguage = lang);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Notification Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Live Trip & Order Updates'),
                subtitle: const Text('Driver arrival and order tracking notifications'),
                value: _pushNotifications,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setModalState(() => _pushNotifications = val);
                  setState(() => _pushNotifications = val);
                },
              ),
              SwitchListTile(
                title: const Text('Promotions & Discounts'),
                subtitle: const Text('Weekend inspiration and curated deals'),
                value: _promotionalAlerts,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setModalState(() => _promotionalAlerts = val);
                  setState(() => _promotionalAlerts = val);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSecuritySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Security & Privacy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Biometric Fingerprint / FaceID'),
                subtitle: const Text('Require unlock on launching QuikFly'),
                value: _biometricLock,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setModalState(() => _biometricLock = val);
                  setState(() => _biometricLock = val);
                },
              ),
              ListTile(
                leading: const Icon(Icons.devices_rounded, color: AppColors.primary),
                title: const Text('Active Sessions'),
                subtitle: const Text('1 phone session active'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpCenterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('QuikFly 24/7 Help & Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
              title: const Text('Live Chat with Support'),
              subtitle: const Text('Typical response time < 2 mins'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.call_outlined, color: AppColors.accentGreen),
              title: const Text('Emergency Helpline'),
              subtitle: const Text('Toll free: 1800-419-7845'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppTourSheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Welcome to QuikFly!'),
        content: const Text(
          'One app for all your everyday services:\n\n'
          '• Bike & Car Taxis with quick pickup\n'
          '• Multi-vendor food & grocery delivery\n'
          '• Intercity buses, car rentals & travels\n'
          '• Verified safety buddy & emergency support',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('App Quick Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark Mode'),
              subtitle: const Text('System default'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('App Version'),
              subtitle: const Text('v1.0.0+1 (QuikFly Build 2026.10)'),
            ),
          ],
        ),
      ),
    );
  }
}
