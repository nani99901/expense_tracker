import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/core/constants/colors.dart';
import 'package:expense_tracker/features/home/domain/entities/transaction.dart';
import 'package:expense_tracker/features/home/presentation/pages/detail_transaction.dart';
import 'package:expense_tracker/features/home/presentation/pages/financial_report_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String _filterBy = 'All'; 
  String _sortBy = ''; 
  DateTime _selectedMonth = DateTime.now();
  
  Future<void> _pickMonth() async {
    final picked = await showMonthYearPicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  void _openFilterSheet() {
    String tempFilterBy = _filterBy;
    String tempSortBy = _sortBy;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Title and Reset
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Transaction',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setModalState(() {
                            tempFilterBy = 'All';
                            tempSortBy = '';
                          });
                        },
                        child: Container(
                          width: 80,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Reset',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Filter By
                  const Text(
                    'Filter By',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFilterChip('Income', tempFilterBy, (value) {
                        setModalState(() {
                          tempFilterBy = value;
                        });
                      }),
                      const SizedBox(width: 8),
                      _buildFilterChip('Expense', tempFilterBy, (value) {
                        setModalState(() {
                          tempFilterBy = value;
                        });
                      }),
                      const SizedBox(width: 8),
                      _buildFilterChip('Transfer', tempFilterBy, (value) {
                        setModalState(() {
                          tempFilterBy = value;
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Sort By
                  const Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildSortChip('Highest', tempSortBy, (value) {
                        setModalState(() {
                          tempSortBy = value;
                        });
                      }),
                      const SizedBox(width: 8),
                      _buildSortChip('Lowest', tempSortBy, (value) {
                        setModalState(() {
                          tempSortBy = value;
                        });
                      }),
                      const SizedBox(width: 8),
                      _buildSortChip('Newest', tempSortBy, (value) {
                        setModalState(() {
                          tempSortBy = value;
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildSortChip('Oldest', tempSortBy, (value) {
                        setModalState(() {
                          tempSortBy = value;
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Category
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Choose Category',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '0 Selected',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF91919F),
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Color(0xFF91919F),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        setState(() {
                          _filterBy = tempFilterBy;
                          _sortBy = tempSortBy;
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text(
                        'Apply',
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
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String currentFilter, ValueChanged<String> onTap) {
    final selected = currentFilter == label;
    return GestureDetector(
      onTap: () => onTap(label),
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? Colors.transparent : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selected ? AppColors.primary : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, String currentSort, ValueChanged<String> onTap) {
    final selected = currentSort == label;
    return GestureDetector(
      onTap: () => onTap(label),
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? Colors.transparent : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: selected ? AppColors.primary : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    int activeFilters = 0;
    if (_filterBy != 'All') activeFilters++;
    if (_sortBy.isNotEmpty) activeFilters++;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _pickMonth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          // const Icon(
                          //   Icons.calendar_today,
                          //   size: 16,
                          //   color: Colors.black87,
                          // ),
                          SvgPicture.asset('assets/arrow-down-2.svg'),
                           SizedBox(width: 6),
                          Text(
                            DateFormat('MMMM yyyy').format(_selectedMonth),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          // const Icon(
                          //   Icons.keyboard_arrow_down,
                          //   size: 20,
                          // ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _openFilterSheet,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.filter_list, size: 20),
                        ),
                        if (activeFilters > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$activeFilters',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FinancialReportPage(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'See your financial report',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: user == null
                  ? const Center(child: Text('Please login to view transactions'))
                  : _TransactionsList(
                      uid: user.uid,
                      filterBy: _filterBy,
                      sortBy: _sortBy,
                      selectedMonth: _selectedMonth,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionsList extends StatelessWidget {
  final String uid;
  final String filterBy;
  final String sortBy;
  final DateTime selectedMonth;

  const _TransactionsList({
    super.key,
    required this.uid,
    required this.filterBy,
    required this.sortBy,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));

    final monthStart = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final nextMonthStart = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);

    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
        .where('date', isLessThan: Timestamp.fromDate(nextMonthStart))
        .orderBy('date', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No transactions found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        final Map<String, List<Txn>> grouped = {};

        for (final doc in docs) {
          final data = doc.data();
          final ts = data['date'] as Timestamp;
          final dt = ts.toDate();

          final txn = Txn(
            id: data['id'] as String? ?? doc.id,
            amount: (data['amount'] as num).toDouble(),
            isIncome: data['isIncome'] as bool? ?? false,
            category: (data['category'] as String?) ?? '',
            description: (data['description'] as String?) ?? '',
            date: dt,
            walletId: (data['walletId'] as String?) ?? 'default',
          );

          String label;
          final dateOnly = DateTime(dt.year, dt.month, dt.day);
          if (dateOnly == todayStart) {
            label = 'Today';
          } else if (dateOnly == yesterdayStart) {
            label = 'Yesterday';
          } else {
            label = DateFormat('d MMM').format(dt);
          }
          grouped.putIfAbsent(label, () => []).add(txn);
        }

        List<Txn> _applyFilterAndSort(List<Txn> list) {
          var result = List<Txn>.from(list);

          // Filter by type
          if (filterBy == 'Income') {
            result = result.where((t) => t.isIncome).toList();
          } else if (filterBy == 'Expense') {
            result = result.where((t) => !t.isIncome).toList();
          } else if (filterBy == 'Transfer') {
            result = result
                .where((t) => t.category.toLowerCase() == 'transfer')
                .toList();
          }

          // Sort
          if (sortBy.isNotEmpty) {
            result.sort((a, b) {
              switch (sortBy) {
                case 'Highest':
                  return b.amount.compareTo(a.amount);
                case 'Lowest':
                  return a.amount.compareTo(b.amount);
                case 'Oldest':
                  return a.date.compareTo(b.date);
                case 'Newest':
                default:
                  return b.date.compareTo(a.date);
              }
            });
          }

          return result;
        }

        final sectionLabels = grouped.keys.toList()
          ..sort((a, b) {
            // Keep Today/Yesterday at top when current month selected
            if (a == 'Today') return -1;
            if (b == 'Today') return 1;
            if (a == 'Yesterday') return -1;
            if (b == 'Yesterday') return 1;
            
            // For date labels like `5 Nov`, parse back to DateTime for ordering
            DateTime parseLabel(String label) {
              if (label == 'Today') return todayStart;
              if (label == 'Yesterday') return yesterdayStart;
              return DateFormat('d MMM').parse(label);
            }

            final da = parseLabel(a);
            final db = parseLabel(b);
            return db.compareTo(da); // newest first
          });

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: sectionLabels.length,
          itemBuilder: (context, index) {
            final label = sectionLabels[index];
            final transactions = _applyFilterAndSort(grouped[label]!);
            
            if (transactions.isEmpty) return const SizedBox.shrink();
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...transactions.map((t) => _TxnTile(txn: t)),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }
}

class _TxnTile extends StatelessWidget {
  final Txn txn;
  const _TxnTile({super.key, required this.txn});

  Color _getCategoryColor() {
    switch (txn.category.toLowerCase()) {
      case 'shopping':
        return const Color(0xFFFFAA00);
      case 'subscription':
        return const Color(0xFF7F3DFF);
      case 'food':
        return const Color(0xFFFF3B30);
      default:
        return Colors.blue;
    }
  }

 Widget _getCategoryIcon() {
    final cat = txn.category.trim().toLowerCase();
    switch (cat) {
      case 'shopping':
        return SvgPicture.asset('assets/basket.svg', width: 24, height: 24);
      case 'subscription':
        return SvgPicture.asset('assets/expense.svg', width: 24, height: 24);
      case 'food':
        return SvgPicture.asset('assets/cutlery.svg', width: 24, height: 24);
      case 'salary':
        return SvgPicture.asset('assets/income.svg', width: 24, height: 24);
      default:
        if (txn.isIncome) {
          return SvgPicture.asset('assets/income.svg', width: 24, height: 24);
        }
        return SvgPicture.asset('assets/expense.svg', width: 24, height: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm a').format(txn.date);
    final amountStr = txn.amount.toStringAsFixed(0);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailTransaction(txn: txn),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getCategoryColor().withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: _getCategoryIcon()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    txn.category.isEmpty
                        ? (txn.isIncome ? 'Income' : 'Expense')
                        : txn.category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    txn.description.isEmpty
                        ? (txn.isIncome ? 'Income' : 'Expense')
                        : txn.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${txn.isIncome ? '+ ' : '- '}₹$amountStr',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: txn.isIncome ? const Color(0xFF00A86B) : const Color(0xFFFF3B30),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}