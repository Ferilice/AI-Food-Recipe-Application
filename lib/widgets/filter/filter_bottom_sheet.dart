import 'package:flutter/material.dart';

import '../../database/enums/recipe_tag.dart';

/// A widget that manages filter options for recipes
/// used in [RecipesBrowse] to filter recipes by categories and calories
class FilterBottomSheet extends StatefulWidget {
  final Function? onSubmitted;
  final RangeValues? initCalRange;
  final Map<String, RecipeTag>? initSelCategories;

  const FilterBottomSheet(
      {super.key, this.onSubmitted, this.initCalRange, this.initSelCategories});

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  Map<String, RecipeTag> categories = {'สุขภาพ': RecipeTag.healthy, 'อาหารคีโต': RecipeTag.keto
    , 'มังสวิรัติ': RecipeTag.vegan, 'ลดน้ำหนัก': RecipeTag.diet};

  Map<String, RecipeTag> selectedCategories = {};
  RangeValues caloriesRange = RangeValues(0, 1000);

  @override
  void initState() {
    super.initState();
    selectedCategories = widget.initSelCategories ?? {};
    caloriesRange = widget.initCalRange ?? RangeValues(0, 1000);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = theme.colorScheme.secondary;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ตัวกรองการค้นหา',
                style: theme.textTheme.titleLarge,
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text('หมวดหมู่', style: theme.textTheme.titleMedium),
          Wrap(
            spacing: 8,
            children: categories.entries.map((entry) {
              bool isSelected = selectedCategories.containsKey(entry.key);
              return ChoiceChip(
                label: Text(entry.key, style: TextStyle(color: Colors.white)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedCategories[entry.key] = entry.value;
                    } else {
                      selectedCategories.remove(entry.key);
                    }
                  });
                },
                selectedColor: secondaryColor,
                backgroundColor: Color(0xFF858597),
                shape: StadiumBorder(),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('จำนวนแคลอรี่', style: theme.textTheme.titleMedium),
              Text(
                ' (${caloriesRange.start.round()} - ${caloriesRange.end.round()} แคล)',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          RangeSlider(
            values: caloriesRange,
            min: 0,
            max: 1000,
            divisions: 20,
            labels: RangeLabels(
              '${caloriesRange.start.round()} แคล',
              '${caloriesRange.end.round()} แคล',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                caloriesRange = values;
              });
            },
            activeColor: secondaryColor,
            inactiveColor: isDark ? Colors.white : Colors.grey[300],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedCategories.clear();
                    caloriesRange = RangeValues(0, 1000);
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF858597),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('ค่าเริ่มต้น',
                    style: TextStyle(color: Color(0xFFFCF7F8))),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onSubmitted?.call(selectedCategories, caloriesRange);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? Color(0xFFEC4751) : Color(0xFFA31621),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('ยืนยันตัวกรอง',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
