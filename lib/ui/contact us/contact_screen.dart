import 'package:flutter/material.dart';
import 'package:my_hostel_app/ui/core/responsive.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
          horizontal: r.pagePadding, vertical: r.spacingXL),
      child: Column(
        children: [
          _buildHeader(r, theme),
          SizedBox(height: r.spacingXXL),
          _buildContactMethods(context, r, theme),
          SizedBox(height: r.spacingXXL),
          _buildContactForm(context, r, theme),
          SizedBox(height: r.spacingXL),
          _buildFAQ(r, theme),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(Responsive r, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Get In Touch',
          style: TextStyle(
              fontSize: r.h1,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface),
        ),
        SizedBox(height: r.spacingM),
        Text(
          'We\'re here to help you find your perfect student accommodation',
          style: TextStyle(
              fontSize: r.bodyLarge,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        SizedBox(height: r.spacingL),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: r.isMobile ? 16 / 9 : 21 / 7,
            child:
                Image.asset('assets/images/contact2.jpg', fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }

  // ── Contact methods + office hours ────────────────────────────────────────

  Widget _buildContactMethods(
      BuildContext context, Responsive r, ThemeData theme) {
    final leftCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: TextStyle(
              fontSize: r.h3,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface),
        ),
        SizedBox(height: r.spacingM),
        Text(
          'Choose your preferred method to reach out to us. Our team is always '
          'ready to assist you with any questions about hostels, bookings, or partnerships.',
          style: TextStyle(
              fontSize: r.body,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.6),
        ),
        SizedBox(height: r.spacingXL),
        ...[
          (
            icon: Icons.phone,
            title: 'Call Us',
            subtitle: 'Available 24/7 for urgent inquiries',
            contact: '+233 12 345 6789'
          ),
          (
            icon: Icons.email,
            title: 'Email Us',
            subtitle: 'We respond within 2 hours',
            contact: 'support@hostelhub.com'
          ),
          (
            icon: Icons.chat,
            title: 'Live Chat',
            subtitle: 'Instant help from our team',
            contact: 'Start Chat'
          ),
          (
            icon: Icons.location_on,
            title: 'Visit Us',
            subtitle: 'Come say hello at our office',
            contact: 'University of Energy and Natural Resource, Sunyani'
          ),
        ]
            .map((c) => Padding(
                  padding: EdgeInsets.only(bottom: r.spacingM),
                  child: _ContactCard(
                    icon: c.icon,
                    title: c.title,
                    subtitle: c.subtitle,
                    contact: c.contact,
                    r: r,
                    theme: theme,
                  ),
                ))
            .toList(),
      ],
    );

    final rightCol = Container(
      padding: EdgeInsets.all(r.cardPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Office Hours',
            style: TextStyle(
                fontSize: r.h4,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface),
          ),
          SizedBox(height: r.spacingL),
          _OfficeHourRow('Monday – Friday', '9:00 AM – 6:00 PM', r, theme),
          _OfficeHourRow('Saturday', '10:00 AM – 4:00 PM', r, theme),
          _OfficeHourRow('Sunday', 'Emergency Support Only', r, theme),
          SizedBox(height: r.spacingL),
          Container(
            padding: EdgeInsets.all(r.spacingM),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber,
                    color: theme.colorScheme.tertiary,
                    size: r.isMobile ? 18 : 20),
                SizedBox(width: r.spacingM),
                Expanded(
                  child: Text(
                    'For urgent hostel emergencies outside office hours, '
                    'call our 24/7 support line.',
                    style: TextStyle(
                        fontSize: r.bodySmall,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (r.isMobile) {
      return Column(children: [
        leftCol,
        SizedBox(height: r.spacingXL),
        rightCol,
      ]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: leftCol),
        SizedBox(width: r.spacingXL),
        Expanded(child: rightCol),
      ],
    );
  }

  // ── Contact form ──────────────────────────────────────────────────────────

  Widget _buildContactForm(
      BuildContext context, Responsive r, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Send Us a Message',
          style: TextStyle(
              fontSize: r.h3,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface),
        ),
        SizedBox(height: r.spacingL),
        _ContactForm(r: r, theme: theme),
      ],
    );
  }

  // ── FAQ ───────────────────────────────────────────────────────────────────

  Widget _buildFAQ(Responsive r, ThemeData theme) {
    final faqs = [
      (
        q: 'How do I book a hostel?',
        a: 'Browse available hostels, select your preferred room, and follow the booking steps. You\'ll receive confirmation via email.'
      ),
      (
        q: 'What payment methods are accepted?',
        a: 'We accept mobile money, bank transfers, and major credit/debit cards through our secure payment gateway.'
      ),
      (
        q: 'Can I cancel my booking?',
        a: 'Yes, cancellations are allowed up to 48 hours before check-in. Please review the hostel\'s specific cancellation policy.'
      ),
      (
        q: 'How are hostels verified?',
        a: 'Our team personally visits and inspects each hostel before listing. We check safety, hygiene, and amenity standards.'
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: TextStyle(
              fontSize: r.h3,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface),
        ),
        SizedBox(height: r.spacingL),
        ...faqs.map((f) => Padding(
              padding: EdgeInsets.only(bottom: r.spacingM),
              child: _FAQCard(q: f.q, a: f.a, r: r, theme: theme),
            )),
      ],
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String contact;
  final Responsive r;
  final ThemeData theme;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.contact,
    required this.r,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.spacingM),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: r.isMobile ? 20 : 24,
                color: theme.colorScheme.primary),
          ),
          SizedBox(width: r.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: r.h5,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface)),
                SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: r.bodySmall,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                SizedBox(height: 4),
                Text(contact,
                    style: TextStyle(
                        fontSize: r.body,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.primary)),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
        ],
      ),
    );
  }
}

