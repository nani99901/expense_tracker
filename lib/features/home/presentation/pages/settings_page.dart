import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/core/utils/currency_utils.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currency = 'India (INR)';
  String _theme = 'Use device theme';
  String _security = 'PIN';

  @override
  void initState() {
    super.initState();
    _loadCurrencyFromFirestore();
  }

  Future<void> _loadCurrencyFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      if (data != null && data['currencyCode'] is String) {
        final code = data['currencyCode'] as String;
        setState(() {
          _currency = CurrencyUtils.labelForCode(code);
        });
      }
    } catch (_) {}
  }

  Future<void> _openOptions(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String current,
    required void Function(String) onSelected,
  }) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => _SettingsOptionsPage(
          title: title,
          options: options,
          initialSelected: current,
        ),
      ),
    );
    if (result != null && result.isNotEmpty) {
      onSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.arrow_back, size: 24),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              _SettingsItem(
                title: 'Currency',
                trailing: _currency,
                onTap: () {
                  _openOptions(
                    context,
                    title: 'Currency',
                    options: const [
                      'India (INR)',
                      'United States (USD)',
                      'Indonesia (IDR)',
                      'Japan (JPY)',
                      'Russia (RUB)',
                      'Germany (EUR)',
                      'Korea (WON)',
                    ],
                    current: _currency,
                    onSelected: (value) async {
                      setState(() => _currency = value);

                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        final code = CurrencyUtils.codeForLabel(value);
                        try {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .set(
                            {
                              'currencyCode': code,
                            },
                            SetOptions(merge: true),
                          );
                        } catch (_) {}
                      }
                    },
                  );
                },
              ),
              _Divider(),
              _SettingsItem(
                title: 'Theme',
                trailing: _theme,
                onTap: () {
                  _openOptions(
                    context,
                    title: 'Theme',
                    options: const [
                      'Light',
                      'Dark',
                      'Use device theme',
                    ],
                    current: _theme,
                    onSelected: (value) {
                      setState(() => _theme = value);
                    },
                  );
                },
              ),
              _Divider(),
              _SettingsItem(
                title: 'Security',
                trailing: _security,
                onTap: () {
                  _openOptions(
                    context,
                    title: 'Security',
                    options: const [
                      'PIN',
                      'Fingerprint',
                      'Face ID',
                    ],
                    current: _security,
                    onSelected: (value) {
                      setState(() => _security = value);
                    },
                  );
                },
              ),
              _Divider(),
              const _SettingsItem(title: 'About', trailing: null),
              _Divider(),
              const _SettingsItem(title: 'Help', trailing: null),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({required this.title, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                if (trailing != null)
                  Text(
                    trailing!,
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  ),
                const SizedBox(width: 8),
                SvgPicture.asset('assets/arrow-right-2.svg'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Container(height: 1, color: Colors.grey[200]),
    );
  }
}

class _SettingsOptionsPage extends StatefulWidget {
  final String title;
  final List<String> options;
  final String initialSelected;

  const _SettingsOptionsPage({
    required this.title,
    required this.options,
    required this.initialSelected,
  });

  @override
  State<_SettingsOptionsPage> createState() => _SettingsOptionsPageState();
}

class _SettingsOptionsPageState extends State<_SettingsOptionsPage> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.separated(
        itemCount: widget.options.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final value = widget.options[index];
          final selected = value == _selected;
          return ListTile(
            title: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
            trailing: selected
                ? SizedBox(
                  height: 20,
                  width: 20,
                  child: SvgPicture.asset('assets/success.svg',))
                : null,
            onTap: () {
              setState(() {
                _selected = value;
              });
              Navigator.of(context).pop(value);
            },
          );
        },
      ),
    );
  }
}
