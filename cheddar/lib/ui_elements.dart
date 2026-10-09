import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cheddar/user_provider.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';

//stateless
class MyHeaderTitle extends StatelessWidget {
  const MyHeaderTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30),
        Center(
          child: SizedBox(
            width: 200,
            height: 70,
            child: AutoSizeText(
              context.select((UserProvider p) => p.curBudget.budgetDate),
              textAlign: TextAlign.center,
              maxLines: 1,
              maxFontSize: 40,
              minFontSize: 10,
              style: TextStyle(
                fontSize: 50,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MyLoadingScreen extends StatelessWidget {
  const MyLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.monetization_on_sharp,
          color: Theme.of(context).colorScheme.primary,
          size: 50,
        ),
        Transform.scale(
          scale: 2,
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 3,
          ),
        ),
      ],
    );
  }
}

//stateful
class MyBottomSheetBuilder extends StatefulWidget {
  const MyBottomSheetBuilder({
    super.key,
    required this.title,
    required this.edit,
    this.catIndex = -1,
    this.catType = true,
    //reuquired
  });
  final String title;
  final bool edit;
  final int catIndex;
  final bool catType; //inc or exp
  @override
  State<MyBottomSheetBuilder> createState() => _MyBottomSheetBuilderState();
}

class _MyBottomSheetBuilderState extends State<MyBottomSheetBuilder> {
  bool selectedType = true;
  final TextEditingController categoryNameController = TextEditingController();
  final TextEditingController categoryAmountController =
      TextEditingController();
  Icon categoryIcon = Icon(Icons.monetization_on);
  String categoryIconName = 'monetization_on';

  String title = '';
  bool edit = false;
  int catIndex = -1;
  bool catType = true; //inc or exp

