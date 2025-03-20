import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'dart:developer' as developer;
import '../../generated/l10n.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChange;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final iconTheme = Theme.of(context).iconTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.first_page,
            color: currentPage > 1
                ? iconTheme.color ?? context.textPrimaryColor
                : (iconTheme.color ?? context.textPrimaryColor).withOpacity(0.5),
          ),
          padding: const EdgeInsets.all(12),
          onPressed: currentPage > 1
              ? () {
            developer.log('First page button pressed', name: 'PaginationControls');
            onPageChange(1);
          }
              : null,
          tooltip: strings.tooltipFirstPage,
        ),
        IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: currentPage > 1
                ? iconTheme.color ?? context.textPrimaryColor
                : (iconTheme.color ?? context.textPrimaryColor).withOpacity(0.5),
          ),
          padding: const EdgeInsets.all(12),
          onPressed: currentPage > 1
              ? () {
            developer.log('Previous page button pressed', name: 'PaginationControls');
            onPageChange(currentPage - 1);
          }
              : null,
          tooltip: strings.tooltipPreviousPage,
        ),
        Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: context.shadowColor.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '$currentPage / $totalPages',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: context.textPrimaryColor,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.chevron_right,
            color: currentPage < totalPages
                ? iconTheme.color ?? context.textPrimaryColor
                : (iconTheme.color ?? context.textPrimaryColor).withOpacity(0.5),
          ),
          padding: const EdgeInsets.all(12),
          onPressed: currentPage < totalPages
              ? () {
            developer.log('Next page button pressed', name: 'PaginationControls');
            onPageChange(currentPage + 1);
          }
              : null,
          tooltip: strings.tooltipNextPage,
        ),
        IconButton(
          icon: Icon(
            Icons.last_page,
            color: currentPage < totalPages
                ? iconTheme.color ?? context.textPrimaryColor
                : (iconTheme.color ?? context.textPrimaryColor).withOpacity(0.5),
          ),
          padding: const EdgeInsets.all(12),
          onPressed: currentPage < totalPages
              ? () {
            developer.log('Last page button pressed', name: 'PaginationControls');
            onPageChange(totalPages);
          }
              : null,
          tooltip: strings.tooltipLastPage,
        ),
      ],
    );
  }
}