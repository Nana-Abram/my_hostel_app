import 'package:flutter/material.dart';
import 'package:my_hostel_app/ui/app_bar/app_bar_screen.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/core/responsive.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
          horizontal: r.pagePadding, vertical: r.spacingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, r, theme),
          SizedBox(height: r.spacingXXL),
          _buildMission(r, theme),
          SizedBox(height: r.spacingXXL),
          _buildFeatures(r, theme),
          SizedBox(height: r.spacingXXL),
          _buildStats(r, theme),
          SizedBox(height: r.spacingXL),
          _buildCTA(context, r, theme),
          SizedBox(height: r.spacingL),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, Responsive r, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About HostelHub',
          style: TextStyle(
            fontSize: r.h1,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: r.spacingM),
        Text(
          'Your Gateway to Comfortable Student Living',
          style: TextStyle(
            fontSize: r.bodyLarge,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: r.spacingL),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            // Taller on mobile, wider on desktop
            aspectRatio: r.isMobile ? 16 / 9 : 21 / 7,
            child: Image.asset(
              'assets/images/new.jpg',
              fit: BoxFit.cover,
              cacheWidth: (MediaQuery.sizeOf(context).width *
                      MediaQuery.devicePixelRatioOf(context))
                  .round(),
            ),
          ),
        ),
      ],
    );
  }

  // ── Mission ───────────────────────────────────────────────────────────────

  Widget _buildMission(Responsive r, ThemeData theme) {
    final textCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our Mission',
          style: TextStyle(
              fontSize: r.h3,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface),
        ),
        SizedBox(height: r.spacingM),
        Text(
          'At HostelHub, we believe that finding the perfect student accommodation '
          'should be simple, transparent, and stress-free. We\'re dedicated to '
          'connecting students with safe, affordable, and comfortable living spaces '
          'near their educational institutions.',
          style: TextStyle(
            fontSize: r.body,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.6,
          ),
        ),
        SizedBox(height: r.spacingM),
        Text(
          'Our platform brings together hostel owners and students, creating a '
          'seamless marketplace that prioritises safety, convenience, and community.',
          style: TextStyle(
            fontSize: r.body,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.6,
          ),
        ),
      ],
    );

    final infoCard = Container(
      padding: EdgeInsets.all(r.cardPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(Icons.school, size: r.isMobile ? 40 : 50,
              color: theme.colorScheme.primary),
          SizedBox(height: r.spacingM),
          Text(
            'For Students',
            style: TextStyle(
                fontSize: r.h4,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary),
          ),
          SizedBox(height: r.spacingS),
          SmallText(
            text: 'Find your perfect home away from home with verified listings '
                'and transparent pricing.',
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ],
      ),
    );

    if (r.isMobile) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [textCol, SizedBox(height: r.spacingL), infoCard]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: textCol),
        SizedBox(width: r.spacingXL),
        Expanded(child: infoCard),
      ],
    );
  }

  // ── Features ──────────────────────────────────────────────────────────────

  Widget _buildFeatures(Responsive r, ThemeData theme) {
    final features = [
      (icon: Icons.verified_user, title: 'Verified Listings',
          desc: 'Every hostel is personally verified for safety and quality standards'),
      (icon: Icons.price_check, title: 'Transparent Pricing',
          desc: 'No hidden costs. See exactly what you\'ll pay upfront'),
      (icon: Icons.map, title: 'Campus Proximity',
          desc: 'Find hostels within walking distance to your institution'),
      (icon: Icons.support_agent, title: '24/7 Support',
          desc: 'Our team is always here to help you with any concerns'),
      (icon: Icons.reviews, title: 'Student Reviews',
          desc: 'Real feedback from students who\'ve lived there'),
      (icon: Icons.payment, title: 'Easy Booking',
          desc: 'Secure online booking with multiple payment options'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Why Choose HostelHub?',
            style: TextStyle(
                fontSize: r.h3,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface)),
        SizedBox(height: r.spacingS),
        Text(
          'We\'re revolutionising student accommodation with technology and trust',
          style: TextStyle(
              fontSize: r.body,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        SizedBox(height: r.spacingXL),
        LayoutBuilder(builder: (context, constraints) {
          // 1 col mobile, 2 cols tablet, 3 cols desktop
          final cols = r.gridColumns;
          final spacing = r.spacingM;
          final cardW =
              (constraints.maxWidth - spacing * (cols - 1)) / cols;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: features.map((f) {
              return SizedBox(
                width: cardW,
                child: Container(
                  padding: EdgeInsets.all(r.cardPadding),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(r.spacingS),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(f.icon,
                            size: r.isMobile ? 22 : 26,
                            color: theme.colorScheme.primary),
                      ),
                      SizedBox(height: r.spacingM),
                      Text(
                        f.title,
                        style: TextStyle(
                            fontSize: r.h5,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface),
                      ),
                      SizedBox(height: r.spacingS),
                      Text(
                        f.desc,
                        style: TextStyle(
                            fontSize: r.bodySmall,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  // ── Team ──────────────────────────────────────────────────────────────────

  // ── Stats ─────────────────────────────────────────────────────────────────

  Widget _buildStats(Responsive r, ThemeData theme) {
    final stats = [
      (value: '500+', label: 'Hostels Listed'),
      (value: '10,000+', label: 'Students Housed'),
      (value: '15+', label: 'Campuses Served'),
      (value: '98%', label: 'Satisfaction Rate'),
    ];

    return Container(
      padding: EdgeInsets.all(r.cardPadding * 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.blueColor, AppColors.blueColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: r.isMobile
          ? Wrap(
              spacing: r.spacingL,
              runSpacing: r.spacingL,
              alignment: WrapAlignment.spaceAround,
              children: stats.map((s) => _StatItem(s.value, s.label, r)).toList(),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  stats.map((s) => _StatItem(s.value, s.label, r)).toList(),
            ),
    );
  }

  // ── CTA ───────────────────────────────────────────────────────────────────

  Widget _buildCTA(BuildContext context, Responsive r, ThemeData theme) {
    final button = ElevatedButton(
      onPressed: () {
        final state = context.findAncestorStateOfType<AppBarScreenState>();
        state?.onNavSelected(1);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blueColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
            horizontal: r.spacingXL, vertical: r.spacingM),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child:
          Text('Browse Hostels', style: TextStyle(fontSize: r.body, fontWeight: FontWeight.w600)),
    );

    final textCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ready to Find Your Perfect Hostel?',
          style: TextStyle(
              fontSize: r.h3,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface),
        ),
        SizedBox(height: r.spacingM),
        Text(
          'Join thousands of students who have found their ideal accommodation '
          'through HostelHub. Start your search today!',
          style: TextStyle(
              fontSize: r.body,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5),
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.all(r.cardPadding * 1.5),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: r.isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textCol,
                SizedBox(height: r.spacingL),
                SizedBox(width: double.infinity, child: button),
              ],
            )
          : Row(
              children: [
                Expanded(child: textCol),
                SizedBox(width: r.spacingL),
                button,
              ],
            ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Responsive r;
  const _StatItem(this.value, this.label, this.r);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: r.h1,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: r.body,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500)),
        ],
      );
}