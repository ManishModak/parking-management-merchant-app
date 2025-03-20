import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_theme.dart';
import '../../config/app_config.dart';
import '../../models/plaza.dart';
import '../../views/menu.dart';
import '../../generated/l10n.dart';

class CustomDropDown {
  static Widget normalDropDown({
    required String label,
    required String? value,
    required List<String> items,
    Function(String?)? onChanged,
    IconData? icon,
    bool enabled = true,
    String? errorText,
    String? hintText,
    required BuildContext context,
  }) {
    final strings = S.of(context);
    return SizedBox(
      width: AppConfig.deviceWidth * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: errorText != null && errorText.isNotEmpty ? 80 : 60,
            child: DropdownButtonFormField<String>(
              value: value,
              hint: hintText != null
                  ? Text(hintText, style: TextStyle(color: context.textSecondaryColor))
                  : null,
              onChanged: enabled && items.isNotEmpty
                  ? (value) {
                developer.log(
                  'Dropdown "$label" value changed to: $value',
                  name: 'CustomDropDown',
                );
                onChanged?.call(value);
              }
                  : null,
              items: items.isEmpty
                  ? [
                DropdownMenuItem<String>(
                  value: null,
                  enabled: false,
                  child: Text(
                    strings.dropdownNoItems,
                    style: TextStyle(color: context.textSecondaryColor),
                  ),
                )
              ]
                  : items.map<DropdownMenuItem<String>>((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: enabled
                          ? context.textPrimaryColor
                          : context.textSecondaryColor.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                filled: true,
                fillColor: context.formBackgroundColor,
                errorText: errorText?.isEmpty ?? true ? null : errorText,
                errorStyle: const TextStyle(height: 1.2),
                errorMaxLines: 5,
                labelText: label,
                labelStyle: TextStyle(color: context.textPrimaryColor),
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
                    color: AppColors.inputBorderFocused,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
              icon: Icon(
                icon ?? Icons.arrow_drop_down,
                color: enabled
                    ? context.textPrimaryColor
                    : context.textSecondaryColor.withOpacity(0.5),
              ),
              dropdownColor: context.surfaceColor,
              style: TextStyle(
                fontSize: 16,
                color: enabled
                    ? context.textPrimaryColor
                    : context.textSecondaryColor.withOpacity(0.5),
              ),
              isExpanded: true,
            ),
          ),
        ],
      ),
    );
  }

  static Widget expansionDropDown({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<MenuCardItem> items,
    required Color backgroundColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent, // Remove splash effect
          highlightColor: Colors.transparent, // Remove highlight effect
          expansionTileTheme: ExpansionTileThemeData(
            backgroundColor: backgroundColor,
            collapsedBackgroundColor: backgroundColor,
            childrenPadding: EdgeInsets.zero,
          ),
        ),
        child: ExpansionTile(
          leading: Icon(icon, color: context.textPrimaryColor),
          title: Text(
            title,
            style: TextStyle(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: items
              .map((item) => Container(
            color: backgroundColor,
            child: ListTile(
              splashColor: Colors.transparent,
              leading: Icon(item.icon, color: context.textPrimaryColor),
              title: Text(
                item.title,
                style: TextStyle(
                  color: context.textPrimaryColor,
                ),
              ),
              onTap: () {
                developer.log(
                  'Expansion dropdown item tapped: ${item.title}',
                  name: 'CustomDropDown',
                );
                item.onTap?.call();
              },
            ),
          ))
              .toList(),
        ),
      ),
    );
  }
}

// SearchableDropdown remains unchanged as it has a different design purpose
class SearchableDropdown extends StatefulWidget {
  final String label;
  final String? value;
  final List<dynamic> items;
  final Function(dynamic) onChanged;
  final bool enabled;
  final String? errorText;
  final IconData? icon;
  final String Function(dynamic) itemText;
  final String Function(dynamic) itemValue;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.errorText,
    this.icon,
    this.itemText = _defaultItemText,
    this.itemValue = _defaultItemValue,
  });

  static String _defaultItemText(dynamic item) {
    if (item is Plaza) return item.plazaName;
    return item.toString();
  }

  static String _defaultItemValue(dynamic item) {
    if (item is Plaza) return item.plazaId!;
    return item.toString();
  }

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  late dynamic _selectedItem;
  late List<dynamic> _filteredItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.items);
    _updateSelectedItem();
    developer.log(
      'SearchableDropdown initialized with value: ${widget.value}',
      name: 'CustomDropDown',
    );
  }

  @override
  void didUpdateWidget(SearchableDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items || oldWidget.value != widget.value) {
      _filteredItems = List.from(widget.items);
      _updateSelectedItem();
      developer.log(
        'SearchableDropdown updated with new value: ${widget.value}',
        name: 'CustomDropDown',
      );
    }
  }

  void _updateSelectedItem() {
    if (widget.value == null || widget.value!.isEmpty) {
      _selectedItem = null;
      return;
    }

    try {
      _selectedItem = widget.items.firstWhere(
            (item) => widget.itemValue(item).toString() == widget.value.toString(),
      );
    } catch (e) {
      developer.log(
        'Item not found in SearchableDropdown: ${widget.value}',
        name: 'CustomDropDown',
        error: e,
      );
      _selectedItem = null;
    }
  }

  void _showSearchDialog() {
    String searchQuery = '';
    developer.log(
      'Searchable dropdown opened for label: ${widget.label}',
      name: 'CustomDropDown',
    );

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
                      labelText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: context.inputBorderColor),
                      ),
                      filled: true,
                      fillColor: context.cardColor,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                        _filteredItems = widget.items.where((item) {
                          return widget.itemText(item)
                              .toLowerCase()
                              .contains(searchQuery);
                        }).toList();
                        developer.log(
                          'Search query updated: $searchQuery, filtered items: ${_filteredItems.length}',
                          name: 'CustomDropDown',
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _filteredItems.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return ListTile(
                          title: Text(widget.itemText(item)),
                          onTap: () {
                            developer.log(
                              'Selected item: ${widget.itemText(item)}',
                              name: 'CustomDropDown',
                            );
                            widget.onChanged(item);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
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
    return SizedBox(
      width: AppConfig.deviceWidth * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: widget.errorText != null ? 80 : 60,
            child: GestureDetector(
              onTap: widget.enabled ? _showSearchDialog : null,
              child: InputDecorator(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: context.formBackgroundColor,
                  errorText: widget.errorText,
                  errorStyle: const TextStyle(height: 0.8),
                  labelText: widget.label,
                  labelStyle: TextStyle(
                    color: widget.enabled
                        ? context.textPrimaryColor
                        : context.textSecondaryColor.withOpacity(0.5),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.inputBorderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.inputBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.inputBorderFocused,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.error, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  suffixIcon: Icon(
                    widget.icon ?? Icons.arrow_drop_down,
                    color: context.textPrimaryColor,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _selectedItem != null ? widget.itemText(_selectedItem) : '',
                        style: TextStyle(
                          color: widget.enabled
                              ? context.textPrimaryColor
                              : context.textSecondaryColor.withOpacity(0.5),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}