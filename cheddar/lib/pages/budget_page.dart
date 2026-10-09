
import 'package:flutter/material.dart';
import 'package:cheddar/ui_elements.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:cheddar/user_provider.dart';


class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  @override
  Widget build(BuildContext context) {
    final Budget budget = context.watch<UserProvider>().curBudget;
    final createNeWBudgetNameController = TextEditingController();
    return Scaffold(
      floatingActionButton: Align(
        alignment:AlignmentGeometry.centerRight,
        child: Padding(
          padding: EdgeInsetsGeometry.only(top:170),
          child: FloatingActionButton(onPressed:(){
            showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return MyBottomSheetBuilder(title:'Add Category', edit: false);
              },
            );
            },
            backgroundColor: const Color.fromARGB(255, 207, 186, 0),
          
            child: Icon(Icons.add),
            ),
        ),
      ),
    
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownMenu( 
                    width: 200, 
                    label: Text('Current Budget'),
                    initialSelection: budget.budgetDate,
                    
                    dropdownMenuEntries: context.watch<UserProvider>().budgetNames.map<DropdownMenuEntry<String>>((String name){
                      
                      return DropdownMenuEntry(value: name, label: name);
                    }).toList(),
                    onSelected:(value) {
                      if (value != null) {
                        context.read<UserProvider>().setBudgetData(date: value);
                      }
                    },
                    ),
                  IconButton(onPressed: (){
                    //create new budget
                    showDialog(context: context, 
                    builder: (BuildContext context){
                      return AlertDialog(
                        title: Text("Create New Budget", style: TextStyle(fontSize:20,fontWeight: FontWeight.bold ),),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Name: '),
                            SizedBox(
                              width: 120,
                              child: Transform.scale(scale:0.8,
                                child: TextField(
                                  controller: createNeWBudgetNameController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          Center(
                            child: ElevatedButton(onPressed: (){
                              context.read<UserProvider>().setBudgetData(date: createNeWBudgetNameController.text);
                              
                              Navigator.pop(context);
                            }, child: Text('Create')),
                          )
                        ],
                      );
                      
                    });
                    
                  }, icon: Icon(Icons.add)),
                  IconButton(onPressed: (){
                    //create new budget
                    showDialog(context: context, 
                    builder: (BuildContext context){
                      return AlertDialog(
                        title: Text("Are you sure you want to delete \"${budget.budgetDate}?\"", 
                        style: TextStyle(fontSize:20,fontWeight: FontWeight.bold ),),
                        
                        actions: [
                          Center(
                            child: ElevatedButton(onPressed: (){
                              context.read<UserProvider>().deleteBudget(date: budget.budgetDate);
                              
                              Navigator.pop(context);
                            }, child: Text('Delete', style: TextStyle(color: Colors.red,))),
                          )
                        ],
                      );
                    });
                  },icon: Icon(Icons.remove))
                ],
              ),
              MyPieChart(
                      innerData: budget.inc.values,
                      innerName: 'Income',
                      innerNameData: budget.inc.names,
                      innerIconData: budget.inc.icons,
                      outerData: budget.exp.values,
                      outerName: 'Expenses',
                      outerNameData: budget.exp.names,
                      outerIconData: budget.exp.icons,
                      radius: 9,
                     
                    ),
              MyCategoryList(names: budget.inc.names, icons: budget.inc.icons, values: budget.inc.values, showCurrentValues: false, isInc: true),
              MyCategoryList(names: budget.exp.names, icons: budget.exp.icons, values: budget.exp.values, showCurrentValues: false, isInc: false)
            ],
          ),
        ),
      ),
    );
  }
}