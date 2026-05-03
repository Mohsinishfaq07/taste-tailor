import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

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
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @languageHeading.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageHeading;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHybridChip.
  ///
  /// In en, this message translates to:
  /// **'EN + اردو'**
  String get languageHybridChip;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Bawarchi App'**
  String get appTitle;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Culinary Excellence'**
  String get splashSubtitle;

  /// No description provided for @getStartedLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get getStartedLogin;

  /// No description provided for @getStartedSignUpChef.
  ///
  /// In en, this message translates to:
  /// **'Sign up as a Chef'**
  String get getStartedSignUpChef;

  /// No description provided for @getStartedSignUpUser.
  ///
  /// In en, this message translates to:
  /// **'Sign up as a User'**
  String get getStartedSignUpUser;

  /// No description provided for @exitAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exitAppTitle;

  /// No description provided for @exitAppMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to exit the app?'**
  String get exitAppMessage;

  /// No description provided for @exitNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get exitNo;

  /// No description provided for @exitYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get exitYes;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInContinue;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get fillAllFields;

  /// No description provided for @forgotEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'please enter your email!'**
  String get forgotEnterEmail;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Reset password email sent'**
  String get resetEmailSent;

  /// No description provided for @enterCorrectEmail.
  ///
  /// In en, this message translates to:
  /// **'enter correct email'**
  String get enterCorrectEmail;

  /// No description provided for @resetErrorTryLater.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again later.'**
  String get resetErrorTryLater;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signUpUserSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up as a User'**
  String get signUpUserSubtitle;

  /// No description provided for @signUpChefSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up as a Chef'**
  String get signUpChefSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @enterAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your address manually or use GPS above'**
  String get enterAddress;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @passwordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsMismatch;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @experienceHint.
  ///
  /// In en, this message translates to:
  /// **'Years / details'**
  String get experienceHint;

  /// No description provided for @speciality.
  ///
  /// In en, this message translates to:
  /// **'Speciality'**
  String get speciality;

  /// No description provided for @certificate.
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get certificate;

  /// No description provided for @chefSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up as Chef'**
  String get chefSignUp;

  /// No description provided for @drawerAllChefs.
  ///
  /// In en, this message translates to:
  /// **'All Chefs'**
  String get drawerAllChefs;

  /// No description provided for @drawerNewRequest.
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get drawerNewRequest;

  /// No description provided for @drawerMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get drawerMessages;

  /// No description provided for @drawerMyOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get drawerMyOrders;

  /// No description provided for @drawerOrderCalendar.
  ///
  /// In en, this message translates to:
  /// **'Order calendar'**
  String get drawerOrderCalendar;

  /// No description provided for @drawerMyProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get drawerMyProfile;

  /// No description provided for @drawerLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get drawerLogout;

  /// No description provided for @drawerAllOrders.
  ///
  /// In en, this message translates to:
  /// **'All Orders'**
  String get drawerAllOrders;

  /// No description provided for @chefRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get chefRequestsTitle;

  /// No description provided for @noRequestsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No requests available.'**
  String get noRequestsAvailable;

  /// No description provided for @pleaseEnterFare.
  ///
  /// In en, this message translates to:
  /// **'Please enter a price'**
  String get pleaseEnterFare;

  /// No description provided for @clientBookedYou.
  ///
  /// In en, this message translates to:
  /// **'Client booked you for this'**
  String get clientBookedYou;

  /// No description provided for @allChefsTitle.
  ///
  /// In en, this message translates to:
  /// **'All Chefs'**
  String get allChefsTitle;

  /// No description provided for @searchChefByName.
  ///
  /// In en, this message translates to:
  /// **'Search chef by name'**
  String get searchChefByName;

  /// No description provided for @allLocations.
  ///
  /// In en, this message translates to:
  /// **'All locations'**
  String get allLocations;

  /// No description provided for @noChefMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No chefs match \"{query}\"'**
  String noChefMatchSearch(String query);

  /// No description provided for @tryAnotherChefName.
  ///
  /// In en, this message translates to:
  /// **'Try another name'**
  String get tryAnotherChefName;

  /// No description provided for @tryWidenLocationFilter.
  ///
  /// In en, this message translates to:
  /// **'Try another name, or widen the location filter'**
  String get tryWidenLocationFilter;

  /// No description provided for @noChefsInCity.
  ///
  /// In en, this message translates to:
  /// **'No chefs in {city}'**
  String noChefsInCity(String city);

  /// No description provided for @chooseAllLocationsOrCity.
  ///
  /// In en, this message translates to:
  /// **'Choose All locations or another city filter'**
  String get chooseAllLocationsOrCity;

  /// No description provided for @noChefsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No chefs available'**
  String get noChefsAvailable;

  /// No description provided for @bookThisChef.
  ///
  /// In en, this message translates to:
  /// **'Book this chef'**
  String get bookThisChef;

  /// No description provided for @signInToBookChef.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to book a chef.'**
  String get signInToBookChef;

  /// No description provided for @cannotBookSelf.
  ///
  /// In en, this message translates to:
  /// **'You cannot book yourself.'**
  String get cannotBookSelf;

  /// No description provided for @chefDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Chef Details'**
  String get chefDetailsTitle;

  /// No description provided for @noChefSelected.
  ///
  /// In en, this message translates to:
  /// **'No chef selected'**
  String get noChefSelected;

  /// No description provided for @chefProfileSection.
  ///
  /// In en, this message translates to:
  /// **'Chef profile'**
  String get chefProfileSection;

  /// No description provided for @certificateSection.
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get certificateSection;

  /// No description provided for @chefExperienceInfo.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get chefExperienceInfo;

  /// No description provided for @chefSpecialtiesInfo.
  ///
  /// In en, this message translates to:
  /// **'Specialties'**
  String get chefSpecialtiesInfo;

  /// No description provided for @chefAddressInfo.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get chefAddressInfo;

  /// No description provided for @chefPhoneInfo.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get chefPhoneInfo;

  /// No description provided for @chefEmailInfo.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get chefEmailInfo;

  /// No description provided for @reviewsSection.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsSection;

  /// No description provided for @messageChefAboutOrder.
  ///
  /// In en, this message translates to:
  /// **'Message about this booking'**
  String get messageChefAboutOrder;

  /// No description provided for @createRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Request'**
  String get createRequestTitle;

  /// No description provided for @bookAChefTitle.
  ///
  /// In en, this message translates to:
  /// **'Book a chef'**
  String get bookAChefTitle;

  /// No description provided for @bookingForChefBanner.
  ///
  /// In en, this message translates to:
  /// **'Booking request for: {name}\\nOnly this chef will see this job until you accept an offer.'**
  String bookingForChefBanner(String name);

  /// No description provided for @foodItemName.
  ///
  /// In en, this message translates to:
  /// **'Food Item Name'**
  String get foodItemName;

  /// No description provided for @enterFoodItem.
  ///
  /// In en, this message translates to:
  /// **'Enter food item name'**
  String get enterFoodItem;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @selectDateHint.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDateHint;

  /// No description provided for @arrivalTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Arrival Time'**
  String get arrivalTimeLabel;

  /// No description provided for @eventTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Event Time'**
  String get eventTimeLabel;

  /// No description provided for @numberOfPeople.
  ///
  /// In en, this message translates to:
  /// **'Number of People'**
  String get numberOfPeople;

  /// No description provided for @enterPeopleCount.
  ///
  /// In en, this message translates to:
  /// **'Enter number of people'**
  String get enterPeopleCount;

  /// No description provided for @fareLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get fareLabel;

  /// No description provided for @enterFare.
  ///
  /// In en, this message translates to:
  /// **'Enter price amount'**
  String get enterFare;

  /// No description provided for @submitNewPriceTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit new price'**
  String get submitNewPriceTitle;

  /// No description provided for @enterNewPriceHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new price amount'**
  String get enterNewPriceHint;

  /// No description provided for @priceUpdatedApproveRequest.
  ///
  /// In en, this message translates to:
  /// **'Price {amount} updated. Please approve the request!'**
  String priceUpdatedApproveRequest(String amount);

  /// No description provided for @availableIngredientsLabel.
  ///
  /// In en, this message translates to:
  /// **'Available Ingredients'**
  String get availableIngredientsLabel;

  /// No description provided for @ingredientsHint.
  ///
  /// In en, this message translates to:
  /// **'List available ingredients'**
  String get ingredientsHint;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @pleaseSelectEventTimeFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select the event time first'**
  String get pleaseSelectEventTimeFirst;

  /// No description provided for @processingRequest.
  ///
  /// In en, this message translates to:
  /// **'Processing Request...'**
  String get processingRequest;

  /// No description provided for @requestSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request Submitted Successfully!'**
  String get requestSubmittedSuccess;

  /// No description provided for @requestSentAvailableChefs.
  ///
  /// In en, this message translates to:
  /// **'Your request has been sent to available chefs.'**
  String get requestSentAvailableChefs;

  /// No description provided for @requestSentSpecificChef.
  ///
  /// In en, this message translates to:
  /// **'Your request was sent to {name}. They can respond with an offer.'**
  String requestSentSpecificChef(String name);

  /// No description provided for @okButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @myOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrdersTitle;

  /// No description provided for @locationHelpLine.
  ///
  /// In en, this message translates to:
  /// **'You can use your current location or type your address below.'**
  String get locationHelpLine;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocation;

  /// No description provided for @gettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting location…'**
  String get gettingLocation;

  /// No description provided for @notificationFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationFallbackTitle;

  /// No description provided for @notificationFallbackOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get notificationFallbackOk;

  /// No description provided for @accountDeleteEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm.'**
  String get accountDeleteEnterPassword;

  /// No description provided for @accountDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get accountDeletedToast;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login Successful'**
  String get loginSuccessful;

  /// No description provided for @chiefAccountCreated.
  ///
  /// In en, this message translates to:
  /// **'Chief Account Created'**
  String get chiefAccountCreated;

  /// No description provided for @userAccountCreated.
  ///
  /// In en, this message translates to:
  /// **'User Account Created'**
  String get userAccountCreated;

  /// No description provided for @requestAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request Added Successfully'**
  String get requestAddedSuccess;

  /// No description provided for @orderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found.'**
  String get orderNotFound;

  /// No description provided for @orderExpiredToast.
  ///
  /// In en, this message translates to:
  /// **'This order has expired.'**
  String get orderExpiredToast;

  /// No description provided for @requestAcceptedToast.
  ///
  /// In en, this message translates to:
  /// **'Request accepted.'**
  String get requestAcceptedToast;

  /// No description provided for @requestRejectedToast.
  ///
  /// In en, this message translates to:
  /// **'Request rejected.'**
  String get requestRejectedToast;

  /// No description provided for @orderCompletedToast.
  ///
  /// In en, this message translates to:
  /// **'order completed'**
  String get orderCompletedToast;

  /// No description provided for @pleaseSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again.'**
  String get pleaseSignInAgain;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @passwordUpdatedToast.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get passwordUpdatedToast;

  /// No description provided for @noEmailOnAccount.
  ///
  /// In en, this message translates to:
  /// **'No email on this account.'**
  String get noEmailOnAccount;

  /// No description provided for @requestMovedMyOrders.
  ///
  /// In en, this message translates to:
  /// **'Request moved to My Orders'**
  String get requestMovedMyOrders;

  /// No description provided for @errorUpdatingRequest.
  ///
  /// In en, this message translates to:
  /// **'Error updating request: {error}'**
  String errorUpdatingRequest(String error);

  /// No description provided for @errorAcceptingRequest.
  ///
  /// In en, this message translates to:
  /// **'Error accepting request: {error}'**
  String errorAcceptingRequest(String error);

  /// No description provided for @requestAcceptedByUser.
  ///
  /// In en, this message translates to:
  /// **'Request accepted by user.'**
  String get requestAcceptedByUser;

  /// No description provided for @requestDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request successfully deleted'**
  String get requestDeletedSuccess;

  /// No description provided for @requestDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting request: {error}'**
  String requestDeleteError(String error);

  /// No description provided for @mustBeLoggedInRating.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to submit a rating.'**
  String get mustBeLoggedInRating;

  /// No description provided for @thankYouFeedback.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get thankYouFeedback;

  /// No description provided for @errorRating.
  ///
  /// In en, this message translates to:
  /// **'Error submitting rating: {error}'**
  String errorRating(String error);

  /// No description provided for @forgotPasswordScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordScreenTitle;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @workExperienceYearsLabel.
  ///
  /// In en, this message translates to:
  /// **'Work Experience (Years)'**
  String get workExperienceYearsLabel;

  /// No description provided for @workExperienceHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your work experience'**
  String get workExperienceHint;

  /// No description provided for @specialitiesHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your specialities'**
  String get specialitiesHint;

  /// No description provided for @certificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Certifications'**
  String get certificationsTitle;

  /// No description provided for @certificateUploaded.
  ///
  /// In en, this message translates to:
  /// **'Certificate uploaded'**
  String get certificateUploaded;

  /// No description provided for @uploadCertificate.
  ///
  /// In en, this message translates to:
  /// **'Upload certificate'**
  String get uploadCertificate;

  /// No description provided for @pickCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get pickCamera;

  /// No description provided for @pickGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get pickGallery;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @submitRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit request. Please try again.'**
  String get submitRequestFailed;

  /// No description provided for @exitFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit Form'**
  String get exitFormTitle;

  /// No description provided for @exitFormMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit? Your changes will be lost.'**
  String get exitFormMessage;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @exitConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitConfirmButton;

  /// No description provided for @arrivalBeforeEventToast.
  ///
  /// In en, this message translates to:
  /// **'Arrival time must be at least 1 hour before event time'**
  String get arrivalBeforeEventToast;

  /// No description provided for @pleaseEnterField.
  ///
  /// In en, this message translates to:
  /// **'Please enter {field}'**
  String pleaseEnterField(String field);

  /// No description provided for @thisChefLabel.
  ///
  /// In en, this message translates to:
  /// **'This chef'**
  String get thisChefLabel;

  /// No description provided for @theChefFallback.
  ///
  /// In en, this message translates to:
  /// **'the chef'**
  String get theChefFallback;

  /// No description provided for @selectTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTimeHint;

  /// No description provided for @bookingForChefLine1.
  ///
  /// In en, this message translates to:
  /// **'Booking request for: {name}'**
  String bookingForChefLine1(String name);

  /// No description provided for @bookingForChefLine2.
  ///
  /// In en, this message translates to:
  /// **'Only this chef will see this job until you accept an offer.'**
  String get bookingForChefLine2;

  /// No description provided for @chefOrdersCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'My order calendar'**
  String get chefOrdersCalendarTitle;

  /// No description provided for @userOrdersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'🔍 Search order by dish name'**
  String get userOrdersSearchHint;

  /// No description provided for @chefsSearchPrefixHint.
  ///
  /// In en, this message translates to:
  /// **'🔍 '**
  String get chefsSearchPrefixHint;

  /// No description provided for @noOrdersMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No orders match your search.'**
  String get noOrdersMatchSearch;

  /// No description provided for @orderListFarePending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderListFarePending;

  /// No description provided for @orderCardIngredientsHeading.
  ///
  /// In en, this message translates to:
  /// **'🥕 Ingredients'**
  String get orderCardIngredientsHeading;

  /// No description provided for @orderViewChefDetails.
  ///
  /// In en, this message translates to:
  /// **'View Chef Details'**
  String get orderViewChefDetails;

  /// No description provided for @orderWaitingChefAcceptance.
  ///
  /// In en, this message translates to:
  /// **'⏳ Waiting for chef acceptance'**
  String get orderWaitingChefAcceptance;

  /// No description provided for @orderWaitingChefOffers.
  ///
  /// In en, this message translates to:
  /// **'Waiting for chef offers.'**
  String get orderWaitingChefOffers;

  /// No description provided for @orderExpiredLine.
  ///
  /// In en, this message translates to:
  /// **'Expired — event date has passed.'**
  String get orderExpiredLine;

  /// No description provided for @rateChefButton.
  ///
  /// In en, this message translates to:
  /// **'⭐ Rate Chef'**
  String get rateChefButton;

  /// No description provided for @emptyOrdersAll.
  ///
  /// In en, this message translates to:
  /// **'No orders yet.'**
  String get emptyOrdersAll;

  /// No description provided for @emptyOrdersPending.
  ///
  /// In en, this message translates to:
  /// **'No pending requests at the moment.'**
  String get emptyOrdersPending;

  /// No description provided for @emptyOrdersExpired.
  ///
  /// In en, this message translates to:
  /// **'No expired orders.'**
  String get emptyOrdersExpired;

  /// No description provided for @emptyOrdersAssigned.
  ///
  /// In en, this message translates to:
  /// **'No assigned orders.'**
  String get emptyOrdersAssigned;

  /// No description provided for @emptyOrdersCompleted.
  ///
  /// In en, this message translates to:
  /// **'No completed orders.'**
  String get emptyOrdersCompleted;

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderStatusAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get orderStatusAssigned;

  /// No description provided for @orderStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get orderStatusCompleted;

  /// No description provided for @orderStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get orderStatusExpired;

  /// No description provided for @orderStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get orderStatusUnknown;

  /// No description provided for @orderLabelPeopleEmoji.
  ///
  /// In en, this message translates to:
  /// **'👨‍👩‍👧'**
  String get orderLabelPeopleEmoji;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @noOrdersOnDate.
  ///
  /// In en, this message translates to:
  /// **'No orders on {date}'**
  String noOrdersOnDate(String date);

  /// No description provided for @notAvailableAbbrev.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailableAbbrev;

  /// No description provided for @chefCardChefChip.
  ///
  /// In en, this message translates to:
  /// **'👨‍🍳 Chef'**
  String get chefCardChefChip;

  /// No description provided for @chefCardExperienceRow.
  ///
  /// In en, this message translates to:
  /// **'🧑‍🍳 Experience'**
  String get chefCardExperienceRow;

  /// No description provided for @chefCardContactRow.
  ///
  /// In en, this message translates to:
  /// **'📞 Contact'**
  String get chefCardContactRow;

  /// No description provided for @chefCardAddressRow.
  ///
  /// In en, this message translates to:
  /// **'📍 Address'**
  String get chefCardAddressRow;

  /// No description provided for @chefCardEmailRow.
  ///
  /// In en, this message translates to:
  /// **'📧 Email'**
  String get chefCardEmailRow;

  /// No description provided for @chefCardNoRatings.
  ///
  /// In en, this message translates to:
  /// **'⭐ No ratings yet'**
  String get chefCardNoRatings;

  /// No description provided for @chefCardReviewsCount.
  ///
  /// In en, this message translates to:
  /// **' ({count} reviews)'**
  String chefCardReviewsCount(int count);

  /// No description provided for @reviewNoWrittenFeedback.
  ///
  /// In en, this message translates to:
  /// **'No written feedback'**
  String get reviewNoWrittenFeedback;

  /// No description provided for @profileLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Could not load your profile. Please sign out and sign in again.'**
  String get profileLoadErrorBody;

  /// No description provided for @profileAccountDetailsHeading.
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get profileAccountDetailsHeading;

  /// No description provided for @profileYourNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get profileYourNameHint;

  /// No description provided for @profileValidatorNameShort.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get profileValidatorNameShort;

  /// No description provided for @profileValidatorPhoneShort.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get profileValidatorPhoneShort;

  /// No description provided for @profileSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get profileSaveChanges;

  /// No description provided for @profileChangePasswordHeading.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profileChangePasswordHeading;

  /// No description provided for @profilePasswordIntro.
  ///
  /// In en, this message translates to:
  /// **'You must enter your current password to set a new one.'**
  String get profilePasswordIntro;

  /// No description provided for @profileCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get profileCurrentPassword;

  /// No description provided for @profileNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get profileNewPassword;

  /// No description provided for @profileConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get profileConfirmNewPassword;

  /// No description provided for @validatorRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get validatorRequired;

  /// No description provided for @validatorPasswordMinSix.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get validatorPasswordMinSix;

  /// No description provided for @validatorPasswordsNoMatchAlt.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validatorPasswordsNoMatchAlt;

  /// No description provided for @profileUpdatePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get profileUpdatePasswordButton;

  /// No description provided for @profileDeleteAccountHeading.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profileDeleteAccountHeading;

  /// No description provided for @profileDeleteAccountBlurb.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your Taste Tailor account and associated profile data.'**
  String get profileDeleteAccountBlurb;

  /// No description provided for @profileDeleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get profileDeleteAccountButton;

  /// No description provided for @profilePhotoHeading.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhotoHeading;

  /// No description provided for @profilePhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the camera icon to change your picture'**
  String get profilePhotoHint;

  /// No description provided for @profilePhotoGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get profilePhotoGallery;

  /// No description provided for @profilePhotoCamera.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get profilePhotoCamera;

  /// No description provided for @profilePhotoDismiss.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profilePhotoDismiss;

  /// No description provided for @privacyPolicyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyLink;

  /// No description provided for @privacyPolicyOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link. Check your internet connection.'**
  String get privacyPolicyOpenFailed;

  /// No description provided for @chefProfileLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Could not load your chef profile. Please sign out and sign in again.'**
  String get chefProfileLoadErrorBody;

  /// No description provided for @orderDetailPeopleShort.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get orderDetailPeopleShort;

  /// No description provided for @orderDetailDateShort.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get orderDetailDateShort;

  /// No description provided for @orderDetailArrivalShort.
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get orderDetailArrivalShort;

  /// No description provided for @orderDetailEventShort.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get orderDetailEventShort;

  /// No description provided for @orderDetailFareShort.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get orderDetailFareShort;
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
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
