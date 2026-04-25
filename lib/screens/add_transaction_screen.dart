import 'package:expenseflow/db/database_helper.dart';
import 'package:expenseflow/models/transaction_model.dart';
import 'package:expenseflow/widgets/category_card.dart';
import 'package:expenseflow/widgets/date_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String selectedType = 'expense';
  String? categoryselected;
  double amount = 0;

  bool isFocused = false;
  FocusNode amountFocusNode = FocusNode();
  TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    amountController.text = '0';
    amountFocusNode.addListener(() {
      setState(() {
        isFocused = amountFocusNode.hasFocus;
      });
    });

    final now = DateTime.now();
    dateController.text =
        "${now.month.toString().padLeft(2, '0')}/"
        "${now.day.toString().padLeft(2, '0')}/"
        "${now.year}";
  }

  @override
  void dispose() {
    amountFocusNode.dispose();
    amountController.dispose();
    dateController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      dateController.text =
          "${picked.month.toString().padLeft(2, '0')}/"
          "${picked.day.toString().padLeft(2, '0')}/"
          "${picked.year}";
    }
  }

  void _increase() {
    setState(() {
      amount++;
      amountController.text = amount.toStringAsFixed(0);
      amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: amountController.text.length),
      );
    });
  }

  void _decrease() {
    setState(() {
      if (amount > 0) amount--;
      amountController.text = amount.toStringAsFixed(0);
      amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: amountController.text.length),
      );
    });
  }

  Future<void> _saveTransaction() async {
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (categoryselected == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    final transaction = TransactionModel(
      amount: amount,
      type: selectedType,
      category: categoryselected!,
      date: dateController.text,
      notes: notesController.text,
    );

    await DatabaseHelper().insertTransaction(transaction);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction'), centerTitle: false),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Type', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedType = 'expense';
                        });
                      },
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: selectedType == 'expense'
                              ? Colors.red
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            'Expense',
                            style: TextStyle(
                              color: selectedType == 'expense'
                                  ? Colors.white
                                  : Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedType = 'income';
                        });
                      },
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: selectedType == 'income'
                              ? Colors.green
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            'Income',
                            style: TextStyle(
                              color: selectedType == 'income'
                                  ? Colors.white
                                  : Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text('Amount', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),

              _buildAmountField(),

              const SizedBox(height: 15),
              Text('Category', style: TextStyle(fontSize: 18)),

              const SizedBox(height: 5),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategory('🍔', 'Food'),
                  _buildCategory('🚗', 'Transport'),
                  _buildCategory('🛍️', 'Shopping'),
                  _buildCategory('💡', 'Bills'),
                ],
              ),

              const SizedBox(height: 5),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategory('🎮', 'Entertainment'),
                  _buildCategory('🏥', 'Health'),
                  _buildCategory('💰', 'Salary'),
                  _buildCategory('📝', 'Other'),
                ],
              ),
              const SizedBox(height: 15),
              Text('Date', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 5),
              TextField(
                controller: dateController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  DateInputFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: "mm/dd/yyyy",
                  filled: true,
                  fillColor: Colors.grey[200],

                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_month_outlined),
                    onPressed: _pickDate,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Color(0xFF0F9D6E), width: 2),
                  ),

                  contentPadding: EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 10,
                  ),
                ),
              ),

              const SizedBox(height: 15),
              Text('Notes (optional)', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 5),
              TextField(
                controller: notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Add notes...",

                  filled: true,
                  fillColor: Colors.grey[200],

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Color(0xFF0F9D6E), width: 2),
                  ),

                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E8F63),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        'Save Transaction',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(amountFocusNode);
      },
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isFocused ? const Color(0xFF0F9D6E) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            const Text(
              '\$',
              style: TextStyle(fontSize: 24, color: Colors.grey),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: TextField(
                controller: amountController,
                focusNode: amountFocusNode,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(border: InputBorder.none),
                onChanged: (value) {
                  amount = double.tryParse(value) ?? 0;
                },
              ),
            ),

            if (isFocused)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _increase,
                    child: const Icon(Icons.arrow_drop_up),
                  ),
                  GestureDetector(
                    onTap: _decrease,
                    child: const Icon(Icons.arrow_drop_down),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String icon, String label) {
    final isSelected = categoryselected == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          categoryselected = label;
        });
      },
      child: CategoryCard(
        icon: icon,
        text: label,
        color: isSelected ? const Color(0xFF0F9D6E) : Colors.grey[200]!,
        textColor: isSelected ? Colors.white : Colors.black,
      ),
    );
  }
}
