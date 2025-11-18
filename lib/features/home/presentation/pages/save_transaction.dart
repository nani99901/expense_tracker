import 'package:expense_tracker/features/home/domain/entities/transaction.dart';
import 'package:expense_tracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:expense_tracker/features/home/presentation/bloc/home_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTxnPage extends StatefulWidget {
  final bool isIncome;
  final Txn? initialTxn;
  const AddTxnPage({Key? key, required this.isIncome, this.initialTxn}) : super(key: key);

  @override
  State<AddTxnPage> createState() => _AddTxnPageState();
}

class _AddTxnPageState extends State<AddTxnPage> {
  final amountCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  String? selectedCategory;
  String? selectedWallet;
  bool isRepeat = false;
  List<String> incomeList = ['Salary', 'Gifts', 'Other'];
  List<String> expenseList = [
    'Shopping',
    'Food',
    'Subscription',
    'Transport',
    'Rent',
    'Other',
  ];
  bool _loadingWallets = false;
  List<Map<String, String>> _wallets = [];

  @override
  void dispose() {
    amountCtrl.dispose();
    categoryCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Prefill for edit mode
    final t = widget.initialTxn;
    if (t != null) {
      amountCtrl.text = t.amount.toStringAsFixed(0);
      selectedCategory = t.category.isEmpty ? null : t.category;
      selectedWallet = t.walletId.isEmpty ? null : t.walletId;
      descCtrl.text = t.description;
    }
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _wallets = [];
        _loadingWallets = false;
      });
      return;
    }

    setState(() {
      _loadingWallets = true;
    });

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wallets')
          .get();

      final loaded = snap.docs.map((doc) {
        final data = doc.data();
        final name = (data['name'] as String?) ?? 'Wallet';
        return {
          'id': doc.id,
          'name': name,
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _wallets = loaded;
        _loadingWallets = false;
        // If no wallet preselected (new txn) and we have wallets, default to first
        if (selectedWallet == null && _wallets.isNotEmpty) {
          selectedWallet = _wallets.first['id'];
        }
        // If editing and previous walletId no longer exists, clear selection
        if (selectedWallet != null &&
            !_wallets.any((w) => w['id'] == selectedWallet)) {
          selectedWallet = null;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _wallets = [];
        _loadingWallets = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (widget.initialTxn?.isIncome ?? widget.isIncome)
          ? const Color(0xFF00A86B)
          : const Color(0xFFFF3B30),
      appBar: AppBar(
        backgroundColor: (widget.initialTxn?.isIncome ?? widget.isIncome)
            ? const Color(0xFF00A86B)
            : const Color(0xFFFF3B30),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          (widget.initialTxn?.isIncome ?? widget.isIncome) ? 'Income' : 'Expense',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'How much?',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '₹',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(color: Colors.white, fontSize: 64),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        hintText: 'Category',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        suffixIcon: const Icon(Icons.keyboard_arrow_down),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF7F3DFF),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      items: (widget.initialTxn?.isIncome ?? widget.isIncome)
                          ? incomeList
                                .map(
                                  (cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  ),
                                )
                                .toList()
                          : expenseList
                                .map(
                                  (cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  ),
                                )
                                .toList(),
                      onChanged: (val) =>
                          setState(() => selectedCategory = val),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descCtrl,
                      decoration: InputDecoration(
                        hintText: 'Description',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF7F3DFF),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedWallet,
                      decoration: InputDecoration(
                        hintText: 'Wallet',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        suffixIcon: const Icon(Icons.keyboard_arrow_down),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF7F3DFF),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      items: _wallets
                          .map(
                            (wallet) => DropdownMenuItem<String>(
                              value: wallet['id'],
                              child: Text(wallet['name'] ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: _loadingWallets || _wallets.isEmpty
                          ? null
                          : (val) => setState(() => selectedWallet = val),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.attach_file, color: Colors.grey[600]),
                            const SizedBox(width: 12),
                            Text(
                              'Add attachment',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Repeat',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Repeat transaction',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: isRepeat,
                                onChanged: (val) =>
                                    setState(() => isRepeat = val),
                                activeColor: const Color(0xFF7F3DFF),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7F3DFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          final amt = double.tryParse(amountCtrl.text) ?? 0;
                          if (amt <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Enter amount')),
                            );
                            return;
                          }
                          if (widget.initialTxn == null && selectedWallet == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Select a wallet')),
                            );
                            return;
                          }
                          final isIncome = widget.initialTxn?.isIncome ?? widget.isIncome;
                          if (widget.initialTxn != null) {
                            // Edit mode: keep same id and original date
                            final before = widget.initialTxn!;
                            final after = Txn(
                              id: before.id,
                              amount: amt,
                              isIncome: isIncome,
                              category: selectedCategory ?? before.category,
                              description: descCtrl.text.trim(),
                              date: before.date,
                              walletId: selectedWallet ?? before.walletId,
                            );
                            context.read<HomeBloc>().add(UpdateTransaction(before: before, after: after));
                            Navigator.pop(context, after);
                          } else {
                            final txn = Txn(
                              id: UniqueKey().toString(),
                              amount: amt,
                              isIncome: isIncome,
                              category: selectedCategory ?? (isIncome ? 'Income' : 'Expense'),
                              description: descCtrl.text.trim(),
                              date: DateTime.now(),
                              walletId: selectedWallet!,
                            );
                            context.read<HomeBloc>().add(AddTransaction(txn));
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
}
