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
    IconData? icon, // This is for the dropdown arrow
    bool enabled = true,
    String? errorText,
    String? hintText,
    required BuildContext context,
    double? height,
    double? width,
    Widget? prefixIcon, // Added optional prefix icon
  }) {
    final strings = S.of(context);
    final bool hasError = errorText != null && errorText.isNotEmpty;

    final double baseHeight = height ?? 58; // Adjusted default height
    final double fieldWidth = width ?? MediaQuery.of(context).size.width * 0.9;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: fieldWidth,
        minHeight: baseHeight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Important for Column height
        children: [
          // Use Padding to control height if DropdownButtonFormField height is tricky
          DropdownButtonFormField<String>(
            value: value,
            hint: hintText != null
                ? Text(hintText,
                    style: TextStyle(color: context.textSecondaryColor))
                : null,
            onChanged: enabled && items.isNotEmpty ? onChanged : null,
            items: items.isEmpty
                ? [
                    /* No items handling as before */
                  ]
                : items.map<DropdownMenuItem<String>>((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Tooltip(
                        /* Tooltip as before */
                        message: item,
                        child: Text(
                          item,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: enabled
                                ? context.textPrimaryColor
                                : context.textSecondaryColor.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            decoration: InputDecoration(
              // Reduced vertical padding slightly
              contentPadding:
                  EdgeInsets.fromLTRB(prefixIcon != null ? 12 : 16, 14, 12, 14),
              filled: true,
              fillColor: context.formBackgroundColor,
              // Don't pass errorText here, handle it below
              errorText: null,
              labelText: label,
              labelStyle:
                  TextStyle(color: context.textPrimaryColor, fontSize: 14),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: prefixIcon,
              // Use the new prefixIcon parameter
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide.none, // Use BorderSide.none for base border
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  // Show error border color if error exists, otherwise normal
                  color: hasError
                      ? AppColors.error
                      : context.inputBorderEnabledColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  // Show error border color if error exists, otherwise focused
                  color:
                      hasError ? AppColors.error : AppColors.inputBorderFocused,
                  width: 1.5,
                ),
              ),
              // Define errorBorder and focusedErrorBorder for consistency, though errorText is null
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.error, width: 1.5),
              ),
              disabledBorder: OutlineInputBorder(
                // Add disabled state border
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            // Use the original 'icon' parameter for the dropdown arrow
            icon: Icon(
              icon ?? Icons.arrow_drop_down,
              color: enabled
                  ? context.textPrimaryColor
                  : context.textSecondaryColor.withOpacity(0.5),
              size: 22,
            ),
            dropdownColor: context.surfaceColor,
            style: TextStyle(
              fontSize: 14,
              color: enabled
                  ? context.textPrimaryColor
                  : context.textSecondaryColor.withOpacity(0.5),
            ),
            isExpanded: true,
            menuMaxHeight: 300,
            isDense: true, // Use isDense for potentially better height control
          ),
          // Display error text separately below the field
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 12.0),
              child: Text(
                errorText,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  // static Widget normalDropDown({
  //   required String label,
  //   required String? value,
  //   required List<String> items,
  //   Function(String?)? onChanged,
  //   IconData? icon,
  //   bool enabled = true,
  //   String? errorText,
  //   String? hintText,
  //   required BuildContext context,
  //   double? height,
  //   double? width,
  // }) {
  //   final strings = S.of(context);
  //   final bool hasError = errorText != null && errorText.isNotEmpty;
  //
  //   // Consistent base height
  //   final double baseHeight = height ?? 56;
  //   final double fieldWidth = width ?? MediaQuery.of(context).size.width * 0.9;
  //
  //   return LayoutBuilder(
  //     builder: (context, constraints) {
  //       // Calculate max lines dynamically based on available width
  //       final textPainter = TextPainter(
  //         text: TextSpan(
  //           text: errorText,
  //           style: const TextStyle(
  //             color: AppColors.error,
  //             fontSize: 10,
  //           ),
  //         ),
  //         maxLines: 100, // Set a high max to allow full text calculation
  //         textDirection: TextDirection.ltr,
  //       )..layout(maxWidth: constraints.maxWidth - 24); // Subtract padding
  //
  //       // Determine number of lines
  //       final int dynamicMaxLines = textPainter.computeLineMetrics().length;
  //
  //       return ConstrainedBox(
  //         constraints: BoxConstraints(
  //           maxWidth: fieldWidth,
  //           minHeight: baseHeight,
  //           maxHeight: baseHeight + (dynamicMaxLines * 15), // Adjust height based on error text lines
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             DropdownButtonFormField<String>(
  //               value: value,
  //               hint: hintText != null
  //                   ? Text(hintText, style: TextStyle(color: context.textSecondaryColor))
  //                   : null,
  //               onChanged: enabled && items.isNotEmpty
  //                   ? (value) {
  //                 developer.log(
  //                   'Dropdown "$label" value changed to: $value',
  //                   name: 'CustomDropDown',
  //                 );
  //                 onChanged?.call(value);
  //               }
  //                   : null,
  //               items: items.isEmpty
  //                   ? [
  //                 DropdownMenuItem<String>(
  //                   value: null,
  //                   enabled: false,
  //                   child: Text(
  //                     strings.dropdownNoItems,
  //                     style: TextStyle(color: context.textSecondaryColor),
  //                   ),
  //                 )
  //               ]
  //                   : items.map<DropdownMenuItem<String>>((String item) {
  //                 return DropdownMenuItem<String>(
  //                   value: item,
  //                   child: Tooltip(
  //                     message: item,
  //                     child: Text(
  //                       item,
  //                       overflow: TextOverflow.ellipsis,
  //                       style: TextStyle(
  //                         color: enabled
  //                             ? context.textPrimaryColor
  //                             : context.textSecondaryColor.withOpacity(0.5),
  //                         fontSize: 14,
  //                       ),
  //                     ),
  //                   ),
  //                 );
  //               }).toList(),
  //               decoration: InputDecoration(
  //                 contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),  // Reduced padding
  //                 filled: true,
  //                 fillColor: context.formBackgroundColor,
  //                 errorText: null,
  //                 labelText: label,
  //                 labelStyle: TextStyle(color: context.textPrimaryColor, fontSize: 14),
  //                 floatingLabelBehavior: FloatingLabelBehavior.always,
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(8),  // Slightly smaller radius
  //                   borderSide: BorderSide(color: context.inputBorderEnabledColor),
  //                 ),
  //                 enabledBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                   borderSide: BorderSide(color: context.inputBorderEnabledColor),
  //                 ),
  //                 focusedBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                   borderSide: BorderSide(
  //                     color: AppColors.inputBorderFocused,
  //                     width: 1.5,
  //                   ),
  //                 ),
  //               ),
  //               icon: Icon(
  //                 icon ?? Icons.arrow_drop_down,
  //                 color: enabled
  //                     ? context.textPrimaryColor
  //                     : context.textSecondaryColor.withOpacity(0.5),
  //                 size: 22,
  //               ),
  //               dropdownColor: context.surfaceColor,
  //               style: TextStyle(
  //                 fontSize: 14,
  //                 color: enabled
  //                     ? context.textPrimaryColor
  //                     : context.textSecondaryColor.withOpacity(0.5),
  //               ),
  //               isExpanded: true,
  //               menuMaxHeight: 300,
  //               isDense: false,
  //             ),
  //             if (hasError)
  //               Padding(
  //                 padding: const EdgeInsets.only(top: 4.0, left: 12.0),
  //                 child: Text(
  //                   errorText,
  //                   style: const TextStyle(
  //                     color: AppColors.error,
  //                     fontSize: 10,
  //                   ),
  //                   maxLines: dynamicMaxLines, // Use dynamically calculated lines
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

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
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          expansionTileTheme: ExpansionTileThemeData(
            backgroundColor: backgroundColor,
            collapsedBackgroundColor: backgroundColor,
            childrenPadding: EdgeInsets.zero,
          ),
        ),
        child: ExpansionTile(
          leading: Icon(icon, color: context.textPrimaryColor, size: 24),
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
                      leading: Icon(item.icon,
                          color: context.textPrimaryColor, size: 24),
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
  final double? height;
  final double? width;

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
    this.height,
    this.width,
  });

  static String _defaultItemText(dynamic item) {
    if (item is Plaza) return item.plazaName!;
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
                        searchQuery = value.toLowerCase();
                        _filteredItems = widget.items.where((item) {
                          return widget
                              .itemText(item)
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
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return ListTile(
                          title: Text(
                            widget.itemText(item),
                            overflow: TextOverflow.visible,
                          ),
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
    // Use base height without adding additional height for error text
    final double baseHeight = widget.height ?? 60;
    final bool hasError =
        widget.errorText != null && widget.errorText!.isNotEmpty;

    // Use provided width or default
    double fieldWidth = widget.width ?? AppConfig.deviceWidth * 0.9;

    return SizedBox(
      width: fieldWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: baseHeight,
            child: GestureDetector(
              onTap: widget.enabled ? _showSearchDialog : null,
              child: InputDecorator(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: context.formBackgroundColor,
                  // Set error text to null since we'll display it separately like in normalDropDown
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
                    borderSide:
                        BorderSide(color: context.inputBorderEnabledColor),
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
                    borderSide:
                        const BorderSide(color: AppColors.error, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  suffixIcon: Icon(
                    widget.icon ?? Icons.arrow_drop_down,
                    color: widget.enabled
                        ? context.textPrimaryColor
                        : context.textSecondaryColor.withOpacity(0.5),
                    size: 24, // Explicit size for consistency
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Tooltip(
                          message: _selectedItem != null
                              ? widget.itemText(_selectedItem)
                              : '',
                          child: Text(
                            _selectedItem != null
                                ? widget.itemText(_selectedItem)
                                : '',
                            style: TextStyle(
                              color: widget.enabled
                                  ? context.textPrimaryColor
                                  : context.textSecondaryColor.withOpacity(0.5),
                            ),
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Display error text consistently with normalDropDown
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 12.0),
              child: Text(
                widget.errorText!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  height: 1.2,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
