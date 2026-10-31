import 'package:flutter/material.dart';
import 'package:cheddar/ui_elements.dart';
import 'package:provider/provider.dart';
import 'package:cheddar/user_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final Budget budget = context.watch<UserProvider>().curBudget;

    return Scaffold(
      appBar: AppBar(title: MyHeaderTitle(), toolbarHeight: 70,),
      body: SafeArea(
        child: Column(
          children: [
            MyPieChart(
              innerData: budget.inc.curValues,
              innerName: 'Income',
              innerNameData: budget.inc.names,
              innerIconData: budget.inc.icons,
              outerData: budget.exp.curValues,
              outerName: 'Expenses',
              outerNameData: budget.exp.names,
              outerIconData: budget.exp.icons,
              radius: 11,//prev 13
              isBudgetPage: false,
            ),
            Expanded(
              child: Row( spacing: 1, mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: MyCategoryList(
                      names: budget.inc.names,
                      icons: budget.inc.icons,
                      values: budget.inc.values,
                      curValues: budget.inc.curValues,
                      showCurrentValues: true,
                      isInc: true,
                    ),
                  ),
                  Expanded(
                    child: MyCategoryList(
                      names: budget.exp.names,
                      icons: budget.exp.icons,
                      values: budget.exp.values,
                      curValues: budget.exp.curValues,
                      showCurrentValues: true,
                      isInc: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
