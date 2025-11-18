import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/core/constants/colors.dart';
import 'package:expense_tracker/features/home/domain/entities/transaction.dart';
import 'package:expense_tracker/features/home/presentation/pages/detail_transaction.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

class FinancialReportPage extends StatefulWidget {
  const FinancialReportPage({super.key});

  @override
  State<FinancialReportPage> createState() => _FinancialReportPageState();
}

class _FinancialReportPageState extends State<FinancialReportPage> {
  bool _showIncome = false; // false = Expense, true = Income
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Financial Report',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset('assets/arrow-down-2.svg'),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('MMMM yyyy').format(_selectedMonth),
                            style: const TextStyle(fontSize: 14),
                          ),
                          // const SizedBox(width: 4),
                          // const Icon(
                          //   Icons.keyboard_arrow_down,
                          //   size: 20,
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (user == null)
              const Expanded(
                child: Center(child: Text('No user')),
              )
            else
              Expanded(
                child: FinancialReportContent(
                  uid: user.uid,
                  selectedMonth: _selectedMonth,
                  showIncome: _showIncome,
                  onToggleType: (income) {
                    setState(() {
                      _showIncome = income;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FinancialReportContent extends StatelessWidget {
  final String uid;
  final DateTime selectedMonth;
  final bool showIncome;
  final ValueChanged<bool> onToggleType;

   FinancialReportContent({
    required this.uid,
    required this.selectedMonth,
    required this.showIncome,
    required this.onToggleType,
  });

  @override
  Widget build(BuildContext context) {
    final start = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final end = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);

    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date', descending: false)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        final txns = <Txn>[];
        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final data = doc.data();
            final txn = Txn(
              id: data['id'] as String? ?? doc.id,
              amount: (data['amount'] as num).toDouble(),
              isIncome: data['isIncome'] as bool? ?? false,
              category: (data['category'] as String?) ?? '',
              description: (data['description'] as String?) ?? '',
              date: (data['date'] as Timestamp).toDate(),
              walletId: (data['walletId'] as String?) ?? 'default',
            );
            txns.add(txn);
          }
        }

        final filtered = txns.where((t) => t.isIncome == showIncome).toList();
        final total = filtered.fold<double>(0, (sum, t) => sum + t.amount);

        
        final daysInMonth = DateUtils.getDaysInMonth(selectedMonth.year, selectedMonth.month);
        final buckets = List<double>.filled(daysInMonth, 0);
        for (final t in filtered) {
          final dayIndex = t.date.day - 1;
          if (dayIndex >= 0 && dayIndex < buckets.length) {
            buckets[dayIndex] += t.amount;
          }
        }
        final spots = <FlSpot>[];
        for (var i = 0; i < buckets.length; i++) {
          spots.add(FlSpot(i.toDouble(), buckets[i]));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '₹${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                // gradient: LinearGradient(
                //   colors: [
                //     AppColors.primary.withOpacity(0.2),
                //     AppColors.primary.withOpacity(0.05),
                //   ],
                //   begin: Alignment.topCenter,
                //   end: Alignment.bottomCenter,
                // ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onToggleType(false),
                        child: Container(
                          decoration: BoxDecoration(
                            color: showIncome ? Colors.transparent : AppColors.primary,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Expense',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: showIncome ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onToggleType(true),
                        child: Container(
                          decoration: BoxDecoration(
                            color: showIncome ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Income',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: showIncome ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.keyboard_arrow_down, size: 20),
                      SizedBox(width: 4),
                      Text(
                        'Transaction',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SvgPicture.asset('assets/filter.svg', width: 20, height: 20),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemBuilder: (context, index) {
                  final txn = filtered[index];
                  return _ReportTxnTile(txn: txn);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ReportTxnTile extends StatelessWidget {
  final Txn txn;
  const _ReportTxnTile({required this.txn});

  Color _getCategoryColor() {
    switch (txn.category.toLowerCase()) {
      case 'shopping':
        return const Color(0xFFFFAA00);
      case 'subscription':
        return const Color(0xFF7F3DFF);
      case 'food':
        return const Color(0xFFFF3B30);
      default:
        return Colors.green;
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
                  (txn.isIncome ? '+ ' : '- ') + '₹$amountStr',
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
