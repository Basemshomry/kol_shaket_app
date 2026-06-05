import '../services/language_service.dart';

class AppStrings {
  static String get _lang => LanguageService.instance.languageCode;

  static String text({
    required String he,
    required String en,
    required String ar,
  }) {
    switch (_lang) {
      case 'en':
        return en;
      case 'ar':
        return ar;
      default:
        return he;
    }
  }

  static String get appName => text(he: 'קול שקט', en: 'Kol Shaket', ar: 'صوت هادئ');
  static String get home => text(he: 'בית', en: 'Home', ar: 'الرئيسية');
  static String get ai => text(he: 'AI', en: 'AI', ar: 'الذكاء الاصطناعي');
  static String get reports => text(he: 'פניות', en: 'Reports', ar: 'التوجهات');
  static String get chats => text(he: 'צ׳אטים', en: 'Chats', ar: 'المحادثات');
  static String get profile => text(he: 'פרופיל', en: 'Profile', ar: 'الملف الشخصي');
  static String get language => text(he: 'שפה', en: 'Language', ar: 'اللغة');
  static String get hebrew => text(he: 'עברית', en: 'Hebrew', ar: 'العبرية');
  static String get english => text(he: 'אנגלית', en: 'English', ar: 'الإنجليزية');
  static String get arabic => text(he: 'ערבית', en: 'Arabic', ar: 'العربية');
  static String get logout => text(he: 'התנתקות', en: 'Logout', ar: 'تسجيل الخروج');

  static String get login => text(he: 'התחברות', en: 'Login', ar: 'تسجيل الدخول');
  static String get register => text(he: 'הרשמה', en: 'Register', ar: 'إنشاء حساب');
  static String get idNumber => text(he: 'תעודת זהות', en: 'ID Number', ar: 'رقم الهوية');
  static String get password => text(he: 'סיסמה', en: 'Password', ar: 'كلمة المرور');
  static String get loginButton => text(he: 'התחבר', en: 'Login', ar: 'دخول');
  static String get registerButton => text(he: 'הירשם', en: 'Register', ar: 'تسجيل');
  static String get noAccountRegister => text(he: 'אין לך חשבון? הירשם', en: 'No account? Register', ar: 'ليس لديك حساب؟ سجّل الآن');
  static String get wrongLogin => text(he: 'תעודת זהות או סיסמה לא נכונים', en: 'Incorrect ID number or password', ar: 'رقم الهوية أو كلمة المرور غير صحيحة');
  static String get userBlocked => text(he: 'המשתמש חסום', en: 'User is blocked', ar: 'المستخدم محظور');
  static String get idNotApproved => text(he: 'תעודת הזהות לא נמצאת ברשימת בית הספר', en: 'This ID is not in the school approved list', ar: 'رقم الهوية غير موجود في قائمة المدرسة');
  static String get alreadyRegistered => text(he: 'משתמש עם תעודת זהות זו כבר רשום במערכת', en: 'A user with this ID is already registered', ar: 'يوجد مستخدم مسجل بهذا الرقم');
  static String get weakPassword => text(he: 'הסיסמה חייבת להכיל לפחות 6 תווים', en: 'Password must contain at least 6 characters', ar: 'كلمة المرور يجب أن تحتوي على 6 أحرف على الأقل');
  static String get registerError => text(he: 'אירעה שגיאה בהרשמה', en: 'Registration error', ar: 'حدث خطأ أثناء التسجيل');

  static String get howCanWeHelp => text(he: 'איך אפשר לעזור לך?', en: 'How can we help you?', ar: 'كيف يمكننا مساعدتك؟');
  static String get chooseReportType => text(he: 'בחר את סוג הפנייה שברצונך לשלוח', en: 'Choose the type of report you want to send', ar: 'اختر نوع التوجه الذي تريد إرساله');
  static String get bullying => text(he: 'בריונות', en: 'Bullying', ar: 'تنمّر');
  static String get mentalPressure => text(he: 'לחץ נפשי', en: 'Mental Pressure', ar: 'ضغط نفسي');
  static String get socialDifficulties => text(he: 'קשיים חברתיים', en: 'Social Difficulties', ar: 'صعوبات اجتماعية');
  static String get distress => text(he: 'מצוקה', en: 'Distress', ar: 'ضائقة');
  static String get other => text(he: 'אחר', en: 'Other', ar: 'أخرى');

