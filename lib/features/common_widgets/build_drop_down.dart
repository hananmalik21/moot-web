import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moot_web/features/common_widgets/custom_dropdown.dart';

class BuildDropdown<T> extends StatelessWidget {
  final String title;
  final String label;
  final String searchHint;
  final bool isEnable;
  final bool showSearch;
  final bool isLoadingMore;
  final TextEditingController controller;
  final TextEditingController searchController;
  final Function(T val) onChange;
  final bool searchLoading;
  final List<T> options;
  final Function(String val) onSearch;
  final Function(String val) onPagination;
  final String Function(T) displayField;
  final EdgeInsets? padding;

  const BuildDropdown({
    super.key,
    required this.title,
    required this.label,
    required this.searchHint,
    this.isEnable = false,
    this.showSearch = true,
    required this.isLoadingMore,
    required this.controller,
    required this.searchController,
    required this.onChange,
    required this.searchLoading,
    this.padding,
    required this.options,
    required this.onSearch,
    required this.onPagination,
    required this.displayField,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??  EdgeInsets.only(bottom: 20.h),
      child: CustomDropdown<T>(
        title: title,
        hintText: label,
        showSearch: showSearch,
        isEnable: isEnable,
        searchHintText: searchHint,
        searchLoading: searchLoading,
        options: options,
        onSearch: onSearch,
        displayField: displayField,
        onSelect: onChange,
        controller: controller,
        pagination: onPagination,
        isLoadingMore: isLoadingMore,
        searchController: searchController,
      ),
    );
  }
}
