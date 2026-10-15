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
      appBar: AppBar(title: MyHeaderTitle()),
      body: SafeArea(
        child: Column(
          children: [
            Expanded( 
              flex: 2,
              child: MyPieChart(
                      innerData: budget.inc.curValues,
                      innerName: 'Income',
                      innerNameData: budget.inc.names,
                      innerIconData: budget.inc.icons,
                      outerData: budget.exp.curValues,
                      outerName: 'Expenses',
                      outerNameData: budget.exp.names,
                      outerIconData: budget.exp.icons,
                      radius: 13,
                     
                    ),
            ),
            MyCategoryList(
              names: budget.inc.names, 
              icons: budget.inc.icons, 
              values: budget.inc.values, 
              curValues: budget.inc.curValues,  
              showCurrentValues: true, 
              isInc: true),
            MyCategoryList(
              names: budget.exp.names,  
              icons: budget.exp.icons, 
              values: budget.exp.values,  
              curValues: budget.exp.curValues,  
              showCurrentValues: true, 
              isInc: false)
          ],
        ),
      ),
      
    );
        }
      
  
  
}