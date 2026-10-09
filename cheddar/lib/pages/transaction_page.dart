import 'package:cheddar/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:cheddar/ui_elements.dart';
import 'package:provider/provider.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  String? selectedCategory;

  List<Transaction> transactions = [];
  Widget addTransactionPopup() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                Text(
                  'Add Transaction',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
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
                        controller: nameController,
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
                        onChanged: (value) => selectedCategory = null  ,
                        //Category amount
                        keyboardType: TextInputType.number,
                        controller: amountController,
                        style: TextStyle(fontSize: 12),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        
                        
                        ),
                      ),
                    ),
                  ],
                ),

                //add category drop down
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Text('Category'),
                    DropdownButton<String>(
                      value: selectedCategory,
                      items: ((double.tryParse(amountController.text)?? 0)> 0)
                      ?context
                          .read<UserProvider>()
                          .curBudget
                          .inc
                          .names
                          .map(
                            (name) => DropdownMenuItem<String>(
                              value: name,
                              child: Text(name),
                            ),
                          )
                          .toList()
                      :context
                          .read<UserProvider>()
                          .curBudget
                          .exp
                          .names
                          .map(
                            (name) => DropdownMenuItem<String>(
                              value: name,
                              child: Text(name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setModalState(() { 
                          selectedCategory = value;
                        });
                      },
                    ),
                  ],
                ),

                ElevatedButton(
                  onPressed: () {
                    context.read<UserProvider>().addTransaction(
                      name: nameController.text,
                      value: double.tryParse(amountController.text) ?? -1,
                      category: selectedCategory?? '',
                    );
                    Navigator.pop(context);
                  },
                  child: Text('Save'),
                ),

                SizedBox(height: 20), //spacer
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<UserProvider>().loadTransactions(
      budget: '',
      cat:'',
    );
  }
  @override
  Widget build(BuildContext context) {
    
    transactions = context.watch<UserProvider>().curTransactions;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 196, 176, 0),
        child: Icon(Icons.add),
        onPressed: () {
          //add transaction popup
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => addTransactionPopup(),
          );
        },
      ),
      body: MyTransactionList(
        oneCategory: false,        
        transactions: transactions,

      ),
    );
  }
}
