import 'package:expense_tracker/core/constants/colors.dart';
import 'package:expense_tracker/features/home/domain/entities/transaction.dart';
import 'package:expense_tracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:expense_tracker/features/home/presentation/bloc/home_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:expense_tracker/features/home/presentation/pages/detail_transaction.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<String> _options = ['Today', 'Week', 'Month', 'Year'];
  DateTime _selectedMonth = DateTime.now();

  Future<void> pickMonth() async {
    final picked = await showMonthYearPicker(
      // builder: (context, child) {
      //     return Container(
      //       width: double.infinity,
      //       child: Dialog(
      //               // insetPadding: const EdgeInsets.symmetric(
      //               //   horizontal: 60, // controls width
      //               //   // vertical: 80,   // controls height
      //               // ),
      //               shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(16),
      //               ),
      //               child: child,
      //             ),
      //     );
      // },
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) {
      setState(() => _selectedMonth = DateTime(picked.year, picked.month));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFfef6e6),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.primary,
                            ),
                          ),
                          // const Spacer(),
                          GestureDetector(
                            onTap: () {
                              pickMonth();
                            },
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
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.black87,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(DateFormat('MMMM yyyy').format(_selectedMonth), style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.keyboard_arrow_down, size: 20),
                                ],
                              ),
                            ),
                          ),
                          // const SizedBox(width: 12),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEE5FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: Color(0xFF7F3DFF),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Monthly aggregates for selected month
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: () {
                        if (FirebaseAuth.instance.currentUser == null) {
                          return Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
                        }
                        final start = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
                        final end = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
                        return FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('transactions')
                            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
                            .where('date', isLessThan: Timestamp.fromDate(end))
                            .snapshots();
                      }(),
                      builder: (context, snapshot) {
                        double totalIncome = 0;
                        double totalExpense = 0;
                        if (snapshot.hasData) {
                          for (final doc in snapshot.data!.docs) {
                            final data = doc.data();
                            final amt = (data['amount'] as num).toDouble();
                            final income = (data['isIncome'] as bool?) ?? false;
                            if (income) {
                              totalIncome += amt;
                            } else {
                              totalExpense += amt;
                            }
                          }
                        }
                        final balance = totalIncome - totalExpense;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Column(
                                children: [
                                  const Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Account Balance',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '₹${balance.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00A86B),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset('assets/total_income.svg'),
                                          // Container(
                                          //   width: 48,
                                          //   height: 48,
                                          //   decoration: BoxDecoration(
                                          //     color: Colors.white,
                                          //     borderRadius:
                                          //         BorderRadius.circular(12),
                                          //   ),
                                          //   child: const Icon(
                                          //     Icons.arrow_downward,
                                          //     color: Color(0xFF00A86B),
                                          //   ),
                                          // ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Income',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '₹${totalIncome.toStringAsFixed(0)}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF3B30),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset('assets/total_expense.svg'),
                                          // Container(
                                          //   width: 48,
                                          //   height: 48,
                                          //   decoration: BoxDecoration(
                                          //     color: Colors.white,
                                          //     borderRadius:
                                          //         BorderRadius.circular(12),
                                          //   ),
                                          //   child: const Icon(
                                          //     Icons.arrow_upward,
                                          //     color: Color(0xFFFF3B30),
                                          //   ),
                                          // ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Expenses',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '₹${totalExpense.toStringAsFixed(0)}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // Spend Frequency Chart
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Spend Frequency',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 170,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: () {
                            final now = DateTime.now();
                            late DateTime start;
                            if (_selectedIndex == 0) {
                              // Today
                              start = DateTime(now.year, now.month, now.day);
                            } else if (_selectedIndex == 1) {
                              // last 7 days including today
                              final today = DateTime(now.year, now.month, now.day);
                              start = today.subtract(const Duration(days: 6));
                            } else if (_selectedIndex == 2) {
                              // last 30 days including today
                              final today = DateTime(now.year, now.month, now.day);
                              start = today.subtract(const Duration(days: 29));
                            } else {
                              // from Jan 1st
                              start = DateTime(now.year, 1, 1);
                            }
                            if (FirebaseAuth.instance.currentUser == null) {
                              return Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
                            }
                            return FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection('transactions')
                                .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
                                .orderBy('date', descending: false)
                                .snapshots();
                          }(),
                          builder: (context, snapshot) {
                            
                            final now = DateTime.now();
                            int bucketCount;
                            int Function(DateTime) bucketIndex;
                            if (_selectedIndex == 0) {
                              bucketCount = 24; // hours
                              bucketIndex = (d) => d.hour;
                            } else if (_selectedIndex == 1) {
                              bucketCount = 7; // days
                              final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
                              bucketIndex = (d) => d.difference(start).inDays.clamp(0, 6);
                            } else if (_selectedIndex == 2) {
                              bucketCount = 30; // days
                              final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
                              bucketIndex = (d) => d.difference(start).inDays.clamp(0, 29);
                            } else {
                              bucketCount = 12; // months
                              bucketIndex = (d) => (d.month - 1).clamp(0, 11);
                            }

                            final buckets = List<double>.filled(bucketCount, 0);
                            if (snapshot.hasData) {
                              for (final doc in snapshot.data!.docs) {
                                final data = doc.data();
                                final isIncome = (data['isIncome'] as bool?) ?? false;
                                if (isIncome) continue; 
                                final ts = data['date'] as Timestamp;
                                final dt = ts.toDate();
                                final amt = (data['amount'] as num).toDouble();
                                final idx = bucketIndex(dt);
                                if (idx >= 0 && idx < buckets.length) {
                                  buckets[idx] += amt;
                                }
                              }
                            }

                            final spots = <FlSpot>[];
                            for (var i = 0; i < buckets.length; i++) {
                              spots.add(FlSpot(i.toDouble(), buckets[i]));
                            }

                            return LineChart(
                              LineChartData(
                                backgroundColor: Colors.white,
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
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
                                      color: AppColors.primary.withOpacity(0.08),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final segmentWidth = constraints.maxWidth / _options.length;

                    return Container(
                      height: 46,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xfffcfcfc)),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Stack(
                        children: [
                          // Sliding highlight exactly matches segment width
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeOutCubic,
                            left: _selectedIndex * segmentWidth,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: segmentWidth,
                              // Create visual inset inside the pill instead of using margin
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                                vertical: 6.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7E0),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),

                          // Options row on top
                          Row(
                            children: List.generate(_options.length, (index) {
                              final optionText = _options[index];
                              final isSelected = _selectedIndex == index;

                              return Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() => _selectedIndex = index);
                                  },
                                  child: Container(
                                    height: double.infinity,
                                    alignment: Alignment.center,
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 160,
                                      ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: isSelected
                                            ? const Color(0xFFFFA000)
                                            : const Color(0xFFB0B0B0),
                                      ),
                                      child: Text(optionText),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 24),
              // Recent Transactions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transaction',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEE5FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseAuth.instance.currentUser == null
                    ? const Stream.empty()
                    : FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('transactions')
                        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(_selectedMonth.year, _selectedMonth.month, 1)))
                        .where('date', isLessThan: Timestamp.fromDate(DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1)))
                        .orderBy('date', descending: true)
                        .limit(10)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('No recent transactions'),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final d = docs[index].data();
                      final txn = Txn(
                        id: d['id'] as String? ?? docs[index].id,
                        amount: (d['amount'] as num).toDouble(),
                        isIncome: d['isIncome'] as bool? ?? false,
                        category: (d['category'] as String?) ?? '',
                        description: (d['description'] as String?) ?? '',
                        date: (d['date'] as Timestamp).toDate(),
                        walletId: (d['walletId'] as String?) ?? 'default',
                      );
                      return TransactionTile(txn: txn, isIncome: txn.isIncome);
                    },
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final Txn txn;
  final bool isIncome;
  TransactionTile({required this.txn, required this.isIncome});

  Widget getCategoryImage() {
    final cat = txn.category.trim().toLowerCase();
    switch (cat) {
      case 'shopping':
        return SvgPicture.asset('assets/basket.svg', width: 24, height: 24);

      case 'subscription':
        return SvgPicture.asset('assets/expense.svg', width: 24, height: 24);

      case 'food':
        return SvgPicture.asset('assets/cutlery.svg', width: 24, height: 24);

      case 'transport':
        return SvgPicture.asset('assets/expense.svg', width: 24, height: 24);

      case 'rent':
        return SvgPicture.asset('assets/expense.svg', width: 24, height: 24);

      case 'gifts':
        return SvgPicture.asset('assets/income.svg', width: 24, height: 24);

      case 'salary':
        return SvgPicture.asset('assets/income.svg', width: 24, height: 24);

      // case 'salary':
      //   return SvgPicture.asset('assets/income.svg', width: 24, height: 24);

      default:
        if (isIncome == true) {
          return SvgPicture.asset(
            'assets/income.svg', 
            width: 24,
            height: 24,
          );
        } else {
          return SvgPicture.asset(
            'assets/expense.svg', 
            width: 24,
            height: 24,
          );
        }
    }
  }

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

  @override
  Widget build(BuildContext context) {
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getCategoryColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: getCategoryImage(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  txn.description.isEmpty ? 'No description' : txn.description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${txn.isIncome ? '+' : '-'}₹${txn.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: txn.isIncome
                      ? const Color(0xFF00A86B)
                      : const Color(0xFFFF3B30),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${txn.date.hour}:${txn.date.minute.toString().padLeft(2, '0')} ${txn.date.hour >= 12 ? 'PM' : 'AM'}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
