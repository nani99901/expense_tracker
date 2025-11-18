import 'package:expense_tracker/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/features/home/domain/entities/transaction.dart';
import 'package:expense_tracker/features/home/presentation/pages/save_transaction.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:expense_tracker/features/home/presentation/bloc/home_event.dart';

class DetailTransaction extends StatefulWidget {
  final Txn txn;
  const DetailTransaction({super.key, required this.txn});

  @override
  State<DetailTransaction> createState() => _DetailTransactionState();
}

class _DetailTransactionState extends State<DetailTransaction> {
  late Txn _txn;

  @override
  void initState() {
    super.initState();
    _txn = widget.txn;
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _txn.isIncome;
    final color = isIncome ? const Color(0xFF00A86B) : const Color(0xFFFD3C4A);

    final dateStr = DateFormat('EEEE d MMMM yyyy').format(_txn.date);
    final timeStr = DateFormat('HH:mm').format(_txn.date);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: color,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Detail Transaction",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () async {
                // Confirm bottom sheet
                final confirmed = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: false,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (ctx) {
                    return SizedBox(
                      height: 260,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                            'Remove this transaction?',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            'Are you sure you wanna remove this\ntransaction?',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Color(0xFF707070)),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('No'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    elevation: 0,
                                  ),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Yes', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                        ],
                      ),
                    ));
                  },
                );

                if (confirmed == true) {
                  // Dispatch delete
                  context.read<HomeBloc>().add(DeleteTransaction(_txn));

                  // Show success dialog
                  // ignore: use_build_context_synchronously
                  await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dCtx) {
                      return Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE9F7EF),
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset('assets/success.svg'),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Transaction has been successfully removed',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(  
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  onPressed: () => Navigator.pop(dCtx),
                                  child: const Text('OK', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );

                  // After dialog, go back to dashboard
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: SvgPicture.asset(
                "assets/trash.svg",
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          )
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddTxnPage(isIncome: _txn.isIncome, initialTxn: _txn),
                  ),
                ).then((result) {
                  if (result is Txn) {
                    setState(() {
                      _txn = result;
                    });
                  }
                });
              },
              child: const Text(
                "Edit",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),

      
      body: Column(
        children: [
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '₹${_txn.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:  8.0),
                  child: Text(
                    _txn.description.isEmpty
                        ? (isIncome ? "Salary" : "Buy some grocery")
                        : _txn.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "$dateStr   $timeStr",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

         
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                /// Main white scrolling content
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF91919F),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _txn.description.isEmpty
                              ? "Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint."
                              : _txn.description,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Color(0xFF0D0E0F),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          "Attachment",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF91919F),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            "https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=600",
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),

                
                Positioned(
                  top: -40,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFF1F1FA),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _infoChip("Type",
                              isIncome ? "Income" : "Expense"),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoChip(
                              "Category",
                              _txn.category.isEmpty
                                  ? "Shopping"
                                  : _txn.category),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoChip(
                              "Wallet",
                              _txn.walletId.isEmpty
                                  ? "Wallet"
                                  : _txn.walletId),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF91919F),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF292B2D),
            ),
          ),
        ),
      ],
    );
  }
}
