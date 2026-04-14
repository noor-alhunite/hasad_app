import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'حصاد'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get signup;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال'**
  String get phoneNumber;

  /// No description provided for @forgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgotPassword;

  /// No description provided for @welcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك مرة أخرى!'**
  String get welcomeBack;

  /// No description provided for @createAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get createAccount;

  /// No description provided for @farmer.
  ///
  /// In ar, this message translates to:
  /// **'مزارع'**
  String get farmer;

  /// No description provided for @trader.
  ///
  /// In ar, this message translates to:
  /// **'تاجر'**
  String get trader;

  /// No description provided for @factory.
  ///
  /// In ar, this message translates to:
  /// **'مصنع'**
  String get factory;

  /// No description provided for @selectRole.
  ///
  /// In ar, this message translates to:
  /// **'اختر دورك'**
  String get selectRole;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @marketplace.
  ///
  /// In ar, this message translates to:
  /// **'السوق'**
  String get marketplace;

  /// No description provided for @smartMapTab.
  ///
  /// In ar, this message translates to:
  /// **'الخريطة'**
  String get smartMapTab;

  /// No description provided for @chatsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحادثات'**
  String get chatsTitle;

  /// No description provided for @seasons.
  ///
  /// In ar, this message translates to:
  /// **'المواسم'**
  String get seasons;

  /// No description provided for @aiAssistant.
  ///
  /// In ar, this message translates to:
  /// **'الذكاء'**
  String get aiAssistant;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get profile;

  /// No description provided for @addSeason.
  ///
  /// In ar, this message translates to:
  /// **'إضافة موسم'**
  String get addSeason;

  /// No description provided for @addNewSeason.
  ///
  /// In ar, this message translates to:
  /// **'إضافة موسم جديد'**
  String get addNewSeason;

  /// No description provided for @cropType.
  ///
  /// In ar, this message translates to:
  /// **'نوع المحصول'**
  String get cropType;

  /// No description provided for @cropVariety.
  ///
  /// In ar, this message translates to:
  /// **'الصنف (اختياري)'**
  String get cropVariety;

  /// No description provided for @cropVarietyHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: طماطم شيري، خيار بلدي'**
  String get cropVarietyHint;

  /// No description provided for @area.
  ///
  /// In ar, this message translates to:
  /// **'المساحة'**
  String get area;

  /// No description provided for @enterArea.
  ///
  /// In ar, this message translates to:
  /// **'أدخل المساحة'**
  String get enterArea;

  /// No description provided for @areaRequired.
  ///
  /// In ar, this message translates to:
  /// **'المساحة مطلوبة'**
  String get areaRequired;

  /// No description provided for @unit.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة'**
  String get unit;

  /// No description provided for @dunum.
  ///
  /// In ar, this message translates to:
  /// **'دونم'**
  String get dunum;

  /// No description provided for @hectare.
  ///
  /// In ar, this message translates to:
  /// **'هكتار'**
  String get hectare;

  /// No description provided for @squareMeter.
  ///
  /// In ar, this message translates to:
  /// **'متر مربع'**
  String get squareMeter;

  /// No description provided for @plantingDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الزراعة'**
  String get plantingDate;

  /// No description provided for @expectedHarvestDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الحصاد المتوقع'**
  String get expectedHarvestDate;

  /// No description provided for @harvestDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الحصاد المتوقع'**
  String get harvestDate;

  /// No description provided for @expectedProduction.
  ///
  /// In ar, this message translates to:
  /// **'الإنتاج المتوقع (طن)'**
  String get expectedProduction;

  /// No description provided for @expectedProductionHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: 10'**
  String get expectedProductionHint;

  /// No description provided for @productionAndQuality.
  ///
  /// In ar, this message translates to:
  /// **'الإنتاج والجودة'**
  String get productionAndQuality;

  /// No description provided for @expectedQuality.
  ///
  /// In ar, this message translates to:
  /// **'درجة الجودة المتوقعة'**
  String get expectedQuality;

  /// No description provided for @qualityGrade.
  ///
  /// In ar, this message translates to:
  /// **'درجة الجودة المتوقعة'**
  String get qualityGrade;

  /// No description provided for @excellent.
  ///
  /// In ar, this message translates to:
  /// **'ممتاز'**
  String get excellent;

  /// No description provided for @very_good.
  ///
  /// In ar, this message translates to:
  /// **'جيد جداً'**
  String get very_good;

  /// No description provided for @veryGood.
  ///
  /// In ar, this message translates to:
  /// **'جيد جداً'**
  String get veryGood;

  /// No description provided for @good.
  ///
  /// In ar, this message translates to:
  /// **'جيد'**
  String get good;

  /// No description provided for @acceptable.
  ///
  /// In ar, this message translates to:
  /// **'مقبول'**
  String get acceptable;

  /// No description provided for @additionalInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات إضافية (اختياري)'**
  String get additionalInfo;

  /// No description provided for @fertilizerType.
  ///
  /// In ar, this message translates to:
  /// **'نوع السماد المستخدم'**
  String get fertilizerType;

  /// No description provided for @fertilizerHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: سماد عضوي، NPK'**
  String get fertilizerHint;

  /// No description provided for @fertilizer.
  ///
  /// In ar, this message translates to:
  /// **'نوع السماد المستخدم (اختياري)'**
  String get fertilizer;

  /// No description provided for @pesticidesUsed.
  ///
  /// In ar, this message translates to:
  /// **'المبيدات المستخدمة'**
  String get pesticidesUsed;

  /// No description provided for @pesticidesHint.
  ///
  /// In ar, this message translates to:
  /// **'اذكر أنواع المبيدات المستخدمة إن وجدت'**
  String get pesticidesHint;

  /// No description provided for @pesticide.
  ///
  /// In ar, this message translates to:
  /// **'المبيدات المستخدمة (اختياري)'**
  String get pesticide;

  /// No description provided for @uploadImages.
  ///
  /// In ar, this message translates to:
  /// **'صور الأرض أو المحصول (اختياري)'**
  String get uploadImages;

  /// No description provided for @uploadImagesHint.
  ///
  /// In ar, this message translates to:
  /// **'اضغط لرفع الصور أو اسحبها هنا'**
  String get uploadImagesHint;

  /// No description provided for @selectLocation.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الموقع على الخريطة'**
  String get selectLocation;

  /// No description provided for @setLocationOnMap.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الموقع على الخريطة'**
  String get setLocationOnMap;

  /// No description provided for @riyadhLocation.
  ///
  /// In ar, this message translates to:
  /// **'الرياض، المملكة العربية السعودية'**
  String get riyadhLocation;

  /// No description provided for @saveAndPublish.
  ///
  /// In ar, this message translates to:
  /// **'حفظ ونشر'**
  String get saveAndPublish;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @selectDate.
  ///
  /// In ar, this message translates to:
  /// **'اختر التاريخ'**
  String get selectDate;

  /// No description provided for @selectCropType.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع المحصول'**
  String get selectCropType;

  /// No description provided for @selectQuality.
  ///
  /// In ar, this message translates to:
  /// **'اختر درجة الجودة'**
  String get selectQuality;

  /// No description provided for @selectDates.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تحديد تواريخ الزراعة والحصاد'**
  String get selectDates;

  /// No description provided for @uploadImage.
  ///
  /// In ar, this message translates to:
  /// **'رفع صورة'**
  String get uploadImage;

  /// No description provided for @dashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get dashboard;

  /// No description provided for @welcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً'**
  String get welcome;

  /// No description provided for @farmSummary.
  ///
  /// In ar, this message translates to:
  /// **'إليك ملخص مزرعتك اليوم'**
  String get farmSummary;

  /// No description provided for @activeSeasons.
  ///
  /// In ar, this message translates to:
  /// **'المواسم النشطة'**
  String get activeSeasons;

  /// No description provided for @newOffers.
  ///
  /// In ar, this message translates to:
  /// **'عروض جديدة'**
  String get newOffers;

  /// No description provided for @weatherAlert.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه جوي'**
  String get weatherAlert;

  /// No description provided for @quickActions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات سريعة'**
  String get quickActions;

  /// No description provided for @aiRecommendations.
  ///
  /// In ar, this message translates to:
  /// **'توصيات ذكية لك'**
  String get aiRecommendations;

  /// No description provided for @viewDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض التفاصيل'**
  String get viewDetails;

  /// No description provided for @aiAssistantTitle.
  ///
  /// In ar, this message translates to:
  /// **'مساعد الذكاء الاصطناعي'**
  String get aiAssistantTitle;

  /// No description provided for @aiSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تحليلات ذكية وتوقعات دقيقة لمساعدتك في اتخاذ القرارات الصحيحة'**
  String get aiSubtitle;

  /// No description provided for @recommendations.
  ///
  /// In ar, this message translates to:
  /// **'التوصيات'**
  String get recommendations;

  /// No description provided for @analytics.
  ///
  /// In ar, this message translates to:
  /// **'التحليلات'**
  String get analytics;

  /// No description provided for @personal.
  ///
  /// In ar, this message translates to:
  /// **'خاص بك'**
  String get personal;

  /// No description provided for @directMarket.
  ///
  /// In ar, this message translates to:
  /// **'الخريطة الذكية'**
  String get directMarket;

  /// No description provided for @searchProduct.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن منتج...'**
  String get searchProduct;

  /// No description provided for @all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// No description provided for @contact.
  ///
  /// In ar, this message translates to:
  /// **'تواصل'**
  String get contact;

  /// No description provided for @quantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get quantity;

  /// No description provided for @price.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get price;

  /// No description provided for @rating.
  ///
  /// In ar, this message translates to:
  /// **'التقييم'**
  String get rating;

  /// No description provided for @distance.
  ///
  /// In ar, this message translates to:
  /// **'المسافة'**
  String get distance;

  /// No description provided for @myProfile.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get myProfile;

  /// No description provided for @contactInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الاتصال'**
  String get contactInfo;

  /// No description provided for @previousSeasons.
  ///
  /// In ar, this message translates to:
  /// **'المواسم السابقة'**
  String get previousSeasons;

  /// No description provided for @reviews.
  ///
  /// In ar, this message translates to:
  /// **'التقييمات'**
  String get reviews;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @documents.
  ///
  /// In ar, this message translates to:
  /// **'المستندات'**
  String get documents;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @notificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات'**
  String get notificationsTitle;

  /// No description provided for @weather.
  ///
  /// In ar, this message translates to:
  /// **'الطقس'**
  String get weather;

  /// No description provided for @reminders.
  ///
  /// In ar, this message translates to:
  /// **'تذكيرات'**
  String get reminders;

  /// No description provided for @offers.
  ///
  /// In ar, this message translates to:
  /// **'عروض'**
  String get offers;

  /// No description provided for @smartRecommendations.
  ///
  /// In ar, this message translates to:
  /// **'توصيات ذكية جديدة'**
  String get smartRecommendations;

  /// No description provided for @viewMarketAnalysis.
  ///
  /// In ar, this message translates to:
  /// **'اعرض تحليلات السوق والتوصيات المخصصة لك'**
  String get viewMarketAnalysis;

  /// No description provided for @newNotifications.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get newNotifications;

  /// No description provided for @hoursAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {hours} ساعة'**
  String hoursAgo(int hours);

  /// No description provided for @yesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get yesterday;

  /// No description provided for @production.
  ///
  /// In ar, this message translates to:
  /// **'الإنتاج'**
  String get production;

  /// No description provided for @area_label.
  ///
  /// In ar, this message translates to:
  /// **'المساحة'**
  String get area_label;

  /// No description provided for @harvest.
  ///
  /// In ar, this message translates to:
  /// **'الحصاد'**
  String get harvest;

  /// No description provided for @planting.
  ///
  /// In ar, this message translates to:
  /// **'الزراعة'**
  String get planting;

  /// No description provided for @status.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get status;

  /// No description provided for @active.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get active;

  /// No description provided for @harvested.
  ///
  /// In ar, this message translates to:
  /// **'محصود'**
  String get harvested;

  /// No description provided for @cancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغي'**
  String get cancelled;

  /// No description provided for @high.
  ///
  /// In ar, this message translates to:
  /// **'عالية'**
  String get high;

  /// No description provided for @medium_quality.
  ///
  /// In ar, this message translates to:
  /// **'متوسطة'**
  String get medium_quality;

  /// No description provided for @premium.
  ///
  /// In ar, this message translates to:
  /// **'ممتازة'**
  String get premium;

  /// No description provided for @expected_return.
  ///
  /// In ar, this message translates to:
  /// **'العائد المتوقع'**
  String get expected_return;

  /// No description provided for @golden_opportunity.
  ///
  /// In ar, this message translates to:
  /// **'فرصة ذهبية'**
  String get golden_opportunity;

  /// No description provided for @warning.
  ///
  /// In ar, this message translates to:
  /// **'تحذير'**
  String get warning;

  /// No description provided for @high_demand.
  ///
  /// In ar, this message translates to:
  /// **'طلب مرتفع'**
  String get high_demand;

  /// No description provided for @shortage.
  ///
  /// In ar, this message translates to:
  /// **'نقص في السوق'**
  String get shortage;

  /// No description provided for @tomatoes.
  ///
  /// In ar, this message translates to:
  /// **'طماطم'**
  String get tomatoes;

  /// No description provided for @cucumber.
  ///
  /// In ar, this message translates to:
  /// **'خيار'**
  String get cucumber;

  /// No description provided for @watermelon.
  ///
  /// In ar, this message translates to:
  /// **'بطيخ'**
  String get watermelon;

  /// No description provided for @pepper.
  ///
  /// In ar, this message translates to:
  /// **'فلفل'**
  String get pepper;

  /// No description provided for @dates.
  ///
  /// In ar, this message translates to:
  /// **'تمور'**
  String get dates;

  /// No description provided for @grapes.
  ///
  /// In ar, this message translates to:
  /// **'عنب'**
  String get grapes;

  /// No description provided for @onboarding_title.
  ///
  /// In ar, this message translates to:
  /// **'منصة حصاد الزراعية'**
  String get onboarding_title;

  /// No description provided for @onboarding_subtitle.
  ///
  /// In ar, this message translates to:
  /// **'تربط المزارعين والتجار والمصانع في منصة واحدة متكاملة'**
  String get onboarding_subtitle;

  /// No description provided for @verification_code.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق'**
  String get verification_code;

  /// No description provided for @enter_code.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز المرسل إلى جوالك'**
  String get enter_code;

  /// No description provided for @verify.
  ///
  /// In ar, this message translates to:
  /// **'تحقق'**
  String get verify;

  /// No description provided for @resend_code.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرمز'**
  String get resend_code;

  /// No description provided for @under_review.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get under_review;

  /// No description provided for @review_message.
  ///
  /// In ar, this message translates to:
  /// **'تم استلام بياناتك وهي قيد المراجعة'**
  String get review_message;

  /// No description provided for @review_time.
  ///
  /// In ar, this message translates to:
  /// **'سيتم مراجعة طلبك خلال 48 ساعة'**
  String get review_time;

  /// No description provided for @continue_btn.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get continue_btn;

  /// No description provided for @upload_documents.
  ///
  /// In ar, this message translates to:
  /// **'رفع المستندات'**
  String get upload_documents;

  /// No description provided for @id_card.
  ///
  /// In ar, this message translates to:
  /// **'صورة الهوية'**
  String get id_card;

  /// No description provided for @land_documents.
  ///
  /// In ar, this message translates to:
  /// **'وثائق ملكية الأرض'**
  String get land_documents;

  /// No description provided for @commercial_register.
  ///
  /// In ar, this message translates to:
  /// **'السجل التجاري'**
  String get commercial_register;

  /// No description provided for @industrial_register.
  ///
  /// In ar, this message translates to:
  /// **'السجل الصناعي'**
  String get industrial_register;

  /// No description provided for @submit_review.
  ///
  /// In ar, this message translates to:
  /// **'إرسال للمراجعة'**
  String get submit_review;

  /// No description provided for @required.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب'**
  String get required;

  /// No description provided for @completed.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get completed;

  /// No description provided for @send_offer.
  ///
  /// In ar, this message translates to:
  /// **'إرسال عرض'**
  String get send_offer;

  /// No description provided for @contracts.
  ///
  /// In ar, this message translates to:
  /// **'العقود'**
  String get contracts;

  /// No description provided for @orders.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات'**
  String get orders;

  /// No description provided for @supply_request.
  ///
  /// In ar, this message translates to:
  /// **'طلب توريد'**
  String get supply_request;

  /// No description provided for @raw_materials.
  ///
  /// In ar, this message translates to:
  /// **'المواد الخام'**
  String get raw_materials;

  /// No description provided for @production_schedule.
  ///
  /// In ar, this message translates to:
  /// **'جدول الإنتاج'**
  String get production_schedule;

  /// No description provided for @contract_management.
  ///
  /// In ar, this message translates to:
  /// **'إدارة العقود'**
  String get contract_management;

  /// No description provided for @active_contracts.
  ///
  /// In ar, this message translates to:
  /// **'العقود النشطة'**
  String get active_contracts;

  /// No description provided for @payment_schedule.
  ///
  /// In ar, this message translates to:
  /// **'جدول الدفعات'**
  String get payment_schedule;

  /// No description provided for @delivery_date.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ التسليم'**
  String get delivery_date;

  /// No description provided for @total_amount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ الإجمالي'**
  String get total_amount;

  /// No description provided for @notes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get notes;

  /// No description provided for @pending.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get pending;

  /// No description provided for @accepted.
  ///
  /// In ar, this message translates to:
  /// **'مقبول'**
  String get accepted;

  /// No description provided for @rejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get rejected;

  /// No description provided for @completed_status.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get completed_status;

  /// No description provided for @member_since.
  ///
  /// In ar, this message translates to:
  /// **'عضو منذ'**
  String get member_since;

  /// No description provided for @location_label.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get location_label;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In ar, this message translates to:
  /// **'فلترة'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب'**
  String get sort;

  /// No description provided for @available_quantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المتوفرة'**
  String get available_quantity;

  /// No description provided for @price_per_kg.
  ///
  /// In ar, this message translates to:
  /// **'ر.س/كجم'**
  String get price_per_kg;

  /// No description provided for @km_away.
  ///
  /// In ar, this message translates to:
  /// **'كم'**
  String get km_away;

  /// No description provided for @stars.
  ///
  /// In ar, this message translates to:
  /// **'نجوم'**
  String get stars;

  /// No description provided for @seasons_count.
  ///
  /// In ar, this message translates to:
  /// **'موسم'**
  String get seasons_count;

  /// No description provided for @no_seasons.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مواسم حالياً'**
  String get no_seasons;

  /// No description provided for @add_first_season.
  ///
  /// In ar, this message translates to:
  /// **'أضف موسمك الزراعي الأول'**
  String get add_first_season;

  /// No description provided for @no_notifications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تنبيهات'**
  String get no_notifications;

  /// No description provided for @no_products.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات'**
  String get no_products;

  /// No description provided for @error_required_field.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get error_required_field;

  /// No description provided for @error_invalid_email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني غير صحيح'**
  String get error_invalid_email;

  /// No description provided for @error_password_short.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب أن تكون 6 أحرف على الأقل'**
  String get error_password_short;

  /// No description provided for @error_passwords_mismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور غير متطابقة'**
  String get error_passwords_mismatch;

  /// No description provided for @login_success.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الدخول بنجاح'**
  String get login_success;

  /// No description provided for @signup_success.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الحساب بنجاح'**
  String get signup_success;

  /// No description provided for @season_added.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة الموسم بنجاح'**
  String get season_added;

  /// No description provided for @seasonAddedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة الموسم بنجاح'**
  String get seasonAddedSuccess;

  /// No description provided for @have_account.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب؟'**
  String get have_account;

  /// No description provided for @no_account.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get no_account;

  /// No description provided for @or.
  ///
  /// In ar, this message translates to:
  /// **'أو'**
  String get or;

  /// No description provided for @demo_login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل دخول تجريبي'**
  String get demo_login;

  /// No description provided for @farmer_demo.
  ///
  /// In ar, this message translates to:
  /// **'دخول كمزارع'**
  String get farmer_demo;

  /// No description provided for @trader_demo.
  ///
  /// In ar, this message translates to:
  /// **'دخول كتاجر'**
  String get trader_demo;

  /// No description provided for @factory_demo.
  ///
  /// In ar, this message translates to:
  /// **'دخول كمصنع'**
  String get factory_demo;

  /// No description provided for @expected_harvest.
  ///
  /// In ar, this message translates to:
  /// **'الحصاد المتوقع'**
  String get expected_harvest;

  /// No description provided for @growing.
  ///
  /// In ar, this message translates to:
  /// **'نمو'**
  String get growing;

  /// No description provided for @add.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get add;

  /// No description provided for @conversations.
  ///
  /// In ar, this message translates to:
  /// **'المحادثات'**
  String get conversations;

  /// No description provided for @ai_assistant_menu.
  ///
  /// In ar, this message translates to:
  /// **'مساعد AI'**
  String get ai_assistant_menu;

  /// No description provided for @market_menu.
  ///
  /// In ar, this message translates to:
  /// **'السوق'**
  String get market_menu;

  /// No description provided for @example_tomato.
  ///
  /// In ar, this message translates to:
  /// **'مثال: طماطم شيري، خيار بلدي'**
  String get example_tomato;

  /// No description provided for @example_area.
  ///
  /// In ar, this message translates to:
  /// **'المساحة'**
  String get example_area;

  /// No description provided for @example_production.
  ///
  /// In ar, this message translates to:
  /// **'مثال: 10'**
  String get example_production;

  /// No description provided for @example_fertilizer.
  ///
  /// In ar, this message translates to:
  /// **'مثال: سماد عضوي، NPK'**
  String get example_fertilizer;

  /// No description provided for @example_pesticide.
  ///
  /// In ar, this message translates to:
  /// **'اذكر أنواع المبيدات المستخدمة إن وجدت'**
  String get example_pesticide;

  /// No description provided for @drag_or_click.
  ///
  /// In ar, this message translates to:
  /// **'اضغط لرفع الصور أو اسحبها هنا'**
  String get drag_or_click;

  /// No description provided for @cropInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات المحصول'**
  String get cropInfo;

  /// No description provided for @dates_section.
  ///
  /// In ar, this message translates to:
  /// **'التواريخ'**
  String get dates_section;

  /// No description provided for @dates_label.
  ///
  /// In ar, this message translates to:
  /// **'التواريخ'**
  String get dates_label;

  /// No description provided for @seasonAddedError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ، يرجى المحاولة مرة أخرى'**
  String get seasonAddedError;

  /// No description provided for @viewAllSeasons.
  ///
  /// In ar, this message translates to:
  /// **'عرض كل المواسم'**
  String get viewAllSeasons;

  /// No description provided for @viewAllProducts.
  ///
  /// In ar, this message translates to:
  /// **'عرض كل المنتجات'**
  String get viewAllProducts;

  /// No description provided for @marketPrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر السوق'**
  String get marketPrice;

  /// No description provided for @cropDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المحصول'**
  String get cropDetails;

  /// No description provided for @farmerName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المزارع'**
  String get farmerName;

  /// No description provided for @location.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get location;

  /// No description provided for @qualityLabel.
  ///
  /// In ar, this message translates to:
  /// **'الجودة'**
  String get qualityLabel;

  /// No description provided for @availableFrom.
  ///
  /// In ar, this message translates to:
  /// **'متاح من'**
  String get availableFrom;

  /// No description provided for @contactFarmer.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع المزارع'**
  String get contactFarmer;

  /// No description provided for @sendMessage.
  ///
  /// In ar, this message translates to:
  /// **'إرسال رسالة'**
  String get sendMessage;

  /// No description provided for @makeOffer.
  ///
  /// In ar, this message translates to:
  /// **'تقديم عرض'**
  String get makeOffer;

  /// No description provided for @offerPrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر العرض'**
  String get offerPrice;

  /// No description provided for @offerQuantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المطلوبة'**
  String get offerQuantity;

  /// No description provided for @submitOffer.
  ///
  /// In ar, this message translates to:
  /// **'إرسال العرض'**
  String get submitOffer;

  /// No description provided for @mySeasons.
  ///
  /// In ar, this message translates to:
  /// **'مواسمي'**
  String get mySeasons;

  /// No description provided for @seasonStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة الموسم'**
  String get seasonStatus;

  /// No description provided for @seasonDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الموسم'**
  String get seasonDetails;

  /// No description provided for @editSeason.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الموسم'**
  String get editSeason;

  /// No description provided for @deleteSeason.
  ///
  /// In ar, this message translates to:
  /// **'حذف الموسم'**
  String get deleteSeason;

  /// No description provided for @confirmDelete.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من الحذف؟'**
  String get confirmDelete;

  /// No description provided for @yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get no;

  /// No description provided for @cropName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المحصول'**
  String get cropName;

  /// No description provided for @totalArea.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المساحة'**
  String get totalArea;

  /// No description provided for @totalProduction.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الإنتاج'**
  String get totalProduction;

  /// No description provided for @averageRating.
  ///
  /// In ar, this message translates to:
  /// **'متوسط التقييم'**
  String get averageRating;

  /// No description provided for @totalReviews.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي التقييمات'**
  String get totalReviews;

  /// No description provided for @joinDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانضمام'**
  String get joinDate;

  /// No description provided for @verifiedBadge.
  ///
  /// In ar, this message translates to:
  /// **'موثق'**
  String get verifiedBadge;

  /// No description provided for @premiumBadge.
  ///
  /// In ar, this message translates to:
  /// **'مميز'**
  String get premiumBadge;

  /// No description provided for @shareProfile.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة الملف الشخصي'**
  String get shareProfile;

  /// No description provided for @editProfile.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get editProfile;

  /// No description provided for @helpCenter.
  ///
  /// In ar, this message translates to:
  /// **'مركز المساعدة'**
  String get helpCenter;

  /// No description provided for @privacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In ar, this message translates to:
  /// **'شروط الخدمة'**
  String get termsOfService;

  /// No description provided for @appVersion.
  ///
  /// In ar, this message translates to:
  /// **'إصدار التطبيق'**
  String get appVersion;

  /// No description provided for @rateApp.
  ///
  /// In ar, this message translates to:
  /// **'تقييم التطبيق'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة التطبيق'**
  String get shareApp;

  /// No description provided for @seasonInHarvest.
  ///
  /// In ar, this message translates to:
  /// **'قيد الحصاد'**
  String get seasonInHarvest;

  /// No description provided for @seasonEnded.
  ///
  /// In ar, this message translates to:
  /// **'منتهي'**
  String get seasonEnded;

  /// No description provided for @recentSeasons.
  ///
  /// In ar, this message translates to:
  /// **'مواسمي الزراعية'**
  String get recentSeasons;

  /// No description provided for @seasonPhotos.
  ///
  /// In ar, this message translates to:
  /// **'صور الموسم'**
  String get seasonPhotos;

  /// No description provided for @noSeasonPhotos.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد صور بعد'**
  String get noSeasonPhotos;

  /// No description provided for @fertilizersSection.
  ///
  /// In ar, this message translates to:
  /// **'الأسمدة'**
  String get fertilizersSection;

  /// No description provided for @pesticidesSection.
  ///
  /// In ar, this message translates to:
  /// **'المبيدات'**
  String get pesticidesSection;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
