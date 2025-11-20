// import 'package:flutter/material.dart';
// import 'package:data_table_2/data_table_2.dart';
//
// class CustomDataTable extends StatelessWidget {
//   final List<DataColumn> columns;
//   final List<DataRow> rows;
//   final String emptyMessage;
//   final double heightFactor;
//   final double columnSpacing;
//   final Color headerColor;
//   final TextStyle? headerTextStyle;
//   final TextStyle? dataTextStyle;
//
//   const CustomDataTable({
//     super.key,
//     required this.columns,
//     required this.rows,
//     this.emptyMessage = 'No data found',
//     this.heightFactor = 0.6,
//     this.columnSpacing = 24,
//     this.headerColor = const Color(0xFF3A3A3A),
//     this.headerTextStyle,
//     this.dataTextStyle,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (rows.isEmpty) {
//       return Expanded(
//         child: Container(
//           decoration: _boxDecoration,
//           alignment: Alignment.center,
//           child: Text(
//             emptyMessage,
//             style: const TextStyle(color: Colors.white70, fontSize: 16),
//           ),
//         ),
//       );
//     }
//
//     final size = MediaQuery.of(context).size;
//     final isMobile = size.width < 600;
//
//     final tableHeight = size.height * (isMobile ? 0.5 : heightFactor);
//     return Container(
//       decoration: _boxDecoration,
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final isMobile = constraints.maxWidth < 600;
//
//           final effectiveColumnSpacing = isMobile ? 12.0 : columnSpacing;
//           final effectiveHorizontalMargin = isMobile ? 8.0 : 24.0;
//           final headingHeight = isMobile ? 44.0 : 60.0;
//           final rowHeight = isMobile ? 50.0 : 70.0;
//
//           // 👇 Calculate how wide the table *wants* to be
//           const baseColumnWidth = 120.0; // tweak as needed
//           final desiredWidth = columns.length * baseColumnWidth;
//
//           // 👇 Ensure:
//           // - If content < available width → stretch to full width (no scroll)
//           // - If content > available width → table is wider → horizontal scroll
//           final minTableWidth = desiredWidth < constraints.maxWidth
//               ? constraints.maxWidth
//               : desiredWidth;
//
//           return SizedBox(
//             height: tableHeight,
//             child: DataTable2(
//               fixedTopRows: 1,
//               isVerticalScrollBarVisible: true,
//               isHorizontalScrollBarVisible: true,
//
//               minWidth: minTableWidth,
//               columnSpacing: effectiveColumnSpacing,
//               horizontalMargin: effectiveHorizontalMargin,
//               headingRowHeight: headingHeight,
//               dataRowHeight: rowHeight,
//               dividerThickness: 0,
//
//               headingRowColor: WidgetStateProperty.all(
//                 headerColor.withOpacity(0.6),
//               ),
//               border: TableBorder.all(color: Colors.transparent),
//
//               headingTextStyle: (headerTextStyle ??
//                   const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ))
//                   .copyWith(fontSize: isMobile ? 12 : 14),
//
//               dataTextStyle: (dataTextStyle ??
//                   const TextStyle(
//                     color: Colors.white70,
//                     fontSize: 14,
//                   ))
//                   .copyWith(fontSize: isMobile ? 11 : 14),
//
//               columns: columns,
//               rows: rows,
//             ),
//           );
//         },
//       ),
//     );
//
//   }
//
//   BoxDecoration get _boxDecoration => BoxDecoration(
//     color: Colors.white.withOpacity(0.05),
//     border: Border.all(color: Colors.white.withOpacity(0.2)),
//     borderRadius: BorderRadius.circular(16),
//     boxShadow: [
//       BoxShadow(
//         color: Colors.black.withOpacity(0.2),
//         blurRadius: 8,
//         offset: const Offset(0, 3),
//       ),
//     ],
//   );
// }
//
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

class CustomDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final String emptyMessage;
  final double heightFactor;
  final double columnSpacing;
  final Color headerColor;
  final TextStyle? headerTextStyle;
  final TextStyle? dataTextStyle;
  final Function(int index)? onRowTap;

  const CustomDataTable({
    super.key,
    required this.columns,
    required this.rows,
     this.onRowTap,
    this.emptyMessage = 'No data found',
    this.heightFactor = 0.6,
    this.columnSpacing = 24,
    this.headerColor = const Color(0xFFD01829),
    this.headerTextStyle,
    this.dataTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            emptyMessage,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final tableHeight = size.height * (isMobile ? 0.5 : heightFactor);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        height: tableHeight,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.9),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(1.0),
                offset: const Offset(-5, -5),
                blurRadius: 10,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                offset: const Offset(6, 6),
                blurRadius: 16,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.025),
                offset: const Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                final effectiveColumnSpacing =
                isMobile ? 12.0 : columnSpacing;
                final effectiveHorizontalMargin =
                isMobile ? 12.0 : 16.0;
                final headingHeight = isMobile ? 44.0 : 56.0;
                final rowHeight = isMobile ? 50.0 : 58.0;

                const baseColumnWidth = 120.0;
                final desiredWidth = columns.length * baseColumnWidth;
                final minTableWidth = desiredWidth < constraints.maxWidth
                    ? constraints.maxWidth
                    : desiredWidth;

                return DataTable2(
                  fixedTopRows: 1,
                  isVerticalScrollBarVisible: true,
                  isHorizontalScrollBarVisible: true,

                  showCheckboxColumn: false, // 🚫 no checkboxes

                  minWidth: minTableWidth,
                  columnSpacing: effectiveColumnSpacing,
                  horizontalMargin: effectiveHorizontalMargin,
                  headingRowHeight: headingHeight,
                  dataRowHeight: rowHeight,

                  dividerThickness: 0,
                  border: TableBorder.all(color: Colors.transparent),

                  headingRowColor:
                  MaterialStateProperty.all<Color>(headerColor),
                  headingTextStyle: (headerTextStyle ??
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ))
                      .copyWith(fontSize: isMobile ? 12 : 13),

                  dataTextStyle: (dataTextStyle ??
                      const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 13,
                      ))
                      .copyWith(fontSize: isMobile ? 12 : 13),

                  columns: columns,

                  rows: List.generate(
                    rows.length,
                        (index) {
                      final originalRow = rows[index];
                      final isEven = index.isEven;

                      return DataRow(
                        selected: false,

                        // 👆 cursor on hover
                        mouseCursor:
                        MaterialStateProperty.resolveWith<MouseCursor>(
                              (states) {
                            if (states.contains(MaterialState.hovered)) {
                              return SystemMouseCursors.click;
                            }
                            return SystemMouseCursors.basic;
                          },
                        ),

                        // ⭐ hover + alternating colors
                        color: MaterialStateProperty.resolveWith<Color?>(
                              (states) {
                            if (states.contains(MaterialState.hovered)) {
                              return const Color(0xFFF0F7FF); // hover color
                            }
                            return isEven
                                ? Colors.white
                                : const Color(0xFFF8F8F8);
                          },
                        ),

                        cells: originalRow.cells,

                        // keep row "interactive" so hover state works, but no selection logic needed
                        // 🔔 Row tap → callback with row index
                        onSelectChanged: onRowTap == null
                            ? null
                            : (selected) {
                          if (selected == true) {
                            onRowTap!(index);
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}











