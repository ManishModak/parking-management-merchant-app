import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/models/plaza.dart';
import '../../generated/l10n.dart';
import 'dart:developer' as developer;

class SearchableMultiSelectDropdown extends StatefulWidget {
  final String label;
  final List<String> selectedValues;
  final List<dynamic> items;
  final Function(List<String>) onChanged;
  final bool enabled;
  final String? errorText;
  final String Function(dynamic) itemText;
  final String Function(dynamic) itemValue;
  final double? height;
  final double? width;

  const SearchableMultiSelectDropdown({
    super.key,
    required this.label,
    required this.selectedValues,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.errorText,
    this.itemText = _defaultItemText,
    this.itemValue = _defaultItemValue,
    this.height,
    this.width,
  });

  static String _defaultItemText(dynamic item) =>
      item is Plaza ? '${item.plazaId} - ${item.plazaName}' : item.toString();

  static String _defaultItemValue(dynamic item) =>
      item is Plaza ? item.plazaId! : item.toString();

  @override
  _SearchableMultiSelectDropdownState createState() =>
      _SearchableMultiSelectDropdownState();
}

class _SearchableMultiSelectDropdownState
    extends State<SearchableMultiSelectDropdown> {
  late List<String> _selectedValues;
  late List<dynamic> _filteredItems;
  String _searchQuery = '';
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    _syncSelectedValuesWithItems();
    _filteredItems = List.from(widget.items);
    _selectAll = _selectedValues.length == widget.items.length;
    developer.log(
        'SearchableMultiSelectDropdown initialized with ${_selectedValues.length} selected values',
        name: 'SearchableMultiSelectDropdown');
  }

  @override
  void didUpdateWidget(SearchableMultiSelectDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items ||
        oldWidget.selectedValues != widget.selectedValues) {
      _syncSelectedValuesWithItems();
      _filteredItems = List.from(widget.items);
      _searchQuery = '';
      _selectAll = _selectedValues.length == widget.items.length;
      developer.log(
          'SearchableMultiSelectDropdown updated with ${_selectedValues.length} selected values',
          name: 'SearchableMultiSelectDropdown');
    }
  }

  void _syncSelectedValuesWithItems() {
    // Filter out selected values that don't exist in the current items list
    _selectedValues = widget.selectedValues
        .where((value) => widget.items.any((item) => widget.itemValue(item) == value))
        .toList();
    developer.log('Synced selected values: $_selectedValues',
        name: 'SearchableMultiSelectDropdown');
  }

  void _showMultiSelectDialog() {
    developer.log('Opening multi-select dialog for ${widget.label}',
        name: 'SearchableMultiSelectDropdown');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: S.of(context).labelSearch,
                      prefixIcon: const Icon(Icons.search, size: 24),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: context.inputBorderColor),
                      ),
                      filled: true,
                      fillColor: context.cardColor,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                        _filteredItems = widget.items.where((item) {
                          return widget
                              .itemText(item)
                              .toLowerCase()
                              .contains(_searchQuery);
                        }).toList();
                        developer.log(
                            'Search query: $_searchQuery, filtered items: ${_filteredItems.length}',
                            name: 'SearchableMultiSelectDropdown');
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Select All'),
                    value: _selectAll,
                    onChanged: widget.enabled
                        ? (selected) {
                      setState(() {
                        _selectAll = selected ?? false;
                        if (_selectAll) {
                          _selectedValues = _filteredItems
                              .map((item) => widget.itemValue(item))
                              .toList();
                        } else {
                          _selectedValues.clear();
                        }
                      });
                    }
                        : null,
                  ),
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _filteredItems.length,
                      separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final itemValue = widget.itemValue(item);
                        return CheckboxListTile(
                          title: Text(
                            widget.itemText(item),
                            overflow: TextOverflow.ellipsis,
                          ),
                          value: _selectedValues.contains(itemValue),
                          onChanged: widget.enabled
                              ? (selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedValues.add(itemValue);
                              } else {
                                _selectedValues.remove(itemValue);
                              }
                              _selectAll = _selectedValues.length ==
                                  widget.items.length;
                            });
                          }
                              : null,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          widget.onChanged(_selectedValues);
                          Navigator.pop(context);
                          developer.log('Confirmed selection: $_selectedValues',
                              name: 'SearchableMultiSelectDropdown');
                        },
                        child: Text(S.of(context).buttonOk),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final fieldWidth = widget.width ?? MediaQuery.of(context).size.width * 0.9;
    final baseHeight = widget.height ?? 60;

    return SizedBox(
      width: fieldWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: baseHeight,
            child: GestureDetector(
              onTap: widget.enabled ? _showMultiSelectDialog : null,
              child: InputDecorator(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: context.formBackgroundColor,
                  errorText: null,
                  labelText: widget.label,
                  labelStyle: TextStyle(
                    color: widget.enabled
                        ? context.textPrimaryColor
                        : context.textSecondaryColor.withOpacity(0.5),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.inputBorderEnabledColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.inputBorderFocused, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    const BorderSide(color: AppColors.error, width: 1.5),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  suffixIcon: Icon(
                    Icons.arrow_drop_down,
                    color: widget.enabled
                        ? context.textPrimaryColor
                        : context.textSecondaryColor.withOpacity(0.5),
                    size: 24,
                  ),
                ),
                child: Text(
                  _selectedValues.isEmpty
                      ? ''
                      : _selectedValues
                      .map((v) {
                    try {
                      final item = widget.items.firstWhere(
                            (i) => widget.itemValue(i) == v,
                        orElse: () => null as Plaza?, // Explicit cast
                      );
                      return item != null ? widget.itemText(item) : v;
                    } catch (e) {
                      developer.log(
                        'Error mapping selected value $v: $e',
                        name: 'SearchableMultiSelectDropdown',
                      );
                      return v; // Fallback to raw value
                    }
                  })
                      .join(', '),
                  style: TextStyle(
                    color: widget.enabled
                        ? context.textPrimaryColor
                        : context.textSecondaryColor.withOpacity(0.5),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 12.0),
              child: Text(
                widget.errorText!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

// Extension to handle null safety and mapping
extension ObjectExtension on Object {
  T let<T>(T Function(Object) transform) => transform(this);
}