class _OfficeHourRow extends StatelessWidget {
  final String day;
  final String hours;
  final Responsive r;
  final ThemeData theme;
  const _OfficeHourRow(this.day, this.hours, this.r, this.theme);

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: r.spacingM),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(day,
                style: TextStyle(
                    fontSize: r.body,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
            Text(hours,
                style: TextStyle(
                    fontSize: r.body,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface)),
          ],
        ),
      );
}

class _FAQCard extends StatefulWidget {
  final String q;
  final String a;
  final Responsive r;
  final ThemeData theme;
  const _FAQCard(
      {required this.q,
      required this.a,
      required this.r,
      required this.theme});

  @override
  State<_FAQCard> createState() => _FAQCardState();
}

class _FAQCardState extends State<_FAQCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.r;
    final theme = widget.theme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.q,
                style: TextStyle(
                    fontSize: r.body,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface)),
            trailing: Icon(
              _open ? Icons.expand_less : Icons.expand_more,
              color: theme.colorScheme.primary,
            ),
            onTap: () => setState(() => _open = !_open),
          ),
          if (_open)
            Padding(
              padding: EdgeInsets.fromLTRB(
                  r.spacingM, 0, r.spacingM, r.spacingM),
              child: Text(
                widget.a,
                style: TextStyle(
                    fontSize: r.body,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.5),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Contact Form ──────────────────────────────────────────────────────────────

class _ContactForm extends StatefulWidget {
  final Responsive r;
  final ThemeData theme;
  const _ContactForm({required this.r, required this.theme});

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _loading = false);
    _formKey.currentState!.reset();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(children: [
          Icon(Icons.check_circle,
              color: widget.theme.colorScheme.secondary),
          const SizedBox(width: 8),
          const Text('Message Sent!'),
        ]),
        content: const Text(
            'Thank you! We\'ll get back to you within 2 hours.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.r;
    final theme = widget.theme;
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding:
          EdgeInsets.symmetric(horizontal: r.spacingM, vertical: r.spacingM),
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Name row — stacks on mobile
          r.isMobile
              ? Column(children: [
                  TextFormField(
                      controller: _firstNameCtrl,
                      decoration:
                          inputDecoration.copyWith(labelText: 'First Name *'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null),
                  SizedBox(height: r.spacingM),
                  TextFormField(
                      controller: _lastNameCtrl,
                      decoration:
                          inputDecoration.copyWith(labelText: 'Last Name *'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null),
                ])
              : Row(children: [
                  Expanded(
                    child: TextFormField(
                        controller: _firstNameCtrl,
                        decoration:
                            inputDecoration.copyWith(labelText: 'First Name *'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null),
                  ),
                  SizedBox(width: r.spacingM),
                  Expanded(
                    child: TextFormField(
                        controller: _lastNameCtrl,
                        decoration:
                            inputDecoration.copyWith(labelText: 'Last Name *'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null),
                  ),
                ]),
          SizedBox(height: r.spacingM),
          TextFormField(
              controller: _emailCtrl,
              decoration: inputDecoration.copyWith(labelText: 'Email *'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'Invalid email' : null),
          SizedBox(height: r.spacingM),
          TextFormField(
              controller: _subjectCtrl,
              decoration: inputDecoration.copyWith(labelText: 'Subject *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null),
          SizedBox(height: r.spacingM),
          TextFormField(
              controller: _messageCtrl,
              maxLines: r.isMobile ? 4 : 5,
              decoration:
                  inputDecoration.copyWith(labelText: 'Your Message *'),
              validator: (v) => (v == null || v.trim().length < 10)
                  ? 'Message too short'
                  : null),
          SizedBox(height: r.spacingL),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: r.spacingM),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: _loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary))
                  : Text('Send Message',
                      style: TextStyle(
                          fontSize: r.body, fontWeight: FontWeight.w600)),
            ),
          ),
          SizedBox(height: r.spacingS),
          Text('* Required fields',
              style: TextStyle(
                  fontSize: r.bodySmall,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}