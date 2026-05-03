// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageHeading => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHybridChip => 'EN + اردو';

  @override
  String get appTitle => 'Bawarchi App';

  @override
  String get splashSubtitle => 'Culinary Excellence';

  @override
  String get getStartedLogin => 'Login';

  @override
  String get getStartedSignUpChef => 'Sign up as a Chef';

  @override
  String get getStartedSignUpUser => 'Sign up as a User';

  @override
  String get exitAppTitle => 'Exit App';

  @override
  String get exitAppMessage => 'Do you really want to exit the app?';

  @override
  String get exitNo => 'No';

  @override
  String get exitYes => 'Yes';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInContinue => 'Sign in to continue';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get login => 'Login';

  @override
  String get fillAllFields => 'Please fill all fields';

  @override
  String get forgotEnterEmail => 'please enter your email!';

  @override
  String get resetEmailSent => 'Reset password email sent';

  @override
  String get enterCorrectEmail => 'enter correct email';

  @override
  String get resetErrorTryLater => 'An error occurred. Please try again later.';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signUpUserSubtitle => 'Sign up as a User';

  @override
  String get signUpChefSubtitle => 'Sign up as a Chef';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get enterPhone => 'Enter your phone number';

  @override
  String get address => 'Address';

  @override
  String get enterAddress => 'Enter your address manually or use GPS above';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmYourPassword => 'Confirm your password';

  @override
  String get signUp => 'Sign Up';

  @override
  String get passwordsMismatch => 'Passwords don\'t match';

  @override
  String get experience => 'Experience';

  @override
  String get experienceHint => 'Years / details';

  @override
  String get speciality => 'Speciality';

  @override
  String get certificate => 'Certificate';

  @override
  String get chefSignUp => 'Sign Up as Chef';

  @override
  String get drawerAllChefs => 'All Chefs';

  @override
  String get drawerNewRequest => 'New Request';

  @override
  String get drawerMessages => 'Messages';

  @override
  String get drawerMyOrders => 'My Orders';

  @override
  String get drawerOrderCalendar => 'Order calendar';

  @override
  String get drawerMyProfile => 'My Profile';

  @override
  String get drawerLogout => 'Logout';

  @override
  String get drawerAllOrders => 'All Orders';

  @override
  String get chefRequestsTitle => 'Requests';

  @override
  String get noRequestsAvailable => 'No requests available.';

  @override
  String get pleaseEnterFare => 'Please enter a price';

  @override
  String get clientBookedYou => 'Client booked you for this';

  @override
  String get allChefsTitle => 'All Chefs';

  @override
  String get searchChefByName => 'Search chef by name';

  @override
  String get allLocations => 'All locations';

  @override
  String noChefMatchSearch(String query) {
    return 'No chefs match \"$query\"';
  }

  @override
  String get tryAnotherChefName => 'Try another name';

  @override
  String get tryWidenLocationFilter =>
      'Try another name, or widen the location filter';

  @override
  String noChefsInCity(String city) {
    return 'No chefs in $city';
  }

  @override
  String get chooseAllLocationsOrCity =>
      'Choose All locations or another city filter';

  @override
  String get noChefsAvailable => 'No chefs available';

  @override
  String get bookThisChef => 'Book this chef';

  @override
  String get signInToBookChef => 'Please sign in to book a chef.';

  @override
  String get cannotBookSelf => 'You cannot book yourself.';

  @override
  String get chefDetailsTitle => 'Chef Details';

  @override
  String get noChefSelected => 'No chef selected';

  @override
  String get chefProfileSection => 'Chef profile';

  @override
  String get certificateSection => 'Certificate';

  @override
  String get chefExperienceInfo => 'Experience';

  @override
  String get chefSpecialtiesInfo => 'Specialties';

  @override
  String get chefAddressInfo => 'Address';

  @override
  String get chefPhoneInfo => 'Phone';

  @override
  String get chefEmailInfo => 'Email';

  @override
  String get reviewsSection => 'Reviews';

  @override
  String get messageChefAboutOrder => 'Message about this booking';

  @override
  String get createRequestTitle => 'Create Request';

  @override
  String get bookAChefTitle => 'Book a chef';

  @override
  String bookingForChefBanner(String name) {
    return 'Booking request for: $name\\nOnly this chef will see this job until you accept an offer.';
  }

  @override
  String get foodItemName => 'Food Item Name';

  @override
  String get enterFoodItem => 'Enter food item name';

  @override
  String get dateLabel => 'Date';

  @override
  String get selectDateHint => 'Select date';

  @override
  String get arrivalTimeLabel => 'Arrival Time';

  @override
  String get eventTimeLabel => 'Event Time';

  @override
  String get numberOfPeople => 'Number of People';

  @override
  String get enterPeopleCount => 'Enter number of people';

  @override
  String get fareLabel => 'Price';

  @override
  String get enterFare => 'Enter price amount';

  @override
  String get submitNewPriceTitle => 'Submit new price';

  @override
  String get enterNewPriceHint => 'Enter new price amount';

  @override
  String priceUpdatedApproveRequest(String amount) {
    return 'Price $amount updated. Please approve the request!';
  }

  @override
  String get availableIngredientsLabel => 'Available Ingredients';

  @override
  String get ingredientsHint => 'List available ingredients';

  @override
  String get submitRequest => 'Submit Request';

  @override
  String get pleaseSelectEventTimeFirst => 'Please select the event time first';

  @override
  String get processingRequest => 'Processing Request...';

  @override
  String get requestSubmittedSuccess => 'Request Submitted Successfully!';

  @override
  String get requestSentAvailableChefs =>
      'Your request has been sent to available chefs.';

  @override
  String requestSentSpecificChef(String name) {
    return 'Your request was sent to $name. They can respond with an offer.';
  }

  @override
  String get okButton => 'OK';

  @override
  String get myOrdersTitle => 'My Orders';

  @override
  String get locationHelpLine =>
      'You can use your current location or type your address below.';

  @override
  String get useCurrentLocation => 'Use current location';

  @override
  String get gettingLocation => 'Getting location…';

  @override
  String get notificationFallbackTitle => 'Notification';

  @override
  String get notificationFallbackOk => 'OK';

  @override
  String get accountDeleteEnterPassword => 'Enter your password to confirm.';

  @override
  String get accountDeletedToast => 'Your account has been deleted.';

  @override
  String get loginSuccessful => 'Login Successful';

  @override
  String get chiefAccountCreated => 'Chief Account Created';

  @override
  String get userAccountCreated => 'User Account Created';

  @override
  String get requestAddedSuccess => 'Request Added Successfully';

  @override
  String get orderNotFound => 'Order not found.';

  @override
  String get orderExpiredToast => 'This order has expired.';

  @override
  String get requestAcceptedToast => 'Request accepted.';

  @override
  String get requestRejectedToast => 'Request rejected.';

  @override
  String get orderCompletedToast => 'order completed';

  @override
  String get pleaseSignInAgain => 'Please sign in again.';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get passwordUpdatedToast => 'Password updated';

  @override
  String get noEmailOnAccount => 'No email on this account.';

  @override
  String get requestMovedMyOrders => 'Request moved to My Orders';

  @override
  String errorUpdatingRequest(String error) {
    return 'Error updating request: $error';
  }

  @override
  String errorAcceptingRequest(String error) {
    return 'Error accepting request: $error';
  }

  @override
  String get requestAcceptedByUser => 'Request accepted by user.';

  @override
  String get requestDeletedSuccess => 'Request successfully deleted';

  @override
  String requestDeleteError(String error) {
    return 'Error deleting request: $error';
  }

  @override
  String get mustBeLoggedInRating =>
      'You must be logged in to submit a rating.';

  @override
  String get thankYouFeedback => 'Thank you for your feedback!';

  @override
  String errorRating(String error) {
    return 'Error submitting rating: $error';
  }

  @override
  String get forgotPasswordScreenTitle => 'Forgot Password';

  @override
  String get submit => 'Submit';

  @override
  String get workExperienceYearsLabel => 'Work Experience (Years)';

  @override
  String get workExperienceHint => 'Enter your work experience';

  @override
  String get specialitiesHint => 'Enter your specialities';

  @override
  String get certificationsTitle => 'Certifications';

  @override
  String get certificateUploaded => 'Certificate uploaded';

  @override
  String get uploadCertificate => 'Upload certificate';

  @override
  String get pickCamera => 'Camera';

  @override
  String get pickGallery => 'Gallery';

  @override
  String get errorTitle => 'Error';

  @override
  String get submitRequestFailed =>
      'Failed to submit request. Please try again.';

  @override
  String get exitFormTitle => 'Exit Form';

  @override
  String get exitFormMessage =>
      'Are you sure you want to exit? Your changes will be lost.';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get exitConfirmButton => 'Exit';

  @override
  String get arrivalBeforeEventToast =>
      'Arrival time must be at least 1 hour before event time';

  @override
  String pleaseEnterField(String field) {
    return 'Please enter $field';
  }

  @override
  String get thisChefLabel => 'This chef';

  @override
  String get theChefFallback => 'the chef';

  @override
  String get selectTimeHint => 'Select time';

  @override
  String bookingForChefLine1(String name) {
    return 'Booking request for: $name';
  }

  @override
  String get bookingForChefLine2 =>
      'Only this chef will see this job until you accept an offer.';

  @override
  String get chefOrdersCalendarTitle => 'My order calendar';

  @override
  String get userOrdersSearchHint => '🔍 Search order by dish name';

  @override
  String get chefsSearchPrefixHint => '🔍 ';

  @override
  String get noOrdersMatchSearch => 'No orders match your search.';

  @override
  String get orderListFarePending => 'Pending';

  @override
  String get orderCardIngredientsHeading => '🥕 Ingredients';

  @override
  String get orderViewChefDetails => 'View Chef Details';

  @override
  String get orderWaitingChefAcceptance => '⏳ Waiting for chef acceptance';

  @override
  String get orderWaitingChefOffers => 'Waiting for chef offers.';

  @override
  String get orderExpiredLine => 'Expired — event date has passed.';

  @override
  String get rateChefButton => '⭐ Rate Chef';

  @override
  String get emptyOrdersAll => 'No orders yet.';

  @override
  String get emptyOrdersPending => 'No pending requests at the moment.';

  @override
  String get emptyOrdersExpired => 'No expired orders.';

  @override
  String get emptyOrdersAssigned => 'No assigned orders.';

  @override
  String get emptyOrdersCompleted => 'No completed orders.';

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusAssigned => 'Assigned';

  @override
  String get orderStatusCompleted => 'Completed';

  @override
  String get orderStatusExpired => 'Expired';

  @override
  String get orderStatusUnknown => 'Unknown';

  @override
  String get orderLabelPeopleEmoji => '👨‍👩‍👧';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String noOrdersOnDate(String date) {
    return 'No orders on $date';
  }

  @override
  String get notAvailableAbbrev => 'N/A';

  @override
  String get chefCardChefChip => '👨‍🍳 Chef';

  @override
  String get chefCardExperienceRow => '🧑‍🍳 Experience';

  @override
  String get chefCardContactRow => '📞 Contact';

  @override
  String get chefCardAddressRow => '📍 Address';

  @override
  String get chefCardEmailRow => '📧 Email';

  @override
  String get chefCardNoRatings => '⭐ No ratings yet';

  @override
  String chefCardReviewsCount(int count) {
    return ' ($count reviews)';
  }

  @override
  String get reviewNoWrittenFeedback => 'No written feedback';

  @override
  String get profileLoadErrorBody =>
      'Could not load your profile. Please sign out and sign in again.';

  @override
  String get profileAccountDetailsHeading => 'Account details';

  @override
  String get profileYourNameHint => 'Your name';

  @override
  String get profileValidatorNameShort => 'Enter your name';

  @override
  String get profileValidatorPhoneShort => 'Enter a valid number';

  @override
  String get profileSaveChanges => 'Save profile';

  @override
  String get profileChangePasswordHeading => 'Change password';

  @override
  String get profilePasswordIntro =>
      'You must enter your current password to set a new one.';

  @override
  String get profileCurrentPassword => 'Current password';

  @override
  String get profileNewPassword => 'New password';

  @override
  String get profileConfirmNewPassword => 'Confirm new password';

  @override
  String get validatorRequired => 'Required';

  @override
  String get validatorPasswordMinSix => 'At least 6 characters';

  @override
  String get validatorPasswordsNoMatchAlt => 'Passwords do not match';

  @override
  String get profileUpdatePasswordButton => 'Update password';

  @override
  String get profileDeleteAccountHeading => 'Delete account';

  @override
  String get profileDeleteAccountBlurb =>
      'Permanently remove your Taste Tailor account and associated profile data.';

  @override
  String get profileDeleteAccountButton => 'Delete my account';

  @override
  String get profilePhotoHeading => 'Profile photo';

  @override
  String get profilePhotoHint => 'Tap the camera icon to change your picture';

  @override
  String get profilePhotoGallery => 'Choose from gallery';

  @override
  String get profilePhotoCamera => 'Take photo';

  @override
  String get profilePhotoDismiss => 'Cancel';

  @override
  String get privacyPolicyLink => 'Privacy Policy';

  @override
  String get privacyPolicyOpenFailed =>
      'Could not open the link. Check your internet connection.';

  @override
  String get chefProfileLoadErrorBody =>
      'Could not load your chef profile. Please sign out and sign in again.';

  @override
  String get orderDetailPeopleShort => 'People';

  @override
  String get orderDetailDateShort => 'Date';

  @override
  String get orderDetailArrivalShort => 'Arrival';

  @override
  String get orderDetailEventShort => 'Event';

  @override
  String get orderDetailFareShort => 'Price';
}
