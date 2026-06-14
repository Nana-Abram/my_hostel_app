import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/ui/about%20us/about_screen.dart';
import 'package:my_hostel_app/ui/contact%20us/contact_screen.dart';
import 'package:my_hostel_app/ui/core/responsive.dart';
import 'package:my_hostel_app/ui/home/home_screen.dart';
import 'package:my_hostel_app/ui/hostels/hostel_screen.dart';
import 'package:my_hostel_app/ui/widgets/elv_button_widget.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/nav_button_widget.dart';
import 'package:my_hostel_app/ui/widgets/user_avatar.dart';

class AppBarScreen extends ConsumerStatefulWidget {
  const AppBarScreen({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  ConsumerState<AppBarScreen> createState() => AppBarScreenState();
}

class AppBarScreenState extends ConsumerState<AppBarScreen> {
  late int _selectedIndex;

  final List<Widget> _pages = const [
    HomeScreen(),
    HostelsScreen(),
    AboutScreen(),
    ContactScreen(),
  ];

  static const _navItems = [
    (label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home),
    (label: 'Hostels', icon: Icons.apartment_outlined, activeIcon: Icons.apartment),
    (label: 'About', icon: Icons.info_outline, activeIcon: Icons.info),
    (label: 'Contact', icon: Icons.mail_outline, activeIcon: Icons.mail),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void onNavSelected(int index) {
    setState(() => _selectedIndex = index);
    Navigator.of(context).maybePop(); // close drawer if open
    if (index == 0) {
      GoRouter.of(context).goNamed('home');
    } else {
      GoRouter.of(context).goNamed(
        'tabs',
        pathParameters: {'tabIndex': index.toString()},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context, r, theme),
      endDrawer: r.isMobile ? _buildDrawer(context, theme) : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: _pages[_selectedIndex],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
      BuildContext context, Responsive r, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final appBarH = r.appBarHeight;

    return PreferredSize(
      preferredSize: Size.fromHeight(appBarH),
      child: Container(
        height: appBarH,
        padding: EdgeInsets.symmetric(horizontal: r.pagePadding),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Logo ───────────────────────────────────────────────────────
            GestureDetector(
              onTap: () => GoRouter.of(context).go('/'),
              child: Row(
                children: [
                  _LogoBox(size: r.isMobile ? 32 : 40, theme: theme),
                  if (!r.isMobile) ...[
                    const SizedBox(width: 10),
                    Text(
                      'HostelHub',
                      style: TextStyle(
                        fontSize: r.h4,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Spacer(),

            // ── Center nav (tablet / desktop) ──────────────────────────────
            if (!r.isMobile)
              Row(
                children: List.generate(_navItems.length, (i) {
                  final item = _navItems[i];
                  return NavButtonWidget(
                    text: item.label,
                    isActive: _selectedIndex == i,
                    onPressed: () => onNavSelected(i),
                  );
                }),
              ),

            if (!r.isMobile) const SizedBox(width: 24),

            // ── Right section ──────────────────────────────────────────────
            Consumer(builder: (context, ref, _) {
              final user = ref.watch(authProvider).value;
              return r.isMobile
                  ? _MobileRightSection(
                      user: user,
                      onMenuTap: () => Scaffold.of(context).openEndDrawer(),
                      onUserMenuTap: _buildUserMenu,
                    )
                  : _DesktopRightSection(
                      user: user,
                      theme: theme,
                      r: r,
                      onNavDashboard: () =>
                          GoRouter.of(context).goNamed('dashboard'),
                      onUserMenu: _buildUserMenu,
                      onToggleTheme: () => _toggleTheme(context),
                      getGreeting: _getGreeting,
                    );
            }),
          ],
        ),
      ),
    );
  }

  // ── Mobile end-drawer ─────────────────────────────────────────────────────

  Widget _buildDrawer(BuildContext context, ThemeData theme) {
    final user = ref.read(authProvider).value;
    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  _LogoBox(size: 36, theme: theme),
                  const SizedBox(width: 12),
                  Text(
                    'HostelHub',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Nav items
            ...List.generate(_navItems.length, (i) {
              final item = _navItems[i];
              final isActive = _selectedIndex == i;
              return ListTile(
                leading: Icon(
                  isActive ? item.activeIcon : item.icon,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                title: Text(
                  item.label,
                  style: TextStyle(
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                selected: isActive,
                selectedTileColor:
                    theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                onTap: () => onNavSelected(i),
              );
            }),

            const Divider(),
            const Spacer(),

            // Auth / user section at bottom of drawer
            Padding(
              padding: const EdgeInsets.all(16),
              child: user == null
                  ? Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              GoRouter.of(context).push('/login');
                            },
                            child: const Text('Login'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              GoRouter.of(context).push('/signup');
                            },
                            child: const Text('Sign Up'),
                          ),
                        ),
                      ],
                    )
                  : ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: UserAvatar(user: user, size: 36),
                      title: Text(
                        user.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        user.role.displayName,
                        style: TextStyle(
                            color:
                                theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                      trailing: Tooltip(
                        message: 'Dashboard',
                        child: IconButton(
                          icon: Icon(Icons.dashboard,
                              color: theme.colorScheme.primary),
                          onPressed: () {
                            Navigator.pop(context);
                            GoRouter.of(context).goNamed('dashboard');
                          },
                        ),
                      ),
                    ),
            ),

            // Theme toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _ThemeToggleTile(onToggle: () => _toggleTheme(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserMenu(UserModel currentUser) {
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => _buildUserMenuItems(currentUser, theme),
      onSelected: (value) => _handleUserMenuSelection(value, context),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: theme.colorScheme.primary, width: 1.5),
        ),
        child: IgnorePointer(child: UserAvatar(user: currentUser, size: 40)),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildUserMenuItems(
      UserModel user, ThemeData theme) {
    return [
      PopupMenuItem<String>(
        value: 'profile',
        child: _MenuRow(
            icon: Icons.person,
            label: 'My Profile',
            color: theme.colorScheme.onSurfaceVariant),
      ),
      if (user.role == UserRole.admin) ...[
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'manage_hostels',
          child: _MenuRow(
              icon: Icons.apartment,
              label: 'Manage Hostels',
              color: theme.colorScheme.primary),
        ),
      ],
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'logout',
        child: _MenuRow(
            icon: Icons.logout,
            label: 'Logout',
            color: theme.colorScheme.error),
      ),
    ];
  }

  void _handleUserMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'profile':
        GoRouter.of(context).push('/profile');
        break;
      case 'manage_hostels':
        GoRouter.of(context).goNamed('dashboard');
        break;
      case 'logout':
        _handleLogout(context);
        break;
    }
  }

  void _handleLogout(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text('Confirm Logout',
            style: TextStyle(color: theme.colorScheme.onSurface)),
        content: Text('Are you sure you want to logout?',
            style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) GoRouter.of(context).go('/');
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logout failed: $e')));
                }
              }
            },
            child: Text('Logout',
                style: TextStyle(color: theme.colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _toggleTheme(BuildContext context) {
    final mode = AdaptiveTheme.of(context).mode;
    if (mode.isLight) {
      AdaptiveTheme.of(context).setDark();
    } else {
      AdaptiveTheme.of(context).setLight();
    }
  }

  String _getGreeting(UserModel user) {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _LogoBox extends StatelessWidget {
  final double size;
  final ThemeData theme;
  const _LogoBox({required this.size, required this.theme});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(size * 0.25),
        ),
        child: Center(
          child: Text(
            'H',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: size * 0.5,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
      );
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MenuRow(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontSize: 13)),
        ],
      );
}

class _ThemeToggleTile extends StatelessWidget {
  final VoidCallback onToggle;
  const _ThemeToggleTile({required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = AdaptiveTheme.of(context).mode.isLight;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(isLight ? Icons.dark_mode : Icons.light_mode,
          color: theme.colorScheme.onSurface),
      title: Text(isLight ? 'Dark Mode' : 'Light Mode',
          style: TextStyle(color: theme.colorScheme.onSurface)),
      onTap: onToggle,
    );
  }
}

/// Desktop right section (logged-in or not)
class _DesktopRightSection extends StatelessWidget {
  final UserModel? user;
  final ThemeData theme;
  final Responsive r;
  final VoidCallback onNavDashboard;
  final Widget Function(UserModel) onUserMenu;
  final VoidCallback onToggleTheme;
  final String Function(UserModel) getGreeting;

  const _DesktopRightSection({
    required this.user,
    required this.theme,
    required this.r,
    required this.onNavDashboard,
    required this.onUserMenu,
    required this.onToggleTheme,
    required this.getGreeting,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (user == null) ...[
          ElvButtonWidget(
            text: 'Login',
            onPressed: () => GoRouter.of(context).push('/login'),
          ),
          const SizedBox(width: 12),
          ElvButtonWidget(
            text: 'Sign Up',
            onPressed: () => GoRouter.of(context).push('/signup'),
            isPrimary: true,
          ),
        ] else ...[
          // Dashboard shortcut
          Tooltip(
            message: 'Dashboard',
            child: GestureDetector(
              onTap: onNavDashboard,
              child: IconAndTextWidget(
                icon: Icons.dashboard,
                text: 'Dashboard',
                iconColor: theme.colorScheme.primary,
                iconSize: 20,
                textSize: r.bodySmall,
                textColor: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Greeting + role badge
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                getGreeting(user!),
                style: TextStyle(
                  fontSize: r.bodySmall,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              Text(
                user!.fullName,
                style: TextStyle(
                  fontSize: r.caption,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (user!.role != UserRole.student)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 9, 115, 201),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    user!.role.displayName,
                    style: TextStyle(
                      fontSize: r.caption,
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          onUserMenu(user!),
        ],
        const SizedBox(width: 12),
        // Theme toggle
        IconButton(
          onPressed: onToggleTheme,
          icon: Icon(
            AdaptiveTheme.of(context).mode.isLight
                ? Icons.dark_mode
                : Icons.light_mode,
            color: theme.colorScheme.onSurface,
          ),
          tooltip: AdaptiveTheme.of(context).mode.isLight
              ? 'Dark Mode'
              : 'Light Mode',
        ),
      ],
    );
  }
}

/// Mobile right section (hamburger + optional avatar)
class _MobileRightSection extends StatelessWidget {
  final UserModel? user;
  final VoidCallback onMenuTap;
  final Widget Function(UserModel) onUserMenuTap;

  const _MobileRightSection({
    required this.user,
    required this.onMenuTap,
    required this.onUserMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (user != null) onUserMenuTap(user!),
        const SizedBox(width: 4),
        IconButton(
          icon: Icon(Icons.menu,
              size: 26, color: theme.colorScheme.onSurface),
          onPressed: onMenuTap,
        ),
      ],
    );
  }
}