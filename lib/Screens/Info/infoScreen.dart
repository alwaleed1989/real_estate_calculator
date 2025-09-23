import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Make sure to add this import

class Infoscreen extends StatelessWidget {
  const Infoscreen({super.key});

  // Function to launch the email client
  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'dev.alwaleed@gmail.com',
      query: 'subject=ملاحظات حول تطبيق حاسبة العقار&body=السلام عليكم،',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not launch $emailUri';
      }
    } catch (e) {
      // Show a snackbar on error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكن فتح تطبيق البريد الإلكتروني.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Removed 'const' because of the InkWell's onTap function
    return Scaffold(
      // Use SingleChildScrollView to prevent overflow on small screens
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Makes children fill the width
            children: [
              const Text(
                'حاسبة العقار',
                textAlign: TextAlign.center, // Center the title
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 24, // Made the title bigger
                ),
              ),
              const Divider(height: 30), // Increased height for more space
              const Text(
                'تم عمل هذا التطبيق لتسهيل حساب العقارات داخل المملكة العربية السعودية، حيث يوفر أداة شاملة لحساب التكاليف والضرائب المرتبطة بشراء العقارات بكل سهولة وشفافية، مثل:\n\n'
                    '• ضريبة التصرفات العقارية (5%)\n'
                    '• عمولة الوسيط أو السعي (2.5%)\n\n'
                    'في حال لديك ملاحظات لتحسين التطبيق، نأمل التواصل معنا عبر البريد الإلكتروني:',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20), // Added space before the email

              // This is the correctly placed and functional InkWell
              InkWell(
                onTap: () => _launchEmail(context), // Added the onTap functionality
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'dev.alwaleed@gmail.com',
                    textAlign: TextAlign.center, // Centered the email text
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                    ),
                  ),
                ),
              ),
            ], // Children list ends here
          ),
        ),
      ),
    ); // Scaffold ends here
  }
}