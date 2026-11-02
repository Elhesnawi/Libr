import 'package:flutter/material.dart';
import 'package:librarry_app/models/library_type.dart';

/// اختيار نوع المكتبة: الكتب الورقية (المكتبة) أو الكتب الرقمية.
class LibraryTypeSelector extends StatelessWidget {
  const LibraryTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final LibraryType selected;
  final ValueChanged<LibraryType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Option(
            icon: Icons.local_library_outlined,
            title: 'المكتبة',
            subtitle: 'الكتب الورقية',
            isSelected: selected == LibraryType.paper,
            onTap: () => onChanged(LibraryType.paper),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Option(
            icon: Icons.tablet_android,
            title: 'الكتب الرقمية',
            subtitle: 'قراءة وتحميل',
            isSelected: selected == LibraryType.digital,
            onTap: () => onChanged(LibraryType.digital),
          ),
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = isSelected ? scheme.onPrimary : scheme.onSurface;

    return Material(
      color: isSelected ? scheme.primary : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, size: 30, color: fg),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: fg),
              ),
              Text(subtitle, style: TextStyle(fontSize: 12, color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}
