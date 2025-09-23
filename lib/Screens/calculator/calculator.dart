import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for TextInputFormatter
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_calculator/Screens/setting/SettingScreen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Required for SharedPreferences
import '../setting/SettingScreen.dart'; // Removed: Assuming '../setting/setting.dart' is sufficient
import '../setting/setting.dart'; // Corrected import for your settings.dart
import 'calculator_methods.dart'; // Assuming this exists and is correct

class MaxValueTextInputFormatter extends TextInputFormatter {
  final double maxValue;
  final int decimalDigits;

  MaxValueTextInputFormatter({this.maxValue = double.infinity, this.decimalDigits = 2});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final RegExp regex = RegExp(r'^\d*\.?\d{0,' + decimalDigits.toString() + r'}$');
    if (!regex.hasMatch(newValue.text)) {
      return oldValue;
    }

    final double? parsedValue = double.tryParse(newValue.text);

    if (parsedValue != null && parsedValue > maxValue) {
      return oldValue;
    }

    return newValue;
  }
}


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
  final _sizeassetController = TextEditingController(); // Renamed for consistency
  final _currencyFormatter = NumberFormat("#,##0.00", "ar_SA");

  // State variables for calculations
  double _baseAmount = 0.0;
  double _taxAmount = 0.0;
  double _commissionAmount = 0.0;
  double _totalAmount = 0.0;
  bool _showResults = false;
  String _pricePerUnitSizeText = ""; // Changed to String, initialized as empty

  // --- SETTINGS STATE ---
  double _taxRate = 0.05; // 5%
  double _commissionRate = 0.025; // 2.5%
  bool _isTaxExempt = false;

  @override
  void initState() {
    super.initState();
    // Load settings from SharedPreferences
    _loadSettings();
    // Use a single listener for both controllers to trigger full recalculation
    _amountController.addListener(_recalculateAll);
    _sizeassetController.addListener(_recalculateAll);
  }

  @override
  void dispose() {
    // Remove listeners before disposing controllers
    _amountController.removeListener(_recalculateAll);
    _sizeassetController.removeListener(_recalculateAll);
    _amountController.dispose();
    _sizeassetController.dispose();
    super.dispose(); // Only one super.dispose() call
  }

  // Method to load settings from shared preferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _taxRate = prefs.getDouble('vat_percentage') ?? 0.05;
      _commissionRate = prefs.getDouble('pursuit_fee_percentage') ?? 0.025;
      _isTaxExempt = prefs.getBool('is_tax_exempt') ?? false;
    });
    _recalculateAll(); // Recalculate after loading settings
  }

  // Combined method to trigger all calculations
  void _recalculateAll() {
    _calculate(); // Updates _baseAmount, _taxAmount, _commissionAmount, _totalAmount
    _calculatePricePerUnit(); // Uses the updated _totalAmount
  }

  // Updated calculation logic to use settings state
  void _calculate() {
    final amountText = _amountController.text;
    final baseValue = double.tryParse(amountText) ?? 0;

    setState(() {
      _baseAmount = baseValue;
      if (_baseAmount > 0) {
        // Calculate tax only if not exempt
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
      // _calculatePricePerUnit() will be called by _recalculateAll
    });
  }

  void _calculatePricePerUnit() {
    final sizeText = _sizeassetController.text; // Use the correct controller
    final sizeValue = double.tryParse(sizeText);

    final currentTotalAmount = _totalAmount; // Use the already calculated total

    setState(() {
      if (sizeValue != null && sizeValue > 0 && currentTotalAmount > 0) {
        final pricePerUnit = currentTotalAmount / sizeValue;

        // Formatter for the price per unit
        final unitPriceFormatter = NumberFormat.currency(
          locale: 'ar_SA',
          symbol: 'ر.س', // Correct currency symbol
          decimalDigits: 2,
        );
        _pricePerUnitSizeText = "${unitPriceFormatter.format(pricePerUnit)} / متر مربع"; // Corrected suffix
      } else {
        _pricePerUnitSizeText = ""; // Clear if inputs are invalid
      }
    });
  }

  void _clearInput() {
    _amountController.clear();
    _sizeassetController.clear(); // Clear the size controller too
    setState(() {
      _baseAmount = 0.0;
      _taxAmount = 0.0;
      _commissionAmount = 0.0;
      _totalAmount = 0.0;
      _showResults = false;
      _pricePerUnitSizeText = ""; // Reset price per unit text
    });
  }

  // --- Method to open settings ---
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
      setState(() {
        _taxRate = newSettings.taxRate;
        _commissionRate = newSettings.commissionRate;
        _isTaxExempt = newSettings.isTaxExempt;
      });
      _recalculateAll(); // Recalculate with new rates
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
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              hintText: '0',
              suffixText: 'ر.س ',
              suffixStyle: TextStyle(fontSize: 18, color: Colors.grey[500]),
            ),
            inputFormatters: [
              MaxValueTextInputFormatter(maxValue: 10000000.0, decimalDigits: 2),
            ],
          ),
          const SizedBox(height: 24), // Spacing between amount and size fields
          const Text(
            'مساحة العقار',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _sizeassetController, // Use the corrected controller name
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              hintText: '0',
              suffixText: 'متر ', // Corrected unit suffix
              suffixStyle: TextStyle(fontSize: 18, color: Colors.grey[500]),
            ),
            inputFormatters: [
              MaxValueTextInputFormatter(maxValue: 10000.0, decimalDigits: 2), // Example max for size
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCard() {
    // Determine the tax label based on exemption status
    final taxLabel = _isTaxExempt ? 'الضريبة (معفي)' : 'الضريبة (${(_taxRate * 100).toStringAsFixed(1)}%)';
    final commissionLabel = 'السعي (${(_commissionRate * 100).toStringAsFixed(1)}%)';
    // Removed old SizeLabel which had a syntax error
    // Now _pricePerUnitSizeText will be displayed directly if it's not empty

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
            // Conditionally display price per unit if calculated
            if (_pricePerUnitSizeText.isNotEmpty)
              _buildTextResultRow('سعر المتر المربع', _pricePerUnitSizeText), // Use helper for formatted text

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

  // New helper widget to display a row with a label and a pre-formatted text value
  Widget _buildTextResultRow(String label, String formattedValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          Text(
            formattedValue, // Use the already formatted string
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
        label: const Text('مسح' , style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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