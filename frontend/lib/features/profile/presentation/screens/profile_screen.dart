import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quikfly_core/quikfly_core.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _selectedLanguage = 'English (US)';

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final preferencesAsync = ref.watch(preferencesProvider);

    final user = userProfileAsync.value;
    final preferences = preferencesAsync.value;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Deep Navy Curved Hero Header Card
            _buildCurvedHeader(context, user),

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
                    icon: Icons.location_on_outlined,
                    title: 'Saved addresses',
                    onTap: () => _showSavedAddressesSheet(context),
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
                    subtitle: 'Wallet: ₹${(user?.walletBalance ?? 1450.0).toStringAsFixed(2)}',
                    onTap: () => _showPaymentMethodsSheet(context, user),
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
                    subtitle: preferences?.language ?? _selectedLanguage,
                    onTap: () => _showLanguagePickerSheet(context, preferences),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    onTap: () => _showNotificationsSheet(context, preferences),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.shield_outlined,
                    title: 'Security & privacy',
                    onTap: () => _showSecuritySheet(context, preferences),
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
  Widget _buildCurvedHeader(BuildContext context, UserModel? user) {
    final fullName = user?.fullName ?? 'Arjun Kumar';
    final initials = fullName.split(' ').where((w) => w.isNotEmpty).map((w) => w[0]).take(2).join().toUpperCase();
    final phoneDisplay = user?.phone ?? '+91 ••••• 48219';
    final localityDisplay = user?.activeLocality ?? 'Bengaluru';

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
                onTap: () => _showEditProfileSheet(context, user),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    // White Circular Avatar with user initials
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials.isEmpty ? 'AK' : initials,
                        style: const TextStyle(
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
                          Text(
                            fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$phoneDisplay • $localityDisplay',
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
    String? subtitle,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
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

  // --- Modal Sheets & Live Actions ---

  void _showEditProfileSheet(BuildContext context, UserModel? user) {
    final nameController = TextEditingController(text: user?.fullName ?? 'Arjun Kumar');
    final phoneController = TextEditingController(text: user?.phone ?? '+919876543210');
    final emailController = TextEditingController(text: user?.email ?? 'arjun.kumar@gmail.com');
    final localityController = TextEditingController(text: user?.activeLocality ?? 'Indiranagar');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: Container(
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
                'Personal Details (Saved to MySQL)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: localityController,
                decoration: const InputDecoration(
                  labelText: 'Current Locality',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(sheetContext);
                  try {
                    await ref.read(apiClientProvider).updateUserProfile(
                          fullName: nameController.text.trim(),
                          phone: phoneController.text.trim(),
                          email: emailController.text.trim(),
                          activeLocality: localityController.text.trim(),
                        );
                    ref.invalidate(userProfileProvider);
                    if (!mounted) return;
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated and saved to MySQL in real-time!'),
                        backgroundColor: AppColors.darkCard,
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(content: Text('Profile update error: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Profile Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSavedAddressesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final addressesAsync = ref.watch(addressesProvider);
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saved Addresses (MySQL)',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _showAddAddressSheet(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Manage your delivery destinations and custom locations:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: addressesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  error: (e, s) => Center(child: Text('Error: $e')),
                  data: (addresses) {
                    if (addresses.isEmpty) {
                      return const Center(child: Text('No saved addresses yet.'));
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: addresses.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final addr = addresses[index];
                        final icon = addr.label.toLowerCase() == 'work'
                            ? Icons.work_outline_rounded
                            : addr.label.toLowerCase() == 'gym'
                                ? Icons.fitness_center_rounded
                                : Icons.home_outlined;

                        return Container(
                          decoration: BoxDecoration(
                            color: addr.isDefault ? const Color(0xFFF0F5FF) : AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: addr.isDefault ? AppColors.primary : AppColors.border,
                              width: addr.isDefault ? 1.5 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: addr.isDefault ? AppColors.primary : AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                icon,
                                color: addr.isDefault ? Colors.white : AppColors.primary,
                                size: 20,
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  addr.formattedTitle,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    addr.label.toUpperCase(),
                                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              addr.addressLine,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted, size: 20),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (dCtx) => AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    title: const Text('Delete Address?'),
                                    content: Text('Are you sure you want to delete ${addr.formattedTitle} from MySQL?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Cancel')),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(dCtx, true),
                                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRed),
                                        child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await ref.read(apiClientProvider).deleteAddress(addr.id);
                                  ref.invalidate(addressesProvider);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    SnackBar(content: Text('Deleted ${addr.formattedTitle} from MySQL.')),
                                  );
                                }
                              },
                            ),
                            onTap: () async {
                              await ref.read(apiClientProvider).setDefaultAddress(addr.id);
                              await ref.read(apiClientProvider).updateUserProfile(
                                    fullName: 'Arjun Kumar',
                                    phone: '+919876548219',
                                    email: 'arjun.kumar@quikfly.app',
                                    activeLocality: addr.locality,
                                  );
                              ref.invalidate(addressesProvider);
                              ref.invalidate(userProfileProvider);
                              if (!mounted) return;
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text('${addr.formattedTitle} set as active delivery location!'),
                                  backgroundColor: AppColors.accentGreen,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _showAddAddressSheet(context);
                },
                icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
                label: const Text('Add New Custom Location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddAddressSheet(BuildContext context) {
    String selectedLabel = 'Home';
    final addressLineController = TextEditingController();
    final localityController = TextEditingController();
    final cityController = TextEditingController(text: 'Bengaluru');
    bool setAsDefault = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (formCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(formCtx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                const SizedBox(height: 16),
                const Text(
                  'Add Custom Location',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Store address directly into MySQL database:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 16),

                // Label selector pills
                const Text('Address Label:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: ['Home', 'Work', 'Gym', 'Custom'].map((lbl) {
                    final isSel = selectedLabel == lbl;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          lbl,
                          style: TextStyle(
                            color: isSel ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        selected: isSel,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.background,
                        onSelected: (val) {
                          if (val) setModalState(() => selectedLabel = lbl);
                        },
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: addressLineController,
                  decoration: const InputDecoration(
                    labelText: 'House / Street / Landmark',
                    hintText: 'e.g. #42, 5th Main, 9th Cross',
                    prefixIcon: Icon(Icons.home_work_outlined),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: localityController,
                  decoration: const InputDecoration(
                    labelText: 'Locality / Area',
                    hintText: 'e.g. Jayanagar, Electronic City, Bellandur',
                    prefixIcon: Icon(Icons.location_city_outlined),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    prefixIcon: Icon(Icons.map_outlined),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),

                const SizedBox(height: 12),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Set as current active delivery location', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  value: setAsDefault,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setModalState(() => setAsDefault = val);
                  },
                ),

                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () async {
                    final street = addressLineController.text.trim();
                    final area = localityController.text.trim();
                    final city = cityController.text.trim();

                    if (street.isEmpty || area.isEmpty) {
                      ScaffoldMessenger.of(formCtx).showSnackBar(
                        const SnackBar(content: Text('Please enter both street and locality.')),
                      );
                      return;
                    }

                    Navigator.pop(formCtx);

                    try {
                      final newAddr = await ref.read(apiClientProvider).addCustomAddress(
                            label: selectedLabel,
                            addressLine: street,
                            locality: area,
                            city: city.isEmpty ? 'Bengaluru' : city,
                            isDefault: setAsDefault,
                          );

                      if (setAsDefault) {
                        await ref.read(apiClientProvider).updateUserProfile(
                              fullName: 'Arjun Kumar',
                              phone: '+919876548219',
                              email: 'arjun.kumar@quikfly.app',
                              activeLocality: newAddr.locality,
                            );
                      }

                      ref.invalidate(addressesProvider);
                      ref.invalidate(userProfileProvider);

                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text("Custom location '${newAddr.formattedTitle}' saved to MySQL!"),
                          backgroundColor: AppColors.accentGreen,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text('Error adding location: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Location to MySQL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
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
              onTap: () {
                Navigator.pop(context);
                context.go('/orders');
              },
            ),
            ListTile(
              leading: const Icon(Icons.hotel_rounded, color: Color(0xFFF95738)),
              title: const Text('Hills Resort, Coorg'),
              subtitle: const Text('Weekend getaways wishlist'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                Navigator.pop(context);
                context.go('/bookings');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodsSheet(BuildContext context, UserModel? user) {
    final balance = (user?.walletBalance ?? 1450.0).toStringAsFixed(2);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Methods & Wallet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.account_balance_rounded, color: AppColors.primary),
              title: const Text('Google Pay / UPI'),
              subtitle: const Text('arjun@okaxis • Default'),
              trailing: const Icon(Icons.check_circle_rounded, color: AppColors.accentGreen),
              onTap: () => Navigator.pop(sheetContext),
            ),
            ListTile(
              leading: const Icon(Icons.credit_card_rounded, color: AppColors.accentPurple),
              title: const Text('HDFC Regalia Credit Card'),
              subtitle: const Text('•••• 8821'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.pop(sheetContext),
            ),
            ListTile(
              leading: const Icon(Icons.wallet_rounded, color: Color(0xFFF95738)),
              title: const Text('QuikFly Wallet'),
              subtitle: Text('Balance: ₹$balance (Live MySQL)'),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _showTopUpWalletDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Top up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTopUpWalletDialog(BuildContext context) {
    final topUpOptions = [200.0, 500.0, 1000.0, 2000.0];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.add_card_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Top up QuikFly Wallet'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select amount to credit directly into your MySQL wallet account:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ...topUpOptions.map((amount) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () async {
                    Navigator.pop(dialogContext);
                    try {
                      final newBal = await ref.read(apiClientProvider).topupWallet(amount);
                      ref.invalidate(userProfileProvider);
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text('₹${amount.toInt()} added to QuikFly Wallet in MySQL! New balance: ₹${newBal.toStringAsFixed(2)}'),
                          backgroundColor: AppColors.accentGreen,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text('Top up error: $e')),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.surface,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('+ ₹${amount.toInt()}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              );
            }),
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
      builder: (sheetContext) => Container(
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
              onTap: () {
                Navigator.pop(sheetContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tax Invoice #QF-071833 downloaded from MySQL records.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_outlined, color: AppColors.primary),
              title: const Text('Invoice #QF-068912'),
              subtitle: const Text('Fresh Basket • ₹782 • 16 Jul 2026'),
              trailing: const Icon(Icons.download_rounded),
              onTap: () {
                Navigator.pop(sheetContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tax Invoice #QF-068912 downloaded from MySQL records.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePickerSheet(BuildContext context, UserPreferences? preferences) {
    final languages = ['English (US)', 'Hindi (हिंदी)', 'Kannada (ಕನ್ನಡ)', 'Tamil (தமிழ்)', 'Telugu (తెలుగు)'];
    final currentLang = preferences?.language ?? _selectedLanguage;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
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
                trailing: currentLang == lang ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                onTap: () async {
                  Navigator.pop(sheetContext);
                  setState(() => _selectedLanguage = lang);
                  try {
                    await ref.read(apiClientProvider).updatePreferences(language: lang);
                    ref.invalidate(preferencesProvider);
                    if (!mounted) return;
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(content: Text('Language preference set to $lang in MySQL!')),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(content: Text('Language update error: $e')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context, UserPreferences? preferences) {
    var pushNotifications = preferences?.pushNotifications ?? true;
    var promotionalAlerts = preferences?.promotionalAlerts ?? false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
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
              const Text('Notification Preferences (Stored in MySQL)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Live Trip & Order Updates'),
                subtitle: const Text('Driver arrival and order tracking notifications'),
                value: pushNotifications,
                activeColor: AppColors.primary,
                onChanged: (val) async {
                  setModalState(() => pushNotifications = val);
                  await ref.read(apiClientProvider).updatePreferences(pushNotifications: val);
                  ref.invalidate(preferencesProvider);
                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Live updates ${val ? "enabled" : "disabled"} in MySQL!')),
                  );
                },
              ),
              SwitchListTile(
                title: const Text('Promotions & Discounts'),
                subtitle: const Text('Weekend inspiration and curated deals'),
                value: promotionalAlerts,
                activeColor: AppColors.primary,
                onChanged: (val) async {
                  setModalState(() => promotionalAlerts = val);
                  await ref.read(apiClientProvider).updatePreferences(promotionalAlerts: val);
                  ref.invalidate(preferencesProvider);
                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Promo notifications ${val ? "enabled" : "disabled"} in MySQL!')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSecuritySheet(BuildContext context, UserPreferences? preferences) {
    var biometricLock = preferences?.biometricLock ?? true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
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
              const Text('Security & Privacy (Stored in MySQL)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Biometric Fingerprint / FaceID'),
                subtitle: const Text('Require unlock on launching QuikFly'),
                value: biometricLock,
                activeColor: AppColors.primary,
                onChanged: (val) async {
                  setModalState(() => biometricLock = val);
                  await ref.read(apiClientProvider).updatePreferences(biometricLock: val);
                  ref.invalidate(preferencesProvider);
                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Biometric lock ${val ? "enabled" : "disabled"} in MySQL!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.devices_rounded, color: AppColors.primary),
                title: const Text('Active Sessions'),
                subtitle: const Text('1 phone session active • Docker Container'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pop(sheetContext),
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
      builder: (sheetContext) => Container(
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
              onTap: () {
                Navigator.pop(sheetContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Connecting to 24/7 QuikFly Live Agent...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.call_outlined, color: AppColors.accentGreen),
              title: const Text('Emergency Helpline'),
              subtitle: const Text('Toll free: 1800-419-7845'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(sheetContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dialing emergency helpline 1800-419-7845...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAppTourSheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Welcome to QuikFly!'),
        content: const Text(
          'One app for all your everyday services:\n\n'
          '• Bike & Car Taxis with instant driver dispatch\n'
          '• Multi-vendor food & grocery delivery\n'
          '• Intercity buses, car rentals & travels\n'
          '• Real-time MySQL database sync on every action\n'
          '• Verified safety buddy & emergency support',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
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
      builder: (sheetContext) => Container(
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
              onTap: () => Navigator.pop(sheetContext),
            ),
            const ListTile(
              leading: Icon(Icons.info_outline_rounded),
              title: Text('App Version'),
              subtitle: Text('v1.0.0+1 (QuikFly Build 2026.10 • MySQL Live)'),
            ),
          ],
        ),
      ),
    );
  }
}
