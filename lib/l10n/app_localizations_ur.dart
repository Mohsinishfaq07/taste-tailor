// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get languageHeading => 'زبان';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHybridChip => 'انگریزی + اردو';

  @override
  String get appTitle => 'باوَرچی ایپ';

  @override
  String get splashSubtitle => 'ذائقہ کی عمدگی';

  @override
  String get getStartedLogin => 'لاگ اِن';

  @override
  String get getStartedSignUpChef => 'شیف کے طور پر رجسٹر کریں';

  @override
  String get getStartedSignUpUser => 'صارف کے طور پر رجسٹر کریں';

  @override
  String get exitAppTitle => 'ایپ سے باہر نکلیں';

  @override
  String get exitAppMessage => 'کیا آپ واقعی ایپ بند کرنا چاہتے ہیں؟';

  @override
  String get exitNo => 'نہیں';

  @override
  String get exitYes => 'ہاں';

  @override
  String get welcomeBack => 'خوش آمدید';

  @override
  String get signInContinue => 'جاری رکھنے کے لیے سائن اِن کریں';

  @override
  String get email => 'ای میل';

  @override
  String get password => 'پاس ورڈ';

  @override
  String get forgotPassword => 'پاس ورڈ بھول گئے؟';

  @override
  String get login => 'لاگ اِن';

  @override
  String get fillAllFields => 'تمام خانے بھریئے';

  @override
  String get forgotEnterEmail => 'اپنا ای میل درج کریں!';

  @override
  String get resetEmailSent => 'ری سیٹ ای میل بھیج دی گئی';

  @override
  String get enterCorrectEmail => 'درست ای میل درج کریں';

  @override
  String get resetErrorTryLater => 'خرابی آئی ہے۔ بعد میں کوشش کریں۔';

  @override
  String get createAccount => 'اکاؤنٹ بنائیں';

  @override
  String get signUpUserSubtitle => 'صارف کے طور پر';

  @override
  String get signUpChefSubtitle => 'شیف کے طور پر';

  @override
  String get fullName => 'مکمل نام';

  @override
  String get enterFullName => 'اپنا مکمل نام';

  @override
  String get phoneNumber => 'فون نمبر';

  @override
  String get enterPhone => 'فون نمبر درج کریں';

  @override
  String get address => 'پتہ';

  @override
  String get enterAddress => 'دستی پتہ لکھیں یا اوپر سے GPS استعمال کریں';

  @override
  String get enterEmail => 'ای میل درج کریں';

  @override
  String get enterPassword => 'پاس ورڈ درج کریں';

  @override
  String get confirmPassword => 'پاس ورڈ کی تصدیق';

  @override
  String get confirmYourPassword => 'پاس ورڈ دوبارہ درج کریں';

  @override
  String get signUp => 'سائن اپ';

  @override
  String get passwordsMismatch => 'پاس ورڈ یکساں نہیں';

  @override
  String get experience => 'تجربہ';

  @override
  String get experienceHint => 'سال / تفصیل';

  @override
  String get speciality => 'مہارت';

  @override
  String get certificate => 'سرٹیفکیٹ';

  @override
  String get chefSignUp => 'شیف اکاؤنٹ بنائیں';

  @override
  String get drawerAllChefs => 'تمام شیفز';

  @override
  String get drawerNewRequest => 'نئی درخواست';

  @override
  String get drawerMessages => 'پیغامات';

  @override
  String get drawerMyOrders => 'میرے آرڈرز';

  @override
  String get drawerOrderCalendar => 'آرڈر کیلنڈر';

  @override
  String get drawerMyProfile => 'میری پروفائل';

  @override
  String get drawerLogout => 'لاگ آؤٹ';

  @override
  String get drawerAllOrders => 'تمام آرڈرز';

  @override
  String get chefRequestsTitle => 'درخواستیں';

  @override
  String get noRequestsAvailable => 'کوئی درخواست موجود نہیں۔';

  @override
  String get pleaseEnterFare => 'قیمت درج کریں';

  @override
  String get clientBookedYou => 'گاہک نے آپ کو منتخب کیا';

  @override
  String get allChefsTitle => 'تمام شیفز';

  @override
  String get searchChefByName => 'نام سے شیف تلاش کریں';

  @override
  String get allLocations => 'تمام مقامات';

  @override
  String noChefMatchSearch(String query) {
    return '\"$query\" سے کوئی شیف نہیں ملا';
  }

  @override
  String get tryAnotherChefName => 'کوئی اور نام آزمائیں';

  @override
  String get tryWidenLocationFilter => 'دوسرا نام یا مقام وسعت دیں';

  @override
  String noChefsInCity(String city) {
    return '$city میں کوئی شیف نہیں';
  }

  @override
  String get chooseAllLocationsOrCity =>
      '\'تمام مقامات\' یا دوسرے شہر پر جائیں';

  @override
  String get noChefsAvailable => 'کوئی شیف دستیاب نہیں';

  @override
  String get bookThisChef => 'اس شیف کو بُک کریں';

  @override
  String get signInToBookChef => 'شیف بُک کرنے کے لیے سائن اِن کریں۔';

  @override
  String get cannotBookSelf => 'اپنے آپ کو بُک نہیں کر سکتے۔';

  @override
  String get chefDetailsTitle => 'شیف کی تفصیل';

  @override
  String get noChefSelected => 'کوئی شیف نہیں';

  @override
  String get chefProfileSection => 'شیف کا پروفائل';

  @override
  String get certificateSection => 'سرٹیفکیٹ';

  @override
  String get chefExperienceInfo => 'تجربہ';

  @override
  String get chefSpecialtiesInfo => 'مہارت';

  @override
  String get chefAddressInfo => 'پتہ';

  @override
  String get chefPhoneInfo => 'فون';

  @override
  String get chefEmailInfo => 'ای میل';

  @override
  String get reviewsSection => 'جائزے';

  @override
  String get messageChefAboutOrder => 'بُکنگ کے بارے میں پیغام';

  @override
  String get createRequestTitle => 'درخواست بنائیں';

  @override
  String get bookAChefTitle => 'شیف کو بُک کریں';

  @override
  String bookingForChefBanner(String name) {
    return 'بُکنگ: $name\\nمنتخب شیف ہی یہ کام دیکھے گا جب تک آپ آفر قبول نہیں کرتے۔';
  }

  @override
  String get foodItemName => 'کھانے کی قسم';

  @override
  String get enterFoodItem => 'نام درج کریں';

  @override
  String get dateLabel => 'تاریخ';

  @override
  String get selectDateHint => 'تاریخ چنیں';

  @override
  String get arrivalTimeLabel => 'پہنچنے کا وقت';

  @override
  String get eventTimeLabel => 'وقتٔ تقریب';

  @override
  String get numberOfPeople => 'افراد کی تعداد';

  @override
  String get enterPeopleCount => 'تعداد درج کریں';

  @override
  String get fareLabel => 'قیمت';

  @override
  String get enterFare => 'قیمت درج کریں';

  @override
  String get submitNewPriceTitle => 'نئی قیمت بھیجیں';

  @override
  String get enterNewPriceHint => 'نئی قیمت درج کریں';

  @override
  String priceUpdatedApproveRequest(String amount) {
    return 'قیمت $amount اپ ڈیٹ ہو گئی۔ براہ کرم درخواست منظور کریں۔';
  }

  @override
  String get availableIngredientsLabel => 'دستیاب اجزاء';

  @override
  String get ingredientsHint => 'اجزاء لکھیں';

  @override
  String get submitRequest => 'درخواست بھیجیں';

  @override
  String get pleaseSelectEventTimeFirst => 'پہلے تقریب کا وقت چنیں';

  @override
  String get processingRequest => 'عمل جاری ہے...';

  @override
  String get requestSubmittedSuccess => 'درخواست کامیابی سے بھیجی گئی!';

  @override
  String get requestSentAvailableChefs =>
      'درخواست دستیاب شیفز تک بھیجی گئی ہے۔';

  @override
  String requestSentSpecificChef(String name) {
    return 'درخواست $name کو بھیجی گئی۔ وہ آفر بھیج سکتے ہیں۔';
  }

  @override
  String get okButton => 'ٹھیک';

  @override
  String get myOrdersTitle => 'میرے آرڈرز';

  @override
  String get locationHelpLine => 'موجودہ مقام یا نیچے پتہ دستی طور پر لکھیں۔';

  @override
  String get useCurrentLocation => 'موجودہ مقام استعمال کریں';

  @override
  String get gettingLocation => 'لوکیشن لو ہو رہی ہے…';

  @override
  String get notificationFallbackTitle => 'اطلاع';

  @override
  String get notificationFallbackOk => 'ٹھیک';

  @override
  String get accountDeleteEnterPassword =>
      'تصدیق کے لیے اپنا پاس ورڈ درج کریں۔';

  @override
  String get accountDeletedToast => 'آپ کا اکاؤنٹ ڈیلیٹ ہو گیا ہے۔';

  @override
  String get loginSuccessful => 'لاگ اِن کامیاب';

  @override
  String get chiefAccountCreated => 'شیف اکاؤنٹ بنا دیا گیا';

  @override
  String get userAccountCreated => 'صارف اکاؤنٹ بنا دیا گیا';

  @override
  String get requestAddedSuccess => 'درخواست شامل ہو گئی';

  @override
  String get orderNotFound => 'آرڈر نہیں ملا۔';

  @override
  String get orderExpiredToast => 'یہ آرڈر ختم ہو چکا۔';

  @override
  String get requestAcceptedToast => 'درخواست قبول۔';

  @override
  String get requestRejectedToast => 'درخواست مسترد۔';

  @override
  String get orderCompletedToast => 'آرڈر مکمل';

  @override
  String get pleaseSignInAgain => 'براہ کرم دوبارہ سائن اِن کریں۔';

  @override
  String get profileUpdated => 'پروفائل اپ ڈیٹ';

  @override
  String get passwordUpdatedToast => 'پاس ورڈ اپ ڈیٹ';

  @override
  String get noEmailOnAccount => 'اکاؤنٹ پر ای میل نہیں۔';

  @override
  String get requestMovedMyOrders => 'درخواست میرے آرڈرز میں منتقل';

  @override
  String errorUpdatingRequest(String error) {
    return 'اپ ڈیٹ میں خرابی: $error';
  }

  @override
  String errorAcceptingRequest(String error) {
    return 'قبول کرنے میں خرابی: $error';
  }

  @override
  String get requestAcceptedByUser => 'صارف نے قبول کر لیا۔';

  @override
  String get requestDeletedSuccess => 'درخواست حذف ہو گئی';

  @override
  String requestDeleteError(String error) {
    return 'حذف میں خرابی: $error';
  }

  @override
  String get mustBeLoggedInRating => 'ریٹنگ کے لیے سائن اِن ضروری ہے۔';

  @override
  String get thankYouFeedback => 'آپ کا شکریہ!';

  @override
  String errorRating(String error) {
    return 'ریٹنگ میں خرابی: $error';
  }

  @override
  String get forgotPasswordScreenTitle => 'پاس ورڈ بھول گئے';

  @override
  String get submit => 'جمع کرائیں';

  @override
  String get workExperienceYearsLabel => 'کام کا تجربہ (سال)';

  @override
  String get workExperienceHint => 'اپنا تجربہ درج کریں';

  @override
  String get specialitiesHint => 'مہارتیں درج کریں';

  @override
  String get certificationsTitle => 'سرٹیفیکیٹس';

  @override
  String get certificateUploaded => 'سرٹیفیکیٹ اپ لوڈ ہو گیا';

  @override
  String get uploadCertificate => 'سرٹیفیکیٹ اپ لوڈ کریں';

  @override
  String get pickCamera => 'کیمرہ';

  @override
  String get pickGallery => 'گیلری';

  @override
  String get errorTitle => 'خرابی';

  @override
  String get submitRequestFailed =>
      'درخواست بھیجنے میں ناکامی۔ دوبارہ کوشش کریں۔';

  @override
  String get exitFormTitle => 'فارم چھوڑیں';

  @override
  String get exitFormMessage =>
      'کیا آپ یقیناً باہر نکلنا چاہتے ہیں؟ آپ کی تبدیلیاں ضائع ہو جائیں گی۔';

  @override
  String get cancelButton => 'منسوخ';

  @override
  String get exitConfirmButton => 'باہر نکلیں';

  @override
  String get arrivalBeforeEventToast =>
      'پہنچنے کا وقت تقریب سے کم از کم ایک گھنٹہ پہلے ہونا چاہیے';

  @override
  String pleaseEnterField(String field) {
    return '$field درج کریں';
  }

  @override
  String get thisChefLabel => 'یہ شیف';

  @override
  String get theChefFallback => 'شیف';

  @override
  String get selectTimeHint => 'وقت چنیں';

  @override
  String bookingForChefLine1(String name) {
    return 'بُکنگ درخواست: $name';
  }

  @override
  String get bookingForChefLine2 =>
      'منتخب شیف ہی یہ کام دیکھے گا جب تک آپ آفر قبول نہیں کرتے۔';

  @override
  String get chefOrdersCalendarTitle => 'میرا آرڈر کیلنڈر';

  @override
  String get userOrdersSearchHint => '🔍 ڈش کے نام سے آرڈر تلاش کریں';

  @override
  String get chefsSearchPrefixHint => '🔍 ';

  @override
  String get noOrdersMatchSearch => 'تلاش سے کوئی آرڈر نہیں ملا۔';

  @override
  String get orderListFarePending => 'زیر التواء';

  @override
  String get orderCardIngredientsHeading => '🥕 اجزاء';

  @override
  String get orderViewChefDetails => 'شیف کی تفصیل دیکھیں';

  @override
  String get orderWaitingChefAcceptance => '⏳ شیف کی قبولیت کا انتظار';

  @override
  String get orderWaitingChefOffers => 'شیف کی پیشکشوں کا انتظار۔';

  @override
  String get orderExpiredLine => 'ختم — تقریب کی تاریخ گزر چکی ہے۔';

  @override
  String get rateChefButton => '⭐ شیف کو ریٹ کریں';

  @override
  String get emptyOrdersAll => 'ابھی کوئی آرڈر نہیں۔';

  @override
  String get emptyOrdersPending => 'اس وقت کوئی زیرِ التواء درخواست نہیں۔';

  @override
  String get emptyOrdersExpired => 'کوئی ختم شدہ آرڈر نہیں۔';

  @override
  String get emptyOrdersAssigned => 'کوئی تفویض شدہ آرڈر نہیں۔';

  @override
  String get emptyOrdersCompleted => 'کوئی مکمل آرڈر نہیں۔';

  @override
  String get orderStatusPending => 'زیر التواء';

  @override
  String get orderStatusAssigned => 'تفویض';

  @override
  String get orderStatusCompleted => 'مکمل';

  @override
  String get orderStatusExpired => 'ختم';

  @override
  String get orderStatusUnknown => 'نامعلوم';

  @override
  String get orderLabelPeopleEmoji => '👨‍👩‍👧';

  @override
  String errorWithMessage(String message) {
    return 'خرابی: $message';
  }

  @override
  String noOrdersOnDate(String date) {
    return '$date کو کوئی آرڈر نہیں';
  }

  @override
  String get notAvailableAbbrev => 'دستیاب نہیں';

  @override
  String get chefCardChefChip => '👨‍🍳 شیف';

  @override
  String get chefCardExperienceRow => '🧑‍🍳 تجربہ';

  @override
  String get chefCardContactRow => '📞 رابطہ';

  @override
  String get chefCardAddressRow => '📍 پتہ';

  @override
  String get chefCardEmailRow => '📧 ای میل';

  @override
  String get chefCardNoRatings => '⭐ ابھی کوئی ریٹنگ نہیں';

  @override
  String chefCardReviewsCount(int count) {
    return ' ($count جائزے)';
  }

  @override
  String get reviewNoWrittenFeedback => 'تحریری رائے نہیں';

  @override
  String get profileLoadErrorBody =>
      'پروفائل لوڈ نہیں ہو سکی۔ براہ کرم سائن آؤٹ کر کے دوبارہ سائن اِن کریں۔';

  @override
  String get profileAccountDetailsHeading => 'اکاؤنٹ کی تفصیلات';

  @override
  String get profileYourNameHint => 'آپ کا نام';

  @override
  String get profileValidatorNameShort => 'نام درج کریں';

  @override
  String get profileValidatorPhoneShort => 'درست نمبر درج کریں';

  @override
  String get profileSaveChanges => 'پروفائل محفوظ کریں';

  @override
  String get profileChangePasswordHeading => 'پاس ورڈ تبدیل کریں';

  @override
  String get profilePasswordIntro =>
      'نیا پاس ورڈ سیٹ کرنے کے لیے موجودہ پاس ورڈ درج کرنا ضروری ہے۔';

  @override
  String get profileCurrentPassword => 'موجودہ پاس ورڈ';

  @override
  String get profileNewPassword => 'نیا پاس ورڈ';

  @override
  String get profileConfirmNewPassword => 'نئے پاس ورڈ کی تصدیق';

  @override
  String get validatorRequired => 'ضروری';

  @override
  String get validatorPasswordMinSix => 'کم از کم 6 حروف';

  @override
  String get validatorPasswordsNoMatchAlt => 'پاس ورڈ یکساں نہیں';

  @override
  String get profileUpdatePasswordButton => 'پاس ورڈ اپ ڈیٹ';

  @override
  String get profileDeleteAccountHeading => 'اکاؤنٹ حذف کریں';

  @override
  String get profileDeleteAccountBlurb =>
      'اپنا Taste Tailor اکاؤنٹ اور منسلک ڈیٹا مستقل طور پر ہٹائیں۔';

  @override
  String get profileDeleteAccountButton => 'میرا اکاؤنٹ حذف کریں';

  @override
  String get profilePhotoHeading => 'پروفائل تصویر';

  @override
  String get profilePhotoHint =>
      'تصویر بدلنے کے لیے کیمرے کے آئیکن پر ٹیپ کریں';

  @override
  String get profilePhotoGallery => 'گیلری سے منتخب کریں';

  @override
  String get profilePhotoCamera => 'تصویر لیں';

  @override
  String get profilePhotoDismiss => 'منسوخ';

  @override
  String get privacyPolicyLink => 'پرائیویسی پالیسی';

  @override
  String get privacyPolicyOpenFailed => 'لنک نہیں کھل سکا۔ انٹرنیٹ چیک کریں۔';

  @override
  String get chefProfileLoadErrorBody =>
      'شیف پروفائل لوڈ نہیں ہو سکی۔ سائن آؤٹ کر کے دوبارہ سائن اِن کریں۔';

  @override
  String get orderDetailPeopleShort => 'افراد';

  @override
  String get orderDetailDateShort => 'تاریخ';

  @override
  String get orderDetailArrivalShort => 'پہنچ';

  @override
  String get orderDetailEventShort => 'تقریب';

  @override
  String get orderDetailFareShort => 'قیمت';
}
