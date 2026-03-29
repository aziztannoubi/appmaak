import 'package:flutter/material.dart';

class HealthHumanScreen extends StatefulWidget {
  const HealthHumanScreen({super.key});

  @override
  State<HealthHumanScreen> createState() => _HealthHumanScreenState();
}

class _HealthHumanScreenState extends State<HealthHumanScreen> {
  bool _insulineOn = true;
  bool _glycemiaOn = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.arrow_back, size: 20),
                  const Spacer(),
                  Text(
                    'Santé humaine',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _SosMedicalCard(theme: theme),
              const SizedBox(height: 14),
              _SectionHeader(
                title: 'Mes Rendez-vous',
                actionLabel: 'Voir tout',
                onActionTap: () {},
              ),
              const SizedBox(height: 8),
              _MonthStrip(theme: theme),
              const SizedBox(height: 10),
              _AppointmentCard(theme: theme),
              const SizedBox(height: 14),
              _SectionHeader(
                title: 'Rappels',
                actionLabel: 'Ajouter',
                onActionTap: () {},
              ),
              const SizedBox(height: 10),
              _ReminderTile(
                color: const Color(0xFFFFF3E0),
                iconColor: const Color(0xFFF39C12),
                icon: Icons.medication_outlined,
                title: 'Insuline',
                subtitle: '08:00 - Avant repas',
                value: _insulineOn,
                onChanged: (value) => setState(() => _insulineOn = value),
              ),
              const SizedBox(height: 10),
              _ReminderTile(
                color: const Color(0xFFE8F3FF),
                iconColor: const Color(0xFF3498DB),
                icon: Icons.medical_services_outlined,
                title: 'Contrôle Glycémie',
                subtitle: '12:00 - Quotidien',
                value: _glycemiaOn,
                onChanged: (value) => setState(() => _glycemiaOn = value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SosMedicalCard extends StatelessWidget {
  const _SosMedicalCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A8E81),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              'SOS',
              style: theme.textTheme.labelLarge?.copyWith(
                color: const Color(0xFF0A8E81),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SOS Médical',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Alerte immédiate & contact urgence',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onActionTap,
          child: Text(
            actionLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF2E86DE),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthStrip extends StatelessWidget {
  const _MonthStrip({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    const dayLabels = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];
    const dayNumbers = ['25', '26', '27', '28', '29', '30', '1'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.chevron_left, color: Color(0xFF727272)),
              const Spacer(),
              Text(
                'Octobre 2023',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Color(0xFF727272)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(dayLabels.length, (index) {
              final isSelected = index == 3;
              return Column(
                children: [
                  Text(
                    dayLabels[index],
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF8A8A8A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNumbers[index],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AUJOURD'HUI - 14:30",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF2E86DE),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dr. Amine - Cardiologue',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Clinique El Amen, Tunis',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6E6E6E),
                  ),
                ),
              ],
            ),
          ),
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFEDEDED),
            child: Icon(Icons.person, color: Color(0xFF8F8F8F)),
          ),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.color,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final Color color;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF7C7C7C),
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
