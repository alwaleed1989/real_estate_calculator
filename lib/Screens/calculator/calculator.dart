// File: lib/Screens/calculator_screen.dart

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart'; // ✔️ ADDED
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_calculator/Screens/Info/infoScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../setting/SettingScreen.dart';
import '../setting/setting.dart';

// ✔️ REMOVED: The MaxValueTextInputFormatter class is no longer needed.

class RealEstateCalculatorApp extends StatelessWidget {
  const RealEstateCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حاسبة العقار',
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
        textTheme: GoogleFonts.tajawalTextTheme(Theme.of(context).textTheme),
        bottomSheetTheme: const BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          backgroundColor: Colors.white,
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _amountController = TextEditingController();
  final _sizeassetController = TextEditingController();
  final _currencyFormatter = NumberFormat("#,##0.00", "ar_SA");

  // ✔️ ADDED: Define the formatter as a state variable
  final CurrencyTextInputFormatter _amountFormatter = CurrencyTextInputFormatter.currency(
    locale: 'ar_SA',
    decimalDigits: 0,
    symbol: 'ر.س ',
    // enableGrouping: true,
  );

  double _baseAmount = 0.0;
  double _taxAmount = 0.0;
  double _commissionAmount = 0.0;
  double _totalAmount = 0.0;
  bool _showResults = false;
  String _pricePerUnitSizeText = "";

  double _taxRate = 0.05; // 5%
  double _commissionRate = 0.025; // 2.5%
  bool _isTaxExempt = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _amountController.addListener(_recalculateAll);
    _sizeassetController.addListener(_recalculateAll);
  }

  @override
  void dispose() {
    _amountController.removeListener(_recalculateAll);
    _sizeassetController.removeListener(_recalculateAll);
    _amountController.dispose();
    _sizeassetController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _taxRate = prefs.getDouble('vat_percentage') ?? 0.05;
      _commissionRate = prefs.getDouble('pursuit_fee_percentage') ?? 0.025;
      _isTaxExempt = prefs.getBool('is_tax_exempt') ?? false;
    });
    _recalculateAll();
  }

  Future<void> _saveSettingsToPrefs(CalculatorSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('vat_percentage', settings.taxRate);
    await prefs.setDouble('pursuit_fee_percentage', settings.commissionRate);
    await prefs.setBool('is_tax_exempt', settings.isTaxExempt);
  }

  void _recalculateAll() {
    _calculate();
    _calculatePricePerUnit();
  }

  // ✔️ MODIFIED: Get the unformatted value from the formatter
  void _calculate() {
    // This now correctly reads the number from the formatted text
    final baseValue = _amountFormatter.getUnformattedValue().toDouble();

    setState(() {
      _baseAmount = baseValue;
      if (_baseAmount > 0) {
        _taxAmount = _isTaxExempt ? 0 : _baseAmount * _taxRate;
        _commissionAmount = _baseAmount * _commissionRate;
        _totalAmount = _baseAmount + _taxAmount + _commissionAmount;
        _showResults = true;
      } else {
        _taxAmount = 0.0;
        _commissionAmount = 0.0;
        _totalAmount = 0.0;
        _showResults = false;
      }
    });
  }

  void _calculatePricePerUnit() {
    final sizeText = _sizeassetController.text;
    final sizeValue = double.tryParse(sizeText);
    final currentTotalAmount = _totalAmount;

    setState(() {
      if (sizeValue != null && sizeValue > 0 && currentTotalAmount > 0) {
        final pricePerUnit = currentTotalAmount / sizeValue;
        final unitPriceFormatter = NumberFormat.currency(
          locale: 'ar_SA',
          symbol: 'ر.س',
          decimalDigits: 2,
        );
        _pricePerUnitSizeText = "${unitPriceFormatter.format(pricePerUnit)} /  متر ";
      } else {
        _pricePerUnitSizeText = "";
      }
    });
  }

  void _clearInput() {
    _amountController.clear();
    _sizeassetController.clear();
    setState(() {
      _baseAmount = 0.0;
      _taxAmount = 0.0;
      _commissionAmount = 0.0;
      _totalAmount = 0.0;
      _showResults = false;
      _pricePerUnitSizeText = "";
    });
  }

  void _openSettings() async {
    final newSettings = await showModalBottomSheet<CalculatorSettings>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SettingsBottomSheet(
        initialTaxRate: _taxRate,
        initialCommissionRate: _commissionRate,
        isTaxExempt: _isTaxExempt,
      ),
    );

    if (newSettings != null) {
      await _saveSettingsToPrefs(newSettings);
      setState(() {
        _taxRate = newSettings.taxRate;
        _commissionRate = newSettings.commissionRate;
        _isTaxExempt = newSettings.isTaxExempt;
      });
      _recalculateAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('حاسبة العقار', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.black),
          tooltip: 'Menu',
          onPressed: () {
            showModalBottomSheet(context: context, builder: (context) => Infoscreen(),);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.grey[600]),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildInputCard(),
                    const SizedBox(height: 24),
                    _buildResultsCard(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _buildClearButton(),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مبلغ العقار الأساسي',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          // ✔️ MODIFIED: This TextField now uses the CurrencyTextInputFormatter
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              hintText: '0',
              contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            ),
            inputFormatters: [
              _amountFormatter,
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'مساحة العقار',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          // ✔️ MODIFIED: Improved this TextField for consistency
          TextField(
            controller: _sizeassetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              hintText: '0',
              suffixText: 'متر',
              suffixStyle: TextStyle(fontSize: 18, color: Colors.grey[500]),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              LengthLimitingTextInputFormatter(10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCard() {
    final taxLabel = _isTaxExempt ? 'الضريبة (معفي)' : 'الضريبة (${(_taxRate * 100).toStringAsFixed(1)}%)';
    final commissionLabel = 'السعي (${(_commissionRate * 100).toStringAsFixed(1)}%)';

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: _showResults ? 1.0 : 0.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تفاصيل التكلفة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildResultRow('المبلغ الأساسي', _baseAmount),
            _buildResultRow(taxLabel, _taxAmount),
            _buildResultRow(commissionLabel, _commissionAmount),
            if (_pricePerUnitSizeText.isNotEmpty)
              const Divider(height: 24),

            _buildTextResultRow('سعر المتر من المبلغ الاساسي', _pricePerUnitSizeText),
            const Divider(height: 24),

            _buildTotalRow('الإجمالي', _totalAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          Text(
            '${_currencyFormatter.format(value)} ر.س',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTextResultRow(String label, String formattedValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
          Text(
            formattedValue,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(
          '${_currencyFormatter.format(value)} ر.س',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildClearButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.delete_outline),
        label: const Text('مسح'),
        onPressed: _clearInput,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}