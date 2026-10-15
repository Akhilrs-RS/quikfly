import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onTap;

  const SearchBarWidget({
    super.key,
    this.hintText = 'Search rides, food, shops and more',
    this.onChanged,
    this.onFilterTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1.2),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onTap: onTap,
                onChanged: onChanged,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.normal,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Container(
              height: 24,
              width: 1,
              color: AppColors.border,
            ),
            IconButton(
              icon: const Icon(
                Icons.tune_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
              onPressed: onFilterTap,
              splashRadius: 18,
            ),
          ],
        ),
      ),
    );
  }
}
