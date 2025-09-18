import 'package:url_launcher/url_launcher.dart';

class MessagingHelper {
  // دالة لإرسال رسالة واتساب
  static Future<void> sendWhatsApp(String phone, String message ) async {
    // تأكد من أن رقم الهاتف يبدأ برمز الدولة (مثال: +966)
    // قم بإزالة أي مسافات أو أصفار في البداية
    String formattedPhone = phone.replaceAll(RegExp(r'[\s+]'), '');
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '966${formattedPhone.substring(1)}';
    }

    final Uri whatsappUrl = Uri.parse(
      'https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message )}',
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      // يمكنك هنا عرض رسالة خطأ إذا لم يكن واتساب مثبتًا
      throw 'Could not launch $whatsappUrl';
    }
  }

  // دالة لإرسال رسالة SMS (كخيار بديل)
  static Future<void> sendSms(String phone, String message) async {
    final Uri smsUrl = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: <String, String>{
        'body': message,
      },
    );

    if (await canLaunchUrl(smsUrl)) {
      await launchUrl(smsUrl);
    } else {
      throw 'Could not launch $smsUrl';
    }
  }
}
