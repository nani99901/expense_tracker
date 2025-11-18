import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/core/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   centerTitle: true,
      //   iconTheme: const IconThemeData(color: Colors.black),
      //   title: const Text(
      //     'Budget',
      //     style: TextStyle(
      //       color: Colors.black,
      //       fontSize: 18,
      //       fontWeight: FontWeight.w600,
      //     ),
      //   ),
      // ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             Text(
                'Spending by Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
               SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: user == null
                      ? Center(child: Text('No user'))
                      : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('transactions')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                
                            final docs = snapshot.data!.docs;
                            if (docs.isEmpty) {
                              return Center(
                                child: Text('No transactions to show'),
                              );
                            }
                
                            final Map<String, double> categoryTotals = {};
                            double totalExpense = 0;
                
                            for (final doc in docs) {
                              final data = doc.data();
                              final isIncome = (data['isIncome'] as bool?) ?? false;
                              if (isIncome) continue; // only expenses in budget
                              final amount = (data['amount'] as num).toDouble();
                              final category = (data['category'] as String?) ?? 'Other';
                              totalExpense += amount;
                              categoryTotals[category] =
                                  (categoryTotals[category] ?? 0) + amount;
                            }
                
                            if (totalExpense == 0 || categoryTotals.isEmpty) {
                              return const Center(
                                child: Text('No expenses recorded yet'),
                              );
                            }
                
                            final colors = [
                              const Color(0xFF7F3DFF),
                              const Color(0xFFFFAA00),
                              const Color(0xFFFF3B30),
                              const Color(0xFF00A86B),
                              const Color(0xFFFCAC12),
                              const Color(0xFF0077FF),
                            ];
                
                            final entries = categoryTotals.entries.toList();
                            final sections = <PieChartSectionData>[];
                
                            for (var i = 0; i < entries.length; i++) {
                              final e = entries[i];
                              final value = e.value;
                              final percentage = value / totalExpense * 100;
                              
                              sections.add(
                                PieChartSectionData(
                                  color: colors[i % colors.length],
                                  value: value,
                                  title: '${percentage.toStringAsFixed(0)}%',
                                  radius: 60,
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }
                
                            return Column(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: PieChart(
                                    PieChartData(
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 40,
                                      borderData: FlBorderData(show: false),
                                      sections: sections,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 3,
                                  child: ListView.builder(
                                    itemCount: entries.length,
                                    itemBuilder: (context, index) {
                                      final e = entries[index];
                                      final value = e.value;
                                      final percentage = value / totalExpense * 100;
                                      final color = colors[index % colors.length];
                                      
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 14,
                                              height: 14,
                                              decoration: BoxDecoration(
                                                color: color,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                e.key,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '₹${value.toStringAsFixed(0)} (${percentage.toStringAsFixed(0)}%)',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}