  static String get firstName => text(he: 'שם פרטי', en: 'First Name', ar: 'الاسم الشخصي');
  static String get lastName => text(he: 'שם משפחה', en: 'Last Name', ar: 'اسم العائلة');
  static String get className => text(he: 'כיתה', en: 'Class', ar: 'الصف');
  static String get role => text(he: 'תפקיד', en: 'Role', ar: 'الدور');
  static String get status => text(he: 'סטטוס', en: 'Status', ar: 'الحالة');
  static String get active => text(he: 'פעיל', en: 'Active', ar: 'فعّال');
  static String get blocked => text(he: 'חסום', en: 'Blocked', ar: 'محظور');
  static String get noUserData => text(he: 'לא נמצאו פרטי משתמש', en: 'User details not found', ar: 'لم يتم العثور على بيانات المستخدم');

  static String get myReports => text(he: 'הפניות שלי', en: 'My Reports', ar: 'توجهاتي');
  static String get allReports => text(he: 'כל הפניות', en: 'All Reports', ar: 'كل التوجهات');
  static String get noReportsYet => text(he: 'עדיין לא שלחת פניות', en: 'You have not sent reports yet', ar: 'لم ترسل توجهات بعد');
  static String get noReportsToShow => text(he: 'אין פניות להצגה', en: 'No reports to show', ar: 'لا توجد توجهات للعرض');
  static String get noChatsYet => text(he: 'אין צ׳אטים עדיין', en: 'No chats yet', ar: 'لا توجد محادثات بعد');
  static String get noMessagesYet => text(he: 'אין הודעות עדיין', en: 'No messages yet', ar: 'لا توجد رسائل بعد');
  static String get unknownStudent => text(he: 'תלמיד לא ידוע', en: 'Unknown student', ar: 'طالب غير معروف');
  static String get reportWithoutCategory => text(he: 'פנייה ללא קטגוריה', en: 'Report without category', ar: 'توجه بدون تصنيف');
  static String get newMessages => text(he: 'הודעות חדשות', en: 'new messages', ar: 'رسائل جديدة');

  static String get pending => text(he: 'ממתין לבדיקה', en: 'Pending', ar: 'بانتظار الفحص');
  static String get inProgress => text(he: 'בטיפול', en: 'In Progress', ar: 'قيد المعالجة');
  static String get resolved => text(he: 'טופל', en: 'Resolved', ar: 'تمت المعالجة');
  static String get allStatuses => text(he: 'כל הפניות', en: 'All Reports', ar: 'كل التوجهات');
  static String get filterByStatus => text(he: 'סינון לפי סטטוס', en: 'Filter by status', ar: 'تصفية حسب الحالة');
  static String get highSeverityOnly => text(he: 'הצג רק פניות חמורות', en: 'Show severe reports only', ar: 'عرض التوجهات الخطيرة فقط');
  static String get severitySevenAndUp => text(he: 'רמת חומרה 7 ומעלה', en: 'Severity 7 and above', ar: 'درجة خطورة 7 وما فوق');

  static String get severityLevel => text(he: 'רמת חומרה', en: 'Severity Level', ar: 'درجة الخطورة');
  static String get studentSeverity => text(he: 'חומרה לפי תלמיד', en: 'Student Severity', ar: 'الخطورة حسب الطالب');
  static String get aiSeverity => text(he: 'חומרה לפי AI', en: 'AI Severity', ar: 'الخطورة حسب الذكاء الاصطناعي');
  static String get clickToOpenCounselorChat => text(he: 'לחץ לפתיחת צ׳אט עם היועצת', en: 'Tap to open chat with counselor', ar: 'اضغط لفتح محادثة مع المستشارة');
  static String get tapToOpenDetails => text(he: 'לחץ לפתיחת פרטי הפנייה', en: 'Tap to open report details', ar: 'اضغط لفتح تفاصيل التوجه');

  static String get describeWhatHappened => text(he: 'תאר מה קרה', en: 'Describe what happened', ar: 'صف ما حدث');
  static String get writeHere => text(he: 'כתוב כאן...', en: 'Write here...', ar: 'اكتب هنا...');
  static String get sendReport => text(he: 'שלח פנייה', en: 'Send Report', ar: 'إرسال التوجه');
  static String get reportSent => text(he: 'הפנייה נשלחה בהצלחה', en: 'Report sent successfully', ar: 'تم إرسال التوجه بنجاح');
  static String get descriptionRequired => text(he: 'חייב לכתוב תיאור לפנייה', en: 'Description is required', ar: 'يجب كتابة وصف للتوجه');
  static String get locationRequired => text(he: 'חייב לאפשר גישה למיקום כדי לשלוח פנייה', en: 'Location permission is required to send a report', ar: 'يجب السماح بالوصول للموقع لإرسال التوجه');
  static String get locationServicesOff => text(he: 'שירותי המיקום כבויים במכשיר', en: 'Location services are disabled', ar: 'خدمات الموقع مغلقة في الجهاز');

  static String get severeReportNew => text(he: 'פנייה חמורה חדשה', en: 'New Severe Report', ar: 'توجه خطير جديد');
  static String get newReport => text(he: 'פנייה חדשה', en: 'New Report', ar: 'توجه جديد');
  static String get newMessage => text(he: 'הודעה חדשה', en: 'New Message', ar: 'رسالة جديدة');
  static String get risk => text(he: 'סיכון', en: 'Risk', ar: 'خطورة');

  static String get reportDetails => text(he: 'פרטי פנייה', en: 'Report Details', ar: 'تفاصيل التوجه');
  static String get openChat => text(he: 'פתח צ׳אט', en: 'Open Chat', ar: 'افتح المحادثة');
  static String get chooseChat => text(he: 'בחר צ׳אט', en: 'Choose Chat', ar: 'اختر محادثة');
  static String get chooseWhoToChatWith => text(he: 'בחר עם מי לפתוח שיחה:', en: 'Choose who to chat with:', ar: 'اختر مع من تريد فتح محادثة:');
  static String get separateSavedChat => text(he: 'שיחה נפרדת ושמורה', en: 'Separate saved chat', ar: 'محادثة منفصلة ومحفوظة');
  static String get chatWithStudent => text(he: 'צ׳אט עם תלמיד', en: 'Chat with student', ar: 'محادثة مع الطالب');
  static String get chatWithAiAssistant => text(he: 'צ׳אט עם עוזר AI', en: 'Chat with AI Assistant', ar: 'محادثة مع مساعد الذكاء الاصطناعي');
  static String get writeMessage => text(he: 'כתוב הודעה...', en: 'Write a message...', ar: 'اكتب رسالة...');
  static String get deleteMessages => text(he: 'מחיקת הודעות', en: 'Delete Messages', ar: 'حذف الرسائل');
  static String get deleteMessagesConfirm => text(he: 'האם למחוק את כל הודעות הצ׳אט? הפנייה עצמה לא תימחק.', en: 'Delete all chat messages? The report itself will not be deleted.', ar: 'هل تريد حذف كل رسائل المحادثة؟ التوجه نفسه لن يُحذف.');
  static String get cancel => text(he: 'ביטול', en: 'Cancel', ar: 'إلغاء');
  static String get delete => text(he: 'מחק', en: 'Delete', ar: 'حذف');

  static String get counselor => text(he: 'יועצת', en: 'Counselor', ar: 'مستشارة');
  static String get teacher => text(he: 'מחנך', en: 'Teacher', ar: 'مربي');
  static String get manager => text(he: 'מנהל', en: 'Manager', ar: 'مدير');
  static String get student => text(he: 'תלמיד', en: 'Student', ar: 'طالب');
  static String get schoolStaff => text(he: 'צוות בית הספר', en: 'School Staff', ar: 'طاقم المدرسة');
  static String get aiAssistant => text(he: 'עוזר AI', en: 'AI Assistant', ar: 'مساعد الذكاء الاصطناعي');

  static String get category => text(he: 'קטגוריה', en: 'Category', ar: 'التصنيف');
  static String get date => text(he: 'תאריך', en: 'Date', ar: 'التاريخ');
  static String get reportDescription => text(he: 'תיאור הפנייה', en: 'Report Description', ar: 'وصف التوجه');
  static String get markInProgress => text(he: 'סמן כבטיפול', en: 'Mark In Progress', ar: 'تحديد قيد المعالجة');
  static String get markResolved => text(he: 'סמן כטופל', en: 'Mark Resolved', ar: 'تحديد كتمت المعالجة');
  static String get statusUpdated => text(he: 'סטטוס הפנייה עודכן', en: 'Report status updated', ar: 'تم تحديث حالة التوجه');

  static String get aiAnalysis => text(he: 'ניתוח AI', en: 'AI Analysis', ar: 'تحليل الذكاء الاصطناعي');
  static String get analyzed => text(he: 'נותח', en: 'Analyzed', ar: 'تم التحليل');
  static String get yes => text(he: 'כן', en: 'Yes', ar: 'نعم');
  static String get no => text(he: 'לא', en: 'No', ar: 'لا');
  static String get aiRiskLevel => text(he: 'רמת סיכון', en: 'Risk Level', ar: 'مستوى الخطورة');
  static String get summary => text(he: 'סיכום', en: 'Summary', ar: 'ملخص');
  static String get recommendation => text(he: 'המלצה', en: 'Recommendation', ar: 'توصية');
  static String get location => text(he: 'מיקום', en: 'Location', ar: 'الموقع');
  static String get noLocationSaved => text(he: 'לא נשמר מיקום', en: 'No location saved', ar: 'لم يتم حفظ الموقع');

  static String get notifications => text(he: 'התראות', en: 'Notifications', ar: 'الإشعارات');
  static String get noNotificationsYet => text(he: 'אין התראות עדיין', en: 'No notifications yet', ar: 'لا توجد إشعارات بعد');

  static String get adminSystem => text(he: 'מערכת ניהול', en: 'Admin System', ar: 'نظام الإدارة');
  static String get viewAllReports => text(he: 'צפייה בכל הפניות', en: 'View All Reports', ar: 'عرض كل التوجهات');
  static String get allChats => text(he: 'כל הצ׳אטים', en: 'All Chats', ar: 'كل المحادثات');
  static String get excelImport => text(he: 'ייבוא Excel', en: 'Excel Import', ar: 'استيراد Excel');
  static String get addApprovedUserManual => text(he: 'הוספת משתמש מאושר ידנית', en: 'Add Approved User Manually', ar: 'إضافة مستخدم مصادق يدويًا');
  static String get userType => text(he: 'סוג משתמש', en: 'User Type', ar: 'نوع المستخدم');
  static String get adminStaff => text(he: 'צוות בית הספר', en: 'School Staff', ar: 'طاقم المدرسة');
  static String get teacherClass => text(he: 'כיתה של המחנך', en: 'Teacher Class', ar: 'صف المربي');
  static String get addToApprovedList => text(he: 'הוסף לרשימה המאושרת', en: 'Add to Approved List', ar: 'إضافة إلى القائمة المصادق عليها');
  static String get approvedUserAdded => text(he: 'המשתמש נוסף לרשימה המאושרת', en: 'User added to approved list', ar: 'تمت إضافة المستخدم إلى القائمة المصادق عليها');
  static String get totalReports => text(he: 'סה״כ פניות', en: 'Total Reports', ar: 'مجموع التوجهات');
  static String get severeReports => text(he: 'פניות חמורות', en: 'Severe Reports', ar: 'توجهات خطيرة');
}