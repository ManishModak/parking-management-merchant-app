import 'package:flutter/material.dart';
import 'package:merchant_app/models/menu_item.dart';
import '../../config/app_colors.dart';
import '../../config/app_config.dart';
import '../../models/plaza.dart';

class CustomDropDown {
  static Widget normalDropDown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    IconData? icon,
    bool enabled = true,
    String? errorText,
  }) {
    return SizedBox(
      width: AppConfig.deviceWidth * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: errorText != null ? 80 : 60,
            child: DropdownButtonFormField<String>(
              value: value,
              onChanged: enabled ? onChanged : null,
              items: items.map<DropdownMenuItem<String>>((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: enabled
                          ? AppColors.textPrimary
                          : AppColors.textDisabled,
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.formBackground,
                errorText: errorText,
                errorStyle: const TextStyle(
                  height: 0.8,
                ),
                labelText: label,
                labelStyle: const TextStyle(color: AppColors.primary),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
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
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
              dropdownColor: AppColors.formBackground,
              style: const TextStyle(fontSize: 16),
              isExpanded: true,
            ),
          ),
        ],
      ),
    );
  }

  static Widget expansionDropDown({
    required String title,
    required IconData icon,
    required List<MenuCardItem> items,
    Color iconColor = Colors.black,
    Color textColor = AppColors.textPrimary,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.primaryCard,
      child: ExpansionTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        children: items
            .map((item) => ListTile(
                  leading: Icon(item.icon, color: iconColor),
                  title: Text(
                    item.title,
                    style: TextStyle(color: textColor),
                  ),
                  onTap: item.onTap,
                ))
            .toList(),
      ),
    );
  }
}

class SearchableDropdown extends StatefulWidget {
  final String label;
  final String? value; // Change to match how you're passing the plaza ID
  final List<dynamic> items;
  final Function(dynamic) onChanged;
  final bool enabled;
  final String? errorText;
  final IconData? icon;
  final String Function(dynamic)? itemText; // Change to non-nullable
  final String Function(dynamic)? itemValue; // Change to non-nullable

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.errorText,
    this.icon,
    this.itemText = _defaultItemText, // Provide a default implementation
    this.itemValue = _defaultItemValue, // Provide a default implementation
  });

  // Default methods if not provided
  static String _defaultItemText(dynamic item) {
    if (item is Plaza) return item.plazaName ?? '';
    return item.toString();
  }

  // In SearchableDropdown class
  static String _defaultItemValue(dynamic item) {
    if (item is Plaza) return item.plazaId!; // Already a string
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
    _filteredItems = List.from(widget.items); // Initialize with current items
    _updateSelectedItem();
  }

  @override
  void didUpdateWidget(SearchableDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items || oldWidget.value != widget.value) {
      _filteredItems = List.from(widget.items); // Update with new items
      _updateSelectedItem();
    }
  }

  void _updateSelectedItem() {
    if (widget.value == null || widget.value!.isEmpty) {
      _selectedItem = null;
      return;
    }

    try {
      _selectedItem = widget.items.firstWhere(
            (item) => widget.itemValue!(item).toString() == widget.value.toString(),
      );
    } catch (e) {
      print("Item not found: ${widget.value}");
      _selectedItem = null;
    }
  }

  void _showSearchDialog() {
    String searchQuery = '';

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
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                        _filteredItems = widget.items.where((item) {
                          return widget.itemText!(item)
                              .toLowerCase()
                              .contains(searchQuery);
                        }).toList();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _filteredItems.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return ListTile(
                          title: Text(widget.itemText!(item)),
                          onTap: () {
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
                  fillColor: AppColors.formBackground,
                  errorText: widget.errorText,
                  errorStyle: const TextStyle(height: 0.8),
                  labelText: widget.label,
                  labelStyle: TextStyle(
                    color: widget.enabled
                        ? AppColors.primary
                        : AppColors.textDisabled,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
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
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  suffixIcon: Icon(
                    widget.icon ?? Icons.arrow_drop_down,
                    color: AppColors.primary,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _selectedItem != null
                            ? widget.itemText!(_selectedItem)
                            : '',
                        style: TextStyle(
                          color: widget.enabled
                              ? AppColors.textPrimary
                              : AppColors.textDisabled,
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
