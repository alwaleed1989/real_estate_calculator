import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../setting/SettingScreen.dart';
import '../setting/setting.dart';

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
        // Define a modern style for the bottom sheet
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
  final _currencyFormatter = NumberFormat("#,##0.00", "ar_SA");

  // State variables for calculations
  double _baseAmount = 0.0;
  double _taxAmount = 0.0;
  double _commissionAmount = 0.0;
  double _totalAmount = 0.0;
  bool _showResults = false;

  // --- SETTINGS STATE ---
  // Default settings values
  double _taxRate = 0.05; // 5%
  double _commissionRate = 0.025; // 2.5%
  bool _isTaxExempt = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_calculate);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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
    });
  }

  void _clearInput() {
    _amountController.clear();
  }

  // --- Method to open settings ---
  void _openSettings() async {
    // Show the modal bottom sheet and wait for a result
    final newSettings = await showModalBottomSheet<CalculatorSettings>(
      context: context,
      isScrollControlled: true, // Important for keyboard handling
      builder: (context) => SettingsBottomSheet(
        initialTaxRate: _taxRate,
        initialCommissionRate: _commissionRate,
        isTaxExempt: _isTaxExempt,
      ),
    );

    // If the user saved new settings, update the state and recalculate
    if (newSettings != null) {
      setState(() {
        _taxRate = newSettings.taxRate;
        _commissionRate = newSettings.commissionRate;
        _isTaxExempt = newSettings.isTaxExempt;
      });
      _calculate(); // Recalculate with new rates
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset is set to false to prevent the UI from resizing when keyboard appears,
      // as we are handling it with SingleChildScrollView.
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('حاسبة العقار', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.grey[600]),
            onPressed: _openSettings, // Open settings on tap
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // The main content is wrapped in Expanded and SingleChildScrollView to make it scrollable.
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
            // The clear button is kept outside the scroll view to be always visible at the bottom.
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
              suffixText: 'ر.س',
              suffixStyle: TextStyle(fontSize: 18, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCard() {
    // Determine the tax label based on exemption status
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
    // return SizedBox(
    //   width: double.infinity,
    //   child: TextButton.icon(
    //     icon: const Icon(Icons.delete_outline),
    //     label: const Text('مسح'),
    //     onPressed: _clearInput,
    //     style: TextButton.styleFrom(
    //       foregroundColor: Colors.red,
    //       padding: const EdgeInsets.symmetric(vertical: 12),
    //       textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    //     ),
    //   ),
    // );
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.delete_outline),
        label: const Text('مسح'),
        onPressed: _clearInput, // يجب أن تكون هذه الدالة معرفة في الكلاس الخاص بك
        style: ElevatedButton.styleFrom(
          // لون الخلفية للزر
          backgroundColor: Colors.red,
          // لون الأيقونة والنص
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          // هذا السطر يجعله مستطيلاً بحواف دائرية قليلاً
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );

  }
}