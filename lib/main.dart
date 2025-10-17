// Files for shared preferences
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExpenseApp());
}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Map<String, dynamic>> expenses = [];
  List<Map<String, dynamic>> filteredExpenses = [];
 // Add expenses to local storage
  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(expenses);
    await prefs.setString('expenses', encodedData);
  }
 //Edit expenses in local storage
  Future<void> _editExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(expenses);
    await prefs.setString('expenses', encodedData);
  }
  //Delete expenses from local storage
  Future<void> _deleteExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(expenses);
    await prefs.setString('expenses', encodedData);
  }
  // Load expenses from local storage
  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('expenses');
    if (encodedData != null) {
      setState(() {
        expenses = List<Map<String, dynamic>>.from(jsonDecode(encodedData));
        filteredExpenses = List.from(expenses);
      });
    }
  }


  // Text Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController searchController = TextEditingController();  

  // =====================
  // Search Logic
  // =====================
  @override
  void initState() {
    super.initState();
     _loadExpenses();
  searchController.addListener(_onSearchChanged);
  }
  void _onSearchChanged() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredExpenses = expenses
          .where((expense) =>
              expense['title'].toLowerCase().contains(query) ||
              expense['amount'].toString().contains(query))
          .toList();
    });
  }
  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }
  // =====================
  // ADD DIALOG
  // =====================
  void _showAddExpenseDialog() {
    titleController.clear();
    amountController.clear();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return _buildGlassDialog(
          title: 'Add New Expense',
          onConfirm: () {
            String title = titleController.text.trim();
            double? amount = double.tryParse(amountController.text);

            if (title.isNotEmpty && amount != null) {
              setState(() {
                expenses.add({'title': title, 'amount': amount});
                filteredExpenses = List.from(expenses);
              });
              _saveExpenses(); // Save to local storage
              Navigator.of(dialogContext).pop();
            }
          },
        );
      },
    );
  }

  // =====================
  // EDIT DIALOG
  // =====================
  void _showEditExpenseDialog(int index) {
    titleController.text = expenses[index]['title'];
    amountController.text = expenses[index]['amount'].toString();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return _buildGlassDialog(
          title: 'Edit Expense',
          onConfirm: () {
            String title = titleController.text.trim();
            double? amount = double.tryParse(amountController.text);

            if (title.isNotEmpty && amount != null) {
              setState(() {
                expenses[index]['title'] = title;
                expenses[index]['amount'] = amount;
                filteredExpenses = List.from(expenses);
              });
              _editExpenses(); // Edit to local storage
              Navigator.of(dialogContext).pop();
            }
          },
        );
      },
    );
  }

  // =====================
  // DELETE DIALOG
  // =====================
  void _showDeleteExpenseDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: Text(
            'Are you sure you want to delete "${expenses[index]['title']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  expenses.removeAt(index);
                  filteredExpenses = List.from(expenses);
                });
                
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // =====================
  // GLASS DIALOG TEMPLATE
  // =====================
  Widget _buildGlassDialog({
    required String title,
    required VoidCallback onConfirm,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width:  MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: onConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Save'),
                        ),
                      ],
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

  // =====================
  // UI
  // =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personal Expense Tracker',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search Expenses',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                )
              ),
            ),

            // Expense list
            Expanded(
              child: filteredExpenses.isEmpty
                  ? const Center(
                      child: Text(
                        'No expenses found.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                itemCount: filteredExpenses.length,
                itemBuilder: (context, index) {
                  final expense = filteredExpenses[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: ListTile(
                      title: Text(expense['title']),
                      subtitle: Text(
                        'Ksh. ${expense['amount'].toStringAsFixed(2)}',
                      ),
                      trailing: Wrap(
                        spacing: 12,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditExpenseDialog(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteExpenseDialog(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: _showAddExpenseDialog,
      ),
    );
  }
}