  //save initial values
  Icon initialCategoryIcon = Icon(Icons.monetization_on);
  String initialCategoryIconName = 'monetization_on';
  String initialCategoryName = '';
  double initialCategoryValue = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    title = widget.title;
    edit = widget.edit;
    catIndex = widget.catIndex;
    catType = widget.catType;
    final Budget budget = context
        .read<UserProvider>()
        .curBudget; //works bc it runs once, doesnt need to watch
    if (edit) {
      //show current values
      //and set initial values to base whether or not they changed
      selectedType = catType;
      //save inital
      if (selectedType) {
        if (catIndex >= budget.inc.values.length) return;
        //inc
        //set values from provider
        categoryIcon = budget.inc.icons[catIndex];
        categoryIconName = budget.inc.iconNames[catIndex];
        categoryNameController.text = budget.inc.names[catIndex];
        categoryAmountController.text = '${budget.inc.values[catIndex]}';
        initialCategoryValue = budget.inc.values[catIndex];
      } else {
        if (catIndex >= budget.exp.values.length) return;

        //exp
        categoryIcon = budget.exp.icons[catIndex];
        categoryIconName = budget.exp.iconNames[catIndex];
        categoryNameController.text = budget.exp.names[catIndex];
        categoryAmountController.text = '${budget.exp.values[catIndex]}';
        initialCategoryValue = budget.exp.values[catIndex];
      }
      //save initial values
      initialCategoryIcon = categoryIcon;
      initialCategoryIconName = categoryIconName;
      initialCategoryName = categoryNameController.text;
    }
  }

  Future<void> _pickIcon() async {
    IconPickerIcon? result = await showIconPicker(
      context,

      configuration: SinglePickerConfiguration(
        showSearchBar: true,
        showTooltips: true,
        iconPackModes: [IconPack.material],
      ),
    );
    if (!mounted) return;

    if (result != null) {
      setState(() {
        categoryIcon = Icon(result.data);
        categoryIconName = result.name;
      });
    } else {
      setState(() {
        categoryIcon = Icon(Icons.monetization_on);
        categoryIconName = 'monetization_on';
      });
    }
  }

  Future<void> _editArrayVariables({
    required Budget budget,
    required int index,

    required double val,
    required Icon icon,
    required String iconName,
    required String name,
  }) async {
    //set stype
    if (catIndex != -1) {
      //make sure that index exists
      if (selectedType == true) {
        //inc
        // value

        if (initialCategoryValue != val) {
          //check for performance, to see if variable changed at all
          if (!mounted) return;
          await context.read<UserProvider>().changeBudgetArrayVar<double>(
            (list) async {
              final next = List<double>.from(list);
              next[index] = val;
              return next;
            },
            context.read<UserProvider>().curBudget.inc.values,
            (list) async {
              context.read<UserProvider>().curBudget.inc.values = list;
            },
            index: index,
            newVar: val,
            date: budget.budgetDate,
            varName: 'incValues',
          );
        }
        //icon
        if (initialCategoryIcon != icon) {
          //check for performance, to see if variable changed at all
          if (!mounted) return;
          await context.read<UserProvider>().changeBudgetArrayVar<Icon>(
            (list) async {
              final next = List<Icon>.from(list);
              next[index] = icon;
              return next;
            },
            context.read<UserProvider>().curBudget.inc.icons,
            (list) async {
              context.read<UserProvider>().curBudget.inc.icons = list;
            },
            index: index,
            newVar: icon,
            date: budget.budgetDate,
            varName: 'null', //doesn't matter
            firebaseSave:
                false, //makes it only save to local, bc firebase only stores icon names
          );
        }
        //icon name
        if (initialCategoryIconName != iconName) {
          //check for performance, to see if variable changed at all
          if (!mounted) return;
          await context.read<UserProvider>().changeBudgetArrayVar<String>(
            (list) async {
              final next = List<String>.from(list);
              next[index] = iconName;
              return next;
            },
            context.read<UserProvider>().curBudget.inc.iconNames,
            (list) async {
              context.read<UserProvider>().curBudget.inc.iconNames = list;
            },
            index: index,
            newVar: iconName,
            date: budget.budgetDate,
            varName: 'incIconNames',
          );
        }
        //name
        if (initialCategoryName != name) {
          //check for performance, to see if variable changed at all
          if (!mounted) return;
          await context.read<UserProvider>().changeBudgetArrayVar<String>(
            (list) async {
              final next = List<String>.from(list);
              next[index] = name;
              return next;
            },
            context.read<UserProvider>().curBudget.inc.names,
            (list) async {
              context.read<UserProvider>().curBudget.inc.names = list;
            },
            index: index,
            newVar: name,
            date: budget.budgetDate,
            varName: 'incNames',
          );
        }
      } else {
        //exp

        if (initialCategoryValue != val) {
          //check for performance, to see if variable changed at all
          if (!mounted) return;
          await context.read<UserProvider>().changeBudgetArrayVar<double>(
            (list) async {
              final next = List<double>.from(list);
              next[index] = val;
              return next;
            },
            context.read<UserProvider>().curBudget.exp.values,
            (list) async {
              context.read<UserProvider>().curBudget.exp.values = list;
            },
            index: index,
            newVar: val,
            date: budget.budgetDate,
            varName: 'expValues',
          );
        }
        //icon
        if (initialCategoryIcon != icon) {
          //check for performance, to see if variable changed at all
          if (!mounted) return;
          await context.read<UserProvider>().changeBudgetArrayVar<Icon>(
            (list) async {
              final next = List<Icon>.from(list);
              next[index] = icon;
              return next;
            },
            context.read<UserProvider>().curBudget.exp.icons,
            (list) async {
              context.read<UserProvider>().curBudget.exp.icons = list;
            },
            index: index,
            newVar: icon,
            date: budget.budgetDate,
            varName: 'null', //doesn't matter
            firebaseSave:
                false, //makes it only save to local, bc firebase only stores icon names
          );
        }
        //icon name
        if (initialCategoryIconName != iconName) {
          //check for performance, to see if variable changed at all
          if (!mounted) return;
          await context.read<UserProvider>().changeBudgetArrayVar<String>(
            (list) async {
              final next = List<String>.from(list);
              next[index] = iconName;
              return next;
            },
            context.read<UserProvider>().curBudget.exp.iconNames,
            (list) async {
              context.read<UserProvider>().curBudget.exp.iconNames = list;
            },
            index: index,
            newVar: iconName,
            date: budget.budgetDate,
            varName: 'expIconNames',
          );
        }
        //name
        if (initialCategoryName != name) {
          //check for performance, to see if variable changed at all
          if (!mounted) return;
          await context.read<UserProvider>().changeBudgetArrayVar<String>(
            (list) async {
              final next = List<String>.from(list);
              next[index] = name;
              return next;
            },
            context.read<UserProvider>().curBudget.exp.names,
            (list) async {
              context.read<UserProvider>().curBudget.exp.names = list;
            },
            index: index,
            newVar: name,
            date: budget.budgetDate,
            varName: 'expNames',
          );
        }
      }
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final Budget budget = context.watch<UserProvider>().curBudget;
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              //exp or inc
              edit
                  ? ElevatedButton(
                      onPressed: () {
                        context.read<UserProvider>().deleteCategory(
                          index: catIndex,
                          isInc: catType,
                          date: budget.budgetDate,
                        );
                        Navigator.pop(context);
                      },
                      child: Text('Delete'),
                    )
                  : SegmentedButton<bool>(
                      emptySelectionAllowed: false,
                      segments: const [
                        ButtonSegment<bool>(value: true, label: Text('Income')),
                        ButtonSegment<bool>(
                          value: false,
                          label: Text('Expense'),
                        ),
                      ],
                      selected: {selectedType},
                      onSelectionChanged: (Set<bool> newSelection) {
                        setModalState(() {
                          selectedType = newSelection.first;
                        });
                      },
                    ),

              Row(
                //name selector
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 22,
                children: [
                  Text('Name'),
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: TextField(
                      //Category Name
                      style: TextStyle(fontSize: 12),
                      controller: categoryNameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              Row(
                //budget amount selector
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  Text('Amount'),
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: TextField(
                      //Category amount
                      keyboardType: TextInputType.number,
                      controller: categoryAmountController,
                      style: TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              Row(
                //pick Icon
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Icon'),
                  IconButton(
                    onPressed: () {
                      _pickIcon();
                    },
                    icon: categoryIcon,
                    iconSize: 30,
                  ),
                ],
              ),

              ElevatedButton(
                onPressed: () {
                  double val =
                      double.tryParse(categoryAmountController.text) ?? -1;
                  if (categoryNameController.text != '' &&
                      val != -1 &&
                      val != 0) {
                    //save or edit all the values
                    if (edit) {
                      //edit existsing category
                      _editArrayVariables(
                        budget: budget,
                        index: catIndex,
                        icon: categoryIcon,
                        iconName: categoryIconName,
                        name: categoryNameController.text,
                        val: val,
                      );
                    } else {
                      //save new category
                      context.read<UserProvider>().addCategory(
                        isInc: selectedType,
                        date: budget.budgetDate,
                        icon: categoryIcon,
                        iconName: categoryIconName,
                        name: categoryNameController.text,
                        value: val,
                      );
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text(edit ? 'Save Changes' : 'Save'),
              ),

              SizedBox(height: 20), //spacer
            ],
          ),
        );
      },
    );
  }
}

class MyCategoryList extends StatefulWidget {
  const MyCategoryList({
    super.key,
    //reuquired
    required this.names,
    required this.icons,
    required this.values,

    this.curValues = const [],

    required this.showCurrentValues,
    required this.isInc,
  });

  final List<String> names;
  final List<Icon> icons;
  final List<double> values;

  final List<double> curValues;

  final bool showCurrentValues;
  final bool isInc;

  @override
  State<MyCategoryList> createState() => _MyCategoryListState();
}

class _MyCategoryListState extends State<MyCategoryList> {
  List<String> names = [];
  List<Icon> icons = [];
  List<double> values = [];

  List<double> curValues = [];
  bool showCurrentValues = true; //also effects the popup
  bool isInc = true;
  @override
  void initState() {
    super.initState();
    // 2. Initialize it once from the widget
    names = widget.names;
    icons = widget.icons;
    values = widget.values;
    curValues = widget.curValues;
    showCurrentValues = widget.showCurrentValues;
    isInc = widget.isInc;
  }

  @override
  void didUpdateWidget(covariant MyCategoryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    names = widget.names;
    icons = widget.icons;
    values = widget.values;
    curValues = widget
        .curValues; //TODO need to change this for adding and deleteing to work properly apparently
    showCurrentValues = widget.showCurrentValues;
    isInc = widget.isInc;
  }

  @override
  Widget build(BuildContext context) {
    Color catColor = isInc
        ? const Color.fromARGB(131, 76, 175, 79)
        : const Color.fromARGB(131, 244, 67, 54);
    double valueSum = values.fold(
      0,
      (previousValue, element) => previousValue + element,
    );

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: values.length,
        padding: EdgeInsets.zero,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(1.0),
            child: SizedBox(
              width: 140,

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    minTileHeight: 58,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    minVerticalPadding: 0,
                    visualDensity: VisualDensity.compact,

                    tileColor: Theme.of(context).colorScheme.surfaceContainer,
                    title: Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [icons[index], Text(names[index])],
                    ),

                    onTap: () {
                      showCurrentValues
                          //show transactions in this category
                          ? showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (context) {
                                return MyTransactionList(
                                  categoryName: names[index],

                                  oneCategory: true,
                                );
                              },
                            )
                          //show edit screen
                          : showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (context) {
                                return MyBottomSheetBuilder(
                                  title: 'Edit Category',
                                  edit: true,
                                  catIndex: index,
                                  catType: isInc,
                                );
                              },
                            );
                    },
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 40,
                        child: RotatedBox(
                          quarterTurns: isInc ? 0 : 2,
                          child: LinearProgressIndicator(
                            value: showCurrentValues
                                ? curValues[index] / values[index]
                                : values[index] / valueSum,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surface,

                            color: catColor,
                          ),
                        ),
                      ),
                      Text(
                        showCurrentValues
                            ? '\$${curValues[index].toStringAsFixed(0)} / \$${values[index].toStringAsFixed(0)}'
                            : '\$${values[index].toStringAsFixed(0)} (%${(values[index] / valueSum * 100).toStringAsFixed(0)})',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MyPieChart extends StatefulWidget {
  const MyPieChart({
    super.key,

    required this.innerNameData,
    required this.innerData,
    required this.innerName,
    required this.innerIconData,

    required this.outerNameData,
    required this.outerData,
    required this.outerName,
    required this.outerIconData,

    required this.radius,
  });

  final double radius;

  final int dec = 2; //how many decimal places values have

  final List<double> innerData;
  final List<double> outerData;

  final List<String> outerNameData;
  final List<String> innerNameData;

  final List<Icon> outerIconData;
  final List<Icon> innerIconData;

  final String outerName;
  final String innerName;

  @override
  State<MyPieChart> createState() => _MyPieChartState();
}

class _MyPieChartState extends State<MyPieChart> {
  double radius = 0;
  List<double> innerData = [];
  List<double> outerData = [];

  List<String> outerNameData = [];
  List<String> innerNameData = [];

  List<Icon> outerIconData = [];
  List<Icon> innerIconData = [];

  String outerName = '';
  String innerName = '';

  int dec = 2;

  int touchedIndex = -1;
  bool inRadius =
      false; //whether or not the touch event is inside the inner radius
  bool prevInRadius = false;

  bool outRadius =
      true; //whether or not the touch event is outside the outer radius
  bool toggleOn = false;
  int prevTouchIndex = -1;
  bool oneTouch = true;
  Offset prevTouchPos = Offset(0, 0);

  double outerSum = -1;
  double innerSum = -1;
  double diff = -1;

  int innerLength = -1;
  int outerLength = -1; //lengths set before adding filler

  //prebuild sections for dynamic editing
  List<PieChartSectionData> innerSections = [];
  List<PieChartSectionData> outerSections = [];

  bool innerFiller = false; //is there an inner filler section
  bool outerFiller = false; //is there an outer filler section
  @override
  void initState() {
    super.initState();
    radius = widget.radius;
    innerData = widget.innerData;
    outerData = widget.outerData;

    outerNameData = widget.outerNameData;
    innerNameData = widget.innerNameData;

    outerIconData = widget.outerIconData;
    innerIconData = widget.innerIconData;

    outerName = widget.outerName;
    innerName = widget.innerName;

    dec = widget.dec;
    for (int i = innerData.length - 1; i >= 0; i--) {
      if (innerData[i] == 0) {
        innerData = List.from(innerData);
        innerData.removeAt(i);

        innerNameData = List.from(innerNameData);
        innerNameData.removeAt(i);

        innerIconData = List.from(innerIconData);
        innerIconData.removeAt(i);
      }
    }
    for (int i = outerData.length - 1; i >= 0; i--) {
      if (outerData[i] == 0) {
        outerData = List.from(outerData);
        outerData.removeAt(i);

        outerNameData = List.from(outerNameData);
        outerNameData.removeAt(i);

        outerIconData = List.from(outerIconData);
        outerIconData.removeAt(i);
      }
    }
  }

  @override
  void didUpdateWidget(covariant MyPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    radius = widget.radius;
    innerData = widget.innerData;
    outerData = widget.outerData;

    outerNameData = widget.outerNameData;
    innerNameData = widget.innerNameData;

    outerIconData = widget.outerIconData;
    innerIconData = widget.innerIconData;

    outerName = widget.outerName;
    innerName = widget.innerName;

    dec = widget.dec;
    //cut zeros//messes up indexing for some reason

    for (int i = innerData.length - 1; i >= 0; i--) {
      if (innerData[i] == 0) {
        innerData = List.from(innerData);
        innerData.removeAt(i);

        innerNameData = List.from(innerNameData);
        innerNameData.removeAt(i);

        innerIconData = List.from(innerIconData);
        innerIconData.removeAt(i);
      }
    }
    for (int i = outerData.length - 1; i >= 0; i--) {
      if (outerData[i] == 0) {
        outerData = List.from(outerData);
        outerData.removeAt(i);

        outerNameData = List.from(outerNameData);
        outerNameData.removeAt(i);

        outerIconData = List.from(outerIconData);
        outerIconData.removeAt(i);
      }
    }

    innerLength = innerData.length;
    outerLength = outerData.length;
  }

  void _addFillerSection(bool isInner, double val) {
    setState(() {
      if (isInner == true) {
        //add to inner //overbudget
        innerFiller = true;
        outerFiller = false;
        innerSections.add(
          PieChartSectionData(
            showTitle: false,
            value: val,
            color: const Color.fromARGB(70, 255, 18, 1),
            radius: radius * 4 * 0.6,
          ),
        );
      } else {
        // add to outer //underbudget
        outerFiller = true;
        innerFiller = false;
        outerSections.add(
          PieChartSectionData(
            showTitle: false,
            value: val,
            color: const Color.fromARGB(160, 157, 255, 132),
            radius: radius * 4 * 0.6,
          ),
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<UserProvider>(context);

    innerSum = innerData.fold(
      0,
      (previousValue, element) => previousValue + element,
    );
    outerSum = outerData.fold(
      0,
      (previousValue, element) => previousValue + element,
    );

    innerLength = innerData.length;
    outerLength = outerData.length;

    if (innerSum != outerSum) {
      diff = (innerSum - outerSum).abs();
    }
  }

  void _handlePieTouch(FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
    setState(() {
      if (!event.isInterestedForInteractions ||
          pieTouchResponse == null ||
          pieTouchResponse.touchedSection == null) {
        touchedIndex = -1;

        return;
      }

      touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;

      final renderBox = context.findRenderObject();
      if (renderBox is! RenderBox) {
        return;
      }
      final center = renderBox.size.center(Offset.zero);
      final touchPosition = event.localPosition;

      if (touchPosition != null) {
        final dx = touchPosition.dx - center.dx;
        final dy = touchPosition.dy - center.dy;
        final distanceFromCenter = sqrt((dx * dx) + (dy * dy));

        inRadius = distanceFromCenter < 9.9 * radius;
        outRadius = distanceFromCenter > 15 * radius;

        if (prevTouchPos != touchPosition) {
          oneTouch = true;
        }
        prevTouchPos = touchPosition;
      }
      //checks to fix bugs
      if (inRadius != prevInRadius) {
        prevTouchIndex = -1;
        toggleOn = false;
      }
      prevInRadius = inRadius;
    });
  }

  Widget _innerPieChart() {
    //premake sections:

    innerSections = [
      for (int i = 0; i < innerLength; i++)
        PieChartSectionData(
          showTitle: false,
          badgeWidget: Transform.scale(
            scale: radius / 10,
            child: innerIconData[i],
          ),

          value: innerData[i],

          color: Color.fromARGB(255, 255 - (i * 30), 200 - (i * 5), 0),
          radius:
              radius *
              4 *
              ((!inRadius)
                  ? 1
                  : (!toggleOn)
                  ? 1.2
                  : (prevTouchIndex == i)
                  ? 1.4
                  : 1),
        ),
    ];

    if (diff != -1 && innerSum < outerSum) {
      _addFillerSection(true, diff);
    }

    return IgnorePointer(
      ignoring: !inRadius,
      child: PieChart(
        swapAnimationDuration: const Duration(milliseconds: 500),
        swapAnimationCurve: Curves.easeInOut,

        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (event, pieTouchResponse) {
              _handlePieTouch(event, pieTouchResponse);
            },
          ),
          centerSpaceRadius: 6 * radius,
          sectionsSpace: 0,
          sections: innerSections,
        ),
      ),
    );
  }

  Widget _outerPieChart() {
    //premake sections:
    print(outerIconData);
    outerSections = [
      for (int i = 0; i < outerLength; i++)
        PieChartSectionData(
          showTitle: false,

          badgeWidget: outerIconData[i],
          value: outerData[i],

          color: Color.fromARGB(255, 255 - (i * 15), 130 - (i * 10), 0),
          radius:
              radius *
              4 *
              ((outRadius)
                  ? 1
                  : (inRadius)
                  ? 1
                  : (!toggleOn)
                  ? 1.2
                  : (prevTouchIndex == i)
                  ? 1.4
                  : 1),
        ),
    ];
    if (diff != -1 && innerSum > outerSum) {
      _addFillerSection(false, diff);
    }

    return PieChart(
      swapAnimationDuration: const Duration(milliseconds: 500),
      swapAnimationCurve: Curves.easeInOut,
      PieChartData(
        pieTouchData: PieTouchData(
          enabled: true,
          touchCallback: (event, pieTouchResponse) {
            _handlePieTouch(event, pieTouchResponse);
          },
        ),
        centerSpaceRadius: 9.9 * radius,
        sectionsSpace: 0,

        sections: outerSections,
      ),
    );
  }

  Widget _centerText() {
    final String chartName = inRadius ? innerName : outerName;

    final String summary = (innerSum == outerSum)
        ? 'On Budget'
        : (innerSum > outerSum)
        ? 'Under Budget'
        : 'Over Budget';

    String centerTitle = outRadius ? summary : chartName;

    String net = (innerSum - outerSum).abs().toStringAsFixed(dec);
    String centerSubtitle = (innerSum == outerSum && outRadius)
        ? ''
        : outRadius
        ? '\$$net'
        : (inRadius)
        ? '\$${innerSum.toStringAsFixed(dec)}'
        : '\$${outerSum.toStringAsFixed(dec)}';

    if (toggleOn == true && prevTouchIndex != -1) {
      print(outerNameData);
      final String sliceName = inRadius
          ? innerNameData[prevTouchIndex]
          : outerNameData[prevTouchIndex];

      final String sliceAmount = inRadius
          ? innerData[prevTouchIndex].toStringAsFixed(dec)
          : outerData[prevTouchIndex].toStringAsFixed(dec);
      centerTitle = outRadius ? summary : sliceName;
      centerSubtitle = outRadius ? '\$$net' : '\$$sliceAmount';
    }

    setState(() {
      if (touchedIndex != -1 && oneTouch == true) {
        oneTouch = false;
        if (prevTouchIndex == touchedIndex ||
            touchedIndex >= innerLength && inRadius ||
            touchedIndex >= outerLength && !inRadius && !outRadius) {
          prevTouchIndex = -1;
          toggleOn = false;
          return;
        } else {
          prevTouchIndex = touchedIndex;
          toggleOn = true;
          return;
        }
      }
      if (inRadius) {}
    });

    return SizedBox(
      width: 10 * radius,
      height: 10 * radius,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          AutoSizeText(
            //chart title or Slice Title
            centerTitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            maxFontSize: 3 * radius,
            minFontSize: radius,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 2 * radius,
              fontWeight: FontWeight.w500,
            ),
          ),
          AutoSizeText(
            //$ amount or nothing
            centerSubtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            maxFontSize: 3 * radius,
            minFontSize: radius,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 1.5 * radius,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: radius * 30,
        width: radius * 30,
        child: Stack(
          alignment: Alignment.center,
          children: [_outerPieChart(), _innerPieChart(), _centerText()],
        ),
      ),
    );
  }
}

//need to be usable for clicking on catgories in homepage and listing unfiltered ones in transaction page
class MyTransactionList extends StatefulWidget {
  const MyTransactionList({
    super.key,

    //reuquired
    // required this.names,
    // required this.values,

    // required this.categories,
    required this.oneCategory,
    this.categoryName = '',
    this.transactions = const [],
  });
  final List<Transaction> transactions;

  final bool oneCategory;
  final String categoryName;

  @override
  State<MyTransactionList> createState() => _MyTransactionListState();
}

class _MyTransactionListState extends State<MyTransactionList> {
  List<Transaction> transactions = [];

  List<String> names = [];
  List<double> values = [];

  bool oneCategory = false;
  String categoryName = '';
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _initializeTransactions();
  }

  Future<void> _initializeTransactions() async {
    oneCategory = widget.oneCategory;
    categoryName = widget.categoryName;

    if (oneCategory) {
      await context.read<UserProvider>().loadTransactions(
        budget: context.read<UserProvider>().curBudget.budgetDate,
        cat: categoryName,
      );
      if (!mounted) return;
      transactions = context.read<UserProvider>().curTransactions;
    } else {
      transactions = widget.transactions;
    }

    if (!mounted) return;
    setState(() {
      _syncTransactionLists();
    });
  }

  void _syncTransactionLists() {
    names.clear();
    values.clear();
    for (int i = 0; i < transactions.length; i++) {
      names.add(transactions[i].name);
      values.add(transactions[i].value);
    }
  }

  @override
  void didUpdateWidget(covariant MyTransactionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    oneCategory = widget.oneCategory;
    categoryName = widget.categoryName;

    if (oneCategory) {
      transactions = context.read<UserProvider>().curTransactions;
    } else {
      transactions = widget.transactions;
    }

    _syncTransactionLists();
  }

  @override
  Widget build(BuildContext context) {
    //isn't needed anymore since transactions are already filtered in the provider

    // if (oneCategory){
    //   for(int i = 0; i < categories.length; i++){
    //     if (categories[i]!= categoryName){
    //       names.removeAt(i);
    //       values.removeAt(i);
    //       categories.removeAt(i);
    //     }
    //   }
    // }
    return GestureDetector(
      onTap: () {
              Navigator.pop(context);
            },
      child: Padding(
        //TODO add more category specific info here if wanted (ie totals, percenatges, sumaries etc)
        padding: EdgeInsets.only(top: oneCategory ? 20.0 : 0.0),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: values.length,
          
          itemBuilder: (BuildContext context, int index) {
            
            return Padding(
              padding: const EdgeInsets.all(1),
              child: Container(
                
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      width: 10,
                      color: (values[index] > 0) ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                child: ListTile(
                  tileColor: Theme.of(context).colorScheme.surfaceContainer,
                  onTap: () {
                    oneCategory
                        ? null//TODO add edit transaction functionality here if wanted
                        //catgorize transaction
                        : showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (context) {
                              return Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).viewInsets.bottom,
                                  top: 20,
                                  left: 20,
                                  right: 20,
                                ),
                                child: Column(
                                  children: [
                                    Text('Categorize Transaction'),
                                    DropdownButtonFormField(
                                      items: [
                                        for (String name
                                            in (widget.transactions[index].value >
                                                    0)
                                                ? context
                                                      .read<UserProvider>()
                                                      .curBudget
                                                      .inc
                                                      .names
                                                : context
                                                      .read<UserProvider>()
                                                      .curBudget
                                                      .exp
                                                      .names)
                                          DropdownMenuItem(
                                            value: name,
                                            child: Text(name),
                                          ),
                                      ],
              
                                      onChanged: (value) {
                                        setState(() {
                                          selectedCategory = value;
                                        });
                                      },
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        if (selectedCategory == null) {
                                          return;
                                        }
              
                                        context
                                            .read<UserProvider>()
                                            .categorizeTransaction(
                                              transaction:
                                                  widget.transactions[index],
                                              budget: context
                                                  .read<UserProvider>()
                                                  .curBudget
                                                  .budgetDate,
                                              category: selectedCategory ?? '',
                                            );
                                      },
                                      child: Text('Save'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                    //categorize
                  },
                  title: AutoSizeText(names[index], maxLines: 1),
                  subtitle: AutoSizeText(
                    "${(values[index] > 0) ? '+' : '-'}\$${(values[index].abs()).toStringAsFixed(2)}",
                    maxLines: 1,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
