
import 'package:flutter_riverpod/legacy.dart';
import '../service/local_storage_service.dart';
import '../service/auth_service.dart';

/// Abstract base class for App Language Localization
abstract class AppLanguage {
  String get languageCode;
  String get languageName;

  // Bottom Navigation
  String get home;
  String get chat;
  String get task;
  String get vip;
  String get profit;
  String get account;

  // Common UI & Dialogs
  String get selectLanguage;
  String get english;
  String get burmese;
  String get login;
  String get signUp;
  String get logout;
  String get cancel;
  String get save;
  String get ok;
  String get confirm;
  String get loading;
  String get error;
  String get success;
  String get withdraw;
  String get balance;
  String get submit;
  String get done;
  String get copy;
  String get search;
  String get send;
  String get back;

  // Account Screen
  String get userNotFound;
  String get wealthCenter;
  String get userIdCopied;
  String get membershipLevel;
  String get totalBalance;
  String get planProgress;
  String get tasksDone;
  String get totalProfit;
  String get addFunds;
  String get transactions;
  String get myTeam;
  String get changeLanguage;
  String get registerNow;
  String get earnMore;
  String get helpCenter;
  String get donate;
  String get confirmLogout;
  String get logoutConfirmMsg;
  String get withdrawSelected;

  // Home Screen
  String get adminControlPanel;
  String get adminSubTitle;
  String get operationalAnalytics;
  String get portfolioBalance;
  String get incomeTiers;

  // Task & Reel Screen
  String get planNotActive;
  String get unlockPlanToWatch;
  String get noVideosAvailable;
  String get dailyLimitReached;
  String get noNewTasksAvailable;
  String get completedAllTasksToday;
  String get watchedAllVideos;
  String get watchAgain;
  String get reviewModeNoRewards;
  String get plan;
  String get progress;
  String get exitReview;
  String get swipe;
  String get watchingInReviewMode;
  String get watchVideoFully;
  String get completed;
  String get watching;
  String get completeTask;
  String get taskCompletedSuccess;

  // Investment & VIP Screen
  String get planUnlocked;
  String get planUnlockedMsg;
  String get investmentTiers;
  String get noPlansAvailable;
  String get errorLoadingPlans;
  String get activePortfolio;
  String get expiryDate;
  String get active;
  String get dailyTask;
  String get payPerTask;
  String get dailyRoi;
  String get investmentAmount;
  String get unlock;

  // Profit Analytics
  String get profitAnalytics;
  String get earningsSummary;
  String get taskStatistics;
  String get totalEarnings;
  String get yesterday;
  String get today;
  String get thisWeek;
  String get thisMonth;
  String get offerEarning;
  String get referralRewards;
  String get taskRewards;
  String get completedToday;
  String get remainingToday;

  // Auth (Login / Sign Up / Forgot Password)
  String get welcomeBack;
  String get username;
  String get emailAddress;
  String get password;
  String get confirmPassword;
  String get referralCode;
  String get referralOptional;
  String get forgotPassword;
  String get resetPassword;
  String get sendLink;
  String get enterEmail;
  String get enterValidEmail;
  String get enterPassword;
  String get minimum6Chars;
  String get enterUsername;
  String get passwordsDoNotMatch;
  String get signUpSuccess;
  String get alreadyHaveAccount;
  String get dontHaveAccount;
  String get registerForWealthFlow;
  String get loginToWealthFlow;

  // Referral Management
  String get referralProgram;
  String get enterReferralCodeMsg;
  String get activeReferrer;
  String get enterReferralCode;
  String get pleaseEnterReferralCode;
  String get referralAddedSuccess;
  String get saveCode;

  // Chat Screen
  String get adminSupport;
  String get typeMessage;
  String get noMessagesYet;
  String get connectedTeam;
  String get online;
  String get offline;
  String get lastSeen;
  String get uplineReferrer;
  String get downlineMember;
  String get sendPhoto;
  String get camera;
  String get gallery;
  String get noConnectedContacts;
  String get inviteFriendsToChat;
  String get photo;

  // Donate Screen
  String get donateToMember;
  String get supportTeamMembers;
  String get transferOrDonateMsg;
  String get donationDetails;
  String get memberEmailOrUserId;
  String get amountThb;
  String get submitDonation;
  String get transferSuccessful;
  String get successfullyDonated;

  // Help Center
  String get howCanWeHelpYou;
  String get liveChat;
  String get speakWithSupportTeam;
  String get emailSupport;
  String get sendUsMessageAnytime;
  String get commonQuestions;
  String get howToWithdraw;
  String get whatAreVipLevels;
  String get howToInviteFriends;

  // My Team
  String get teamStatistics;
  String get totalTeamSize;
  String get members;
  String get directMembersLv1;
  String get indirectMembersLv2;
  String get extendedMembersLv3;

  // Add Funds
  String get scanQrOrCopyAddress;
  String get noPaymentWalletSet;
  String get walletAddressCopied;
  String get paymentDetails;
  String get transactionHashId;
  String get submitDeposit;
  String get requestSubmitted;
  String get depositSentForApproval;

  // Transactions
  String get myHistory;
  String get referralHistory;
  String get noReferralActivityYet;
  String get noTransactionsYet;

  // Admin Dashboard
  String get totalUsers;
  String get pendingDeposits;
  String get pendingWithdrawals;
  String get userManagement;
  String get settings;
  String get requests;

  /// Utility helper for custom/dynamic English vs Burmese text evaluation
  String tr(String englishText, String burmeseText) {
    return languageCode == 'my' ? burmeseText : englishText;
  }
}

/// English Implementation
class EnglishLanguage extends AppLanguage {
  @override
  String get languageCode => 'en';

  @override
  String get languageName => 'English';

  // Bottom Navigation
  @override
  String get home => 'Home';
  @override
  String get chat => 'Chat';
  @override
  String get task => 'Task';
  @override
  String get vip => 'VIP';
  @override
  String get profit => 'Profit';
  @override
  String get account => 'Account';

  // Common UI
  @override
  String get selectLanguage => 'Select Language';
  @override
  String get english => 'English';
  @override
  String get burmese => 'မြန်မာ (Burmese)';
  @override
  String get login => 'LOGIN';
  @override
  String get signUp => 'SIGN UP';
  @override
  String get logout => 'LOGOUT';
  @override
  String get cancel => 'CANCEL';
  @override
  String get save => 'SAVE';
  @override
  String get ok => 'OK';
  @override
  String get confirm => 'Confirm';
  @override
  String get loading => 'Loading...';
  @override
  String get error => 'Error';
  @override
  String get success => 'Success';
  @override
  String get withdraw => 'Withdraw';
  @override
  String get balance => 'Balance';
  @override
  String get submit => 'SUBMIT';
  @override
  String get done => 'DONE';
  @override
  String get copy => 'COPY';
  @override
  String get search => 'Search';
  @override
  String get send => 'SEND';
  @override
  String get back => 'Back';

  // Account
  @override
  String get userNotFound => 'User not found';
  @override
  String get wealthCenter => 'Wealth Center';
  @override
  String get userIdCopied => 'User ID copied to clipboard';
  @override
  String get membershipLevel => 'Membership Level';
  @override
  String get totalBalance => 'Total Balance';
  @override
  String get planProgress => 'Plan Progress';
  @override
  String get tasksDone => 'Tasks Done';
  @override
  String get totalProfit => 'Total Profit';
  @override
  String get addFunds => 'Add Funds';
  @override
  String get transactions => 'Transactions';
  @override
  String get myTeam => 'My Team';
  @override
  String get changeLanguage => 'Change Language';
  @override
  String get registerNow => 'Register Now';
  @override
  String get earnMore => 'Earn More';
  @override
  String get helpCenter => 'Help Center';
  @override
  String get donate => 'Donate';
  @override
  String get confirmLogout => 'Confirm Logout';
  @override
  String get logoutConfirmMsg => 'Are you sure you want to log out?';
  @override
  String get withdrawSelected => 'Withdraw selected';

  // Home
  @override
  String get adminControlPanel => 'Admin Control Panel';
  @override
  String get adminSubTitle => 'Tap to manage users, deposits & settings';
  @override
  String get operationalAnalytics => 'Operational Analytics';
  @override
  String get portfolioBalance => 'Portfolio Balance';
  @override
  String get incomeTiers => 'Income Tiers';

  // Task & Reel
  @override
  String get planNotActive => 'Plan Not Active';
  @override
  String get unlockPlanToWatch => 'Please unlock an investment plan to start watching videos and earning rewards.';
  @override
  String get noVideosAvailable => 'No videos available.';
  @override
  String get dailyLimitReached => 'Daily Limit Reached!';
  @override
  String get noNewTasksAvailable => 'No New Tasks Available';
  @override
  String get completedAllTasksToday => 'You have completed all your tasks for today. Come back tomorrow!';
  @override
  String get watchedAllVideos => 'You have watched all unique videos in our library. Feel free to re-watch!';
  @override
  String get watchAgain => 'Watch Again';
  @override
  String get reviewModeNoRewards => 'Review Mode (No Rewards)';
  @override
  String get plan => 'Plan';
  @override
  String get progress => 'Progress';
  @override
  String get exitReview => 'Exit Review';
  @override
  String get swipe => 'Swipe';
  @override
  String get watchingInReviewMode => 'You are watching this in review mode.';
  @override
  String get watchVideoFully => 'Watch this video fully to complete your daily task.';
  @override
  String get completed => 'Completed';
  @override
  String get watching => 'Watching...';
  @override
  String get completeTask => 'Complete Task';
  @override
  String get taskCompletedSuccess => 'Task completed successfully! Received';

  // Investment
  @override
  String get planUnlocked => 'Plan Unlocked!';
  @override
  String get planUnlockedMsg => 'You have successfully activated';
  @override
  String get investmentTiers => 'Investment Tiers';
  @override
  String get noPlansAvailable => 'No investment plans available.';
  @override
  String get errorLoadingPlans => 'Error loading plans';
  @override
  String get activePortfolio => 'Active Portfolio';
  @override
  String get expiryDate => 'Expiry Date';
  @override
  String get active => 'Active';
  @override
  String get dailyTask => 'Daily Task';
  @override
  String get payPerTask => 'Pay Per Task';
  @override
  String get dailyRoi => 'Daily ROI';
  @override
  String get investmentAmount => 'Investment Amount';
  @override
  String get unlock => 'Unlock';

  // Profit Analytics
  @override
  String get profitAnalytics => 'Profit Analytics';
  @override
  String get earningsSummary => 'Earnings Summary';
  @override
  String get taskStatistics => 'Task Statistics';
  @override
  String get totalEarnings => 'Total Earnings';
  @override
  String get yesterday => 'Yesterday';
  @override
  String get today => 'Today';
  @override
  String get thisWeek => 'This Week';
  @override
  String get thisMonth => 'This Month';
  @override
  String get offerEarning => 'Offer Earning';
  @override
  String get referralRewards => 'Referral Rewards';
  @override
  String get taskRewards => 'Task Rewards';
  @override
  String get completedToday => 'Completed Today';
  @override
  String get remainingToday => 'Remaining Today';

  // Auth
  @override
  String get welcomeBack => 'Welcome Back';
  @override
  String get username => 'Username';
  @override
  String get emailAddress => 'Email Address';
  @override
  String get password => 'Password';
  @override
  String get confirmPassword => 'Confirm Password';
  @override
  String get referralCode => 'Referral Code';
  @override
  String get referralOptional => 'Referral (Optional)';
  @override
  String get forgotPassword => 'Forgot Password?';
  @override
  String get resetPassword => 'Reset Password';
  @override
  String get sendLink => 'SEND LINK';
  @override
  String get enterEmail => 'Enter email';
  @override
  String get enterValidEmail => 'Enter valid email';
  @override
  String get enterPassword => 'Enter password';
  @override
  String get minimum6Chars => 'Minimum 6 characters';
  @override
  String get enterUsername => 'Enter username';
  @override
  String get passwordsDoNotMatch => 'Passwords do not match';
  @override
  String get signUpSuccess => 'Sign up successful';
  @override
  String get alreadyHaveAccount => 'Already have an account?';
  @override
  String get dontHaveAccount => "Don't have an account?";
  @override
  String get registerForWealthFlow => 'Register for Wealth Flow';
  @override
  String get loginToWealthFlow => 'Login to Wealth Flow';

  // Referral
  @override
  String get referralProgram => 'Referral Program';
  @override
  String get enterReferralCodeMsg => 'Enter a referral code to unlock more earnings and connect with your team.';
  @override
  String get activeReferrer => 'Active Referrer';
  @override
  String get enterReferralCode => 'Enter Referral Code';
  @override
  String get pleaseEnterReferralCode => 'Please enter a referral code';
  @override
  String get referralAddedSuccess => 'Referral added successfully!';
  @override
  String get saveCode => 'SAVE CODE';

  // Chat
  @override
  String get adminSupport => 'Admin Support';
  @override
  String get typeMessage => 'Type a message...';
  @override
  String get noMessagesYet => 'No messages yet';
  @override
  String get connectedTeam => 'Referral Team Chat';
  @override
  String get online => 'Online';
  @override
  String get offline => 'Offline';
  @override
  String get lastSeen => 'Last seen';
  @override
  String get uplineReferrer => 'Upline Referrer';
  @override
  String get downlineMember => 'Team Member';
  @override
  String get sendPhoto => 'Send Photo';
  @override
  String get camera => 'Camera';
  @override
  String get gallery => 'Gallery';
  @override
  String get noConnectedContacts => 'No referral contacts found.';
  @override
  String get inviteFriendsToChat => 'Invite friends using your referral code to start chatting!';
  @override
  String get photo => '[Photo]';

  // Donate
  @override
  String get donateToMember => 'Donate to Member';
  @override
  String get supportTeamMembers => 'Support Team Members';
  @override
  String get transferOrDonateMsg => 'Transfer or donate THB assets to your team members downline instantly.';
  @override
  String get donationDetails => 'Donation Details';
  @override
  String get memberEmailOrUserId => 'Member Email or User ID';
  @override
  String get amountThb => 'Amount (THB)';
  @override
  String get submitDonation => 'SUBMIT DONATION';
  @override
  String get transferSuccessful => 'Transfer Successful';
  @override
  String get successfullyDonated => 'Successfully donated';

  // Help Center
  @override
  String get howCanWeHelpYou => 'How can we help you?';
  @override
  String get liveChat => 'Live Chat';
  @override
  String get speakWithSupportTeam => 'Speak with our support team now';
  @override
  String get emailSupport => 'Email Support';
  @override
  String get sendUsMessageAnytime => 'Send us a message anytime';
  @override
  String get commonQuestions => 'Common Questions';
  @override
  String get howToWithdraw => '• How to withdraw funds?';
  @override
  String get whatAreVipLevels => '• What are VIP levels?';
  @override
  String get howToInviteFriends => '• How to invite friends?';

  // My Team
  @override
  String get teamStatistics => 'Team Statistics';
  @override
  String get totalTeamSize => 'Total Team Size';
  @override
  String get members => 'Members';
  @override
  String get directMembersLv1 => 'Direct Members (LV 1)';
  @override
  String get indirectMembersLv2 => 'Indirect Members (LV 2)';
  @override
  String get extendedMembersLv3 => 'Extended Members (LV 3)';

  // Add Funds
  @override
  String get scanQrOrCopyAddress => 'Scan QR Code or copy address to pay';
  @override
  String get noPaymentWalletSet => 'No payment wallet address set by admin yet.';
  @override
  String get walletAddressCopied => 'Wallet address copied!';
  @override
  String get paymentDetails => 'Payment Details';
  @override
  String get transactionHashId => 'Transaction Hash / ID';
  @override
  String get submitDeposit => 'SUBMIT DEPOSIT';
  @override
  String get requestSubmitted => 'Request Submitted';
  @override
  String get depositSentForApproval => 'Your deposit request has been sent for admin approval. Balance will be updated once verified.';

  // Transactions
  @override
  String get myHistory => 'My History';
  @override
  String get referralHistory => 'Referral History';
  @override
  String get noReferralActivityYet => 'No referral activity yet.';
  @override
  String get noTransactionsYet => 'No transactions yet.';

  // Admin Dashboard
  @override
  String get totalUsers => 'Total Users';
  @override
  String get pendingDeposits => 'Pending Deposits';
  @override
  String get pendingWithdrawals => 'Pending Withdrawals';
  @override
  String get userManagement => 'User Management';
  @override
  String get settings => 'Settings';
  @override
  String get requests => 'Requests';
}

/// Burmese Implementation
class BurmeseLanguage extends AppLanguage {
  @override
  String get languageCode => 'my';

  @override
  String get languageName => 'မြန်မာ (Burmese)';

  // Bottom Navigation
  @override
  String get home => 'ပင်မ';
  @override
  String get chat => 'စကားပြော';
  @override
  String get task => 'တာဝန်';
  @override
  String get vip => 'VIP';
  @override
  String get profit => 'အမြတ်';
  @override
  String get account => 'အကောင့်';

  // Common UI
  @override
  String get selectLanguage => 'ဘာသာစကား ရွေးချယ်ပါ';
  @override
  String get english => 'English';
  @override
  String get burmese => 'မြန်မာ (Burmese)';
  @override
  String get login => 'ဝင်ရောက်မည်';
  @override
  String get signUp => 'စာရင်းသွင်းမည်';
  @override
  String get logout => 'ထွက်မည်';
  @override
  String get cancel => 'မလုပ်တော့ပါ';
  @override
  String get save => 'သိမ်းဆည်းမည်';
  @override
  String get ok => 'အိုကေ';
  @override
  String get confirm => 'အတည်ပြုပါ';
  @override
  String get loading => 'ခဏစောင့်ပါ...';
  @override
  String get error => 'အမှားအယွင်း';
  @override
  String get success => 'အောင်မြင်ပါသည်';
  @override
  String get withdraw => 'ငွေထုတ်ရန်';
  @override
  String get balance => 'လက်ကျန်ငွေ';
  @override
  String get submit => 'ပေးပို့မည်';
  @override
  String get done => 'ပြီးပြီ';
  @override
  String get copy => 'ကူးယူမည်';
  @override
  String get search => 'ရှာဖွေရန်';
  @override
  String get send => 'ပေးပို့မည်';
  @override
  String get back => 'နောက်သို့';

  // Account
  @override
  String get userNotFound => 'အသုံးပြုသူ မရှိပါ';
  @override
  String get wealthCenter => 'Wealth Center';
  @override
  String get userIdCopied => 'အသုံးပြုသူ ID ကို ကူးယူပြီးပါပြီ';
  @override
  String get membershipLevel => 'အဖွဲ့ဝင်အဆင့်';
  @override
  String get totalBalance => 'စုစုပေါင်းလက်ကျန်';
  @override
  String get planProgress => 'လုပ်ငန်းတိုးတက်မှု';
  @override
  String get tasksDone => 'ခုပြီးပြီ';
  @override
  String get totalProfit => 'စုစုပေါင်းအမြတ်';
  @override
  String get addFunds => 'ငွေဖြည့်ရန်';
  @override
  String get transactions => 'ငွေလွှဲမှတ်တမ်း';
  @override
  String get myTeam => 'ကျွန်ုပ်အဖွဲ့';
  @override
  String get changeLanguage => 'ဘာသာစကားပြောင်းရန်';
  @override
  String get registerNow => 'ယခုစာရင်းသွင်းရန်';
  @override
  String get earnMore => 'ပိုမိုရရှိရန်';
  @override
  String get helpCenter => 'အကူအညီ';
  @override
  String get donate => 'လှူဒါန်းရန်';
  @override
  String get confirmLogout => 'ထွက်ရန် အတည်ပြုပါ';
  @override
  String get logoutConfirmMsg => 'အကောင့်မှ ထွက်ခွာရန် သေချာပါသလား?';
  @override
  String get withdrawSelected => 'ငွေထုတ်ရန် ရွေးချယ်ထားသည်';

  // Home
  @override
  String get adminControlPanel => 'အက်ဒမင် ထိန်းချုပ်ခန်း';
  @override
  String get adminSubTitle => 'အသုံးပြုသူများ၊ ငွေသွင်းမှုများနှင့် ဆက်တင်များကို စီမံရန် နှိပ်ပါ';
  @override
  String get operationalAnalytics => 'လုပ်ငန်းဆိုင်ရာ ခွဲခြမ်းစိတ်ဖြာမှု';
  @override
  String get portfolioBalance => 'ရင်းနှီးမြှုပ်နှံမှု လက်ကျန်ငွေ';
  @override
  String get incomeTiers => 'ဝင်ငွေအဆင့်များ';

  // Task & Reel
  @override
  String get planNotActive => 'အစီအစဉ်မရှိသေးပါ';
  @override
  String get unlockPlanToWatch => 'ဗီဒီယိုများကြည့်ရှုပြီး ဆုကြေးရရှိရန် ရင်းနှီးမြှုပ်နှံမှုအစီအစဉ်ကို ဖွင့်လှစ်ပါ။';
  @override
  String get noVideosAvailable => 'ဗီဒီယိုများမရှိသေးပါ။';
  @override
  String get dailyLimitReached => 'နေ့စဉ်ကန့်သတ်ချက် ပြည့်သွားပါပြီ။';
  @override
  String get noNewTasksAvailable => 'လုပ်ဆောင်ရန် တာဝန်သစ်မရှိပါ';
  @override
  String get completedAllTasksToday => 'ယနေ့အတွက် တာဝန်အားလုံး ပြီးဆုံးပါပြီ။ မနက်ဖြန် ပြန်လာခဲ့ပါ!';
  @override
  String get watchedAllVideos => 'ရှိသမျှ ဗီဒီယိုများအားလုံး ကြည့်ရှုပြီးပါပြီ။ ပြန်လည်ကြည့်ရှုနိုင်ပါသည်။';
  @override
  String get watchAgain => 'ပြန်လည်ကြည့်ရှုမည်';
  @override
  String get reviewModeNoRewards => 'ပြန်လည်ကြည့်ရှုခြင်း (ဆုကြေးမရှိ)';
  @override
  String get plan => 'အစီအစဉ်';
  @override
  String get progress => 'တိုးတက်မှု';
  @override
  String get exitReview => 'ပြန်ထွက်မည်';
  @override
  String get swipe => 'ပွတ်ဆွဲပါ';
  @override
  String get watchingInReviewMode => 'ဤဗီဒီယိုကို ပြန်လည်ကြည့်ရှုနေခြင်းဖြစ်သည်။';
  @override
  String get watchVideoFully => 'နေ့စဉ်လုပ်ငန်းပြီးမြောက်ရန် ဤဗီဒီယိုကို အပြည့်အဝ ကြည့်ရှုပါ။';
  @override
  String get completed => 'ပြီးမြောက်ပြီး';
  @override
  String get watching => 'ကြည့်ရှုနေသည်...';
  @override
  String get completeTask => 'လုပ်ငန်းပြီးမြောက်ရန်';
  @override
  String get taskCompletedSuccess => 'လုပ်ငန်းအောင်မြင်စွာပြီးဆုံးပါပြီ။ ရရှိငွေ -';

  // Investment
  @override
  String get planUnlocked => 'အစီအစဉ်ကို ဖွင့်လှစ်ပြီးပါပြီ။';
  @override
  String get planUnlockedMsg => 'သင်သည် အောင်မြင်စွာ အသက်သွင်းပြီးပါပြီ';
  @override
  String get investmentTiers => 'ရင်းနှီးမြှုပ်နှံမှုအဆင့်များ';
  @override
  String get noPlansAvailable => 'ရင်းနှီးမြှုပ်နှံမှု အစီအစဉ်များ မရှိသေးပါ။';
  @override
  String get errorLoadingPlans => 'အစီအစဉ်များ ရှာမတွေ့ပါ';
  @override
  String get activePortfolio => 'လက်ရှိ Portfolio';
  @override
  String get expiryDate => 'သက်တမ်းကုန်ဆုံးရက်';
  @override
  String get active => 'အသုံးပြုနေသည်';
  @override
  String get dailyTask => 'နေ့စဉ်တာဝန်';
  @override
  String get payPerTask => 'တာဝန်တစ်ခုနှုန်း';
  @override
  String get dailyRoi => 'နေ့စဉ်ရရှိငွေ';
  @override
  String get investmentAmount => 'ရင်းနှီးမြှုပ်နှံငွေ';
  @override
  String get unlock => 'ဖွင့်ရန်';

  // Profit Analytics
  @override
  String get profitAnalytics => 'အမြတ်ခွဲခြမ်းစိတ်ဖြာမှု';
  @override
  String get earningsSummary => 'ဝင်ငွေအကျဉ်းချုပ်';
  @override
  String get taskStatistics => 'လုပ်ငန်းစာရင်းအင်း';
  @override
  String get totalEarnings => 'စုစုပေါင်းဝင်ငွေ';
  @override
  String get yesterday => 'မနေ့က';
  @override
  String get today => 'ဒီနေ့';
  @override
  String get thisWeek => 'ဒီအပတ်';
  @override
  String get thisMonth => 'ယခုလ';
  @override
  String get offerEarning => 'ကမ်းလှမ်းမှုဝင်ငွေ';
  @override
  String get referralRewards => 'ရည်ညွှန်းဆုကြေး';
  @override
  String get taskRewards => 'လုပ်ငန်းဆုကြေး';
  @override
  String get completedToday => 'ယနေ့ပြီးစီးမှု';
  @override
  String get remainingToday => 'ယနေ့ကျန်ရှိမှု';

  // Auth
  @override
  String get welcomeBack => 'ကြိုဆိုပါသည်';
  @override
  String get username => 'အသုံးပြုသူအမည်';
  @override
  String get emailAddress => 'အီးမေးလ်လိပ်စာ';
  @override
  String get password => 'စကားဝှက်';
  @override
  String get confirmPassword => 'စကားဝှက် အတည်ပြုပါ';
  @override
  String get referralCode => 'ရည်ညွှန်းကုဒ်';
  @override
  String get referralOptional => 'ရည်ညွှန်းကုဒ် (ရှိလျှင်)';
  @override
  String get forgotPassword => 'စကားဝှက် မေ့နေပါသလား?';
  @override
  String get resetPassword => 'စကားဝှက် ပြန်လည်သတ်မှတ်ပါ';
  @override
  String get sendLink => 'လင့်ခ် ပို့မည်';
  @override
  String get enterEmail => 'အီးမေးလ် ထည့်ပါ';
  @override
  String get enterValidEmail => 'မှန်ကန်သော အီးမေးလ် ထည့်ပါ';
  @override
  String get enterPassword => 'စကားဝှက် ထည့်ပါ';
  @override
  String get minimum6Chars => 'အနည်းဆုံး စာလုံး ၆ လုံး ထည့်ပါ';
  @override
  String get enterUsername => 'အသုံးပြုသူအမည် ထည့်ပါ';
  @override
  String get passwordsDoNotMatch => 'စကားဝှက်များ မကိုက်ညီပါ';
  @override
  String get signUpSuccess => 'စာရင်းသွင်းခြင်း အောင်မြင်ပါသည်';
  @override
  String get alreadyHaveAccount => 'အကောင့်ရှိပြီးသားလား?';
  @override
  String get dontHaveAccount => 'အကောင့်မရှိသေးဘူးလား?';
  @override
  String get registerForWealthFlow => 'Wealth Flow အတွက် စာရင်းသွင်းပါ';
  @override
  String get loginToWealthFlow => 'Wealth Flow သို့ ဝင်ရောက်ပါ';

  // Referral
  @override
  String get referralProgram => 'ရည်ညွှန်းအစီအစဉ်';
  @override
  String get enterReferralCodeMsg => 'ပိုမိုဝင်ငွေရရှိရန် နှင့် အဖွဲ့ဝင်များနှင့် ချိတ်ဆက်ရန် ရည်ညွှန်းကုဒ်ထည့်ပါ။';
  @override
  String get activeReferrer => 'လက်ရှိ ရည်ညွှန်းသူ';
  @override
  String get enterReferralCode => 'ရည်ညွှန်းကုဒ် ထည့်ပါ';
  @override
  String get pleaseEnterReferralCode => 'ကျေးဇူးပြု၍ ရည်ညွှန်းကုဒ်ထည့်ပါ';
  @override
  String get referralAddedSuccess => 'ရည်ညွှန်းကုဒ် အောင်မြင်စွာ ထည့်သွင်းပြီးပါပြီ!';
  @override
  String get saveCode => 'ကုဒ်သိမ်းဆည်းမည်';

  // Chat
  @override
  String get adminSupport => 'အက်ဒမင် အကူအညီ';
  @override
  String get typeMessage => 'စာရိုက်ပါ...';
  @override
  String get noMessagesYet => 'မက်ဆေ့ခ်ျများ မရှိသေးပါ';
  @override
  String get connectedTeam => 'ရည်ညွှန်းအဖွဲ့ စကားပြောရန်';
  @override
  String get online => 'အွန်လိုင်း';
  @override
  String get offline => 'အော့ဖ်လိုင်း';
  @override
  String get lastSeen => 'နောက်ဆုံးတွေ့ခဲ့ချိန်';
  @override
  String get uplineReferrer => 'ရည်ညွှန်းသူ (Upline)';
  @override
  String get downlineMember => 'အဖွဲ့ဝင် (Downline)';
  @override
  String get sendPhoto => 'ဓာတ်ပုံ ပို့မည်';
  @override
  String get camera => 'ကင်မရာ';
  @override
  String get gallery => 'ဓာတ်ပုံပြခန်း';
  @override
  String get noConnectedContacts => 'ရည်ညွှန်းအဖွဲ့ဝင်များ မရှိသေးပါ။';
  @override
  String get inviteFriendsToChat => 'စကားပြောရန် သင့်ရည်ညွှန်းကုဒ်ဖြင့် မိတ်ဆွေများကို ဖိတ်ခေါ်ပါ။';
  @override
  String get photo => '[ဓာတ်ပုံ]';

  // Donate
  @override
  String get donateToMember => 'အဖွဲ့ဝင်ထံ လှူဒါန်းရန်';
  @override
  String get supportTeamMembers => 'အဖွဲ့ဝင်များကို ကူညီပါ';
  @override
  String get transferOrDonateMsg => 'သင့်အဖွဲ့ဝင်များထံ THB လက်ကျန်ငွေ ချက်ချင်း လွှဲပြောင်း သို့မဟုတ် လှူဒါန်းပါ။';
  @override
  String get donationDetails => 'လှူဒါန်းမှု အသေးစိတ်';
  @override
  String get memberEmailOrUserId => 'အဖွဲ့ဝင် အီးမေးလ် သို့မဟုတ် ID';
  @override
  String get amountThb => 'ပမာဏ (THB)';
  @override
  String get submitDonation => 'လှူဒါန်းမည်';
  @override
  String get transferSuccessful => 'လွှဲပြောင်းမှု အောင်မြင်ပါသည်';
  @override
  String get successfullyDonated => 'အောင်မြင်စွာ လှူဒါန်းပြီးပါပြီ';

  // Help Center
  @override
  String get howCanWeHelpYou => 'ဘယ်လိုကူညီပေးရမလဲ?';
  @override
  String get liveChat => 'တိုက်ရိုက် စကားပြောရန်';
  @override
  String get speakWithSupportTeam => 'အကူအညီပေးရေးအဖွဲ့နှင့် စကားပြောပါ';
  @override
  String get emailSupport => 'အီးမေးလ်မှ ကူညီပါ';
  @override
  String get sendUsMessageAnytime => 'ကြိုက်နှစ်သက်ရာအချိန်တွင် မက်ဆေ့ခ်ျပို့ပါ';
  @override
  String get commonQuestions => 'မကြာခဏ မေးလေ့ရှိသော မေးခွန်းများ';
  @override
  String get howToWithdraw => '• ငွေထုတ်ယူနည်း';
  @override
  String get whatAreVipLevels => '• VIP အဆင့်များအကြောင်း';
  @override
  String get howToInviteFriends => '• မိတ်ဆွေများကို ဖိတ်ခေါ်နည်း';

  // My Team
  @override
  String get teamStatistics => 'အဖွဲ့ဆိုင်ရာ စာရင်းအင်း';
  @override
  String get totalTeamSize => 'စုစုပေါင်း အဖွဲ့ဝင် အရေအတွက်';
  @override
  String get members => 'ဦး';
  @override
  String get directMembersLv1 => 'တိုက်ရိုက် အဖွဲ့ဝင်များ (LV 1)';
  @override
  String get indirectMembersLv2 => 'ဒုတိယအဆင့် အဖွဲ့ဝင်များ (LV 2)';
  @override
  String get extendedMembersLv3 => 'တတိယအဆင့် အဖွဲ့ဝင်များ (LV 3)';

  // Add Funds
  @override
  String get scanQrOrCopyAddress => 'QR ကုဒ်ဖတ်ပါ သို့မဟုတ် လိပ်စာကို ကူးယူပါ';
  @override
  String get noPaymentWalletSet => 'အက်ဒမင်မှ ငွေလက်ခံမည့် လိပ်စာ မသတ်မှတ်ရသေးပါ။';
  @override
  String get walletAddressCopied => 'Wallet လိပ်စာ ကူးယူပြီးပါပြီ!';
  @override
  String get paymentDetails => 'ငွေပေးချေမှု အသေးစိတ်';
  @override
  String get transactionHashId => 'ငွေလွှဲ အမှတ် / ID';
  @override
  String get submitDeposit => 'ငွေသွင်းရန် ပေးပို့မည်';
  @override
  String get requestSubmitted => 'ပေးပို့ပြီးပါပြီ';
  @override
  String get depositSentForApproval => 'သင့်ငွေသွင်းတောင်းဆိုမှုကို အက်ဒမင် အတည်ပြုရန် ပေးပို့ပြီးပါပြီ။ စစ်ဆေးပြီးပါက လက်ကျန်ငွေ တိုးလာပါမည်။';

  // Transactions
  @override
  String get myHistory => 'ကျွန်ုပ်၏ မှတ်တမ်း';
  @override
  String get referralHistory => 'ရည်ညွှန်းမှု မှတ်တမ်း';
  @override
  String get noReferralActivityYet => 'ရည်ညွှန်းမှု လှုပ်ရှားမှု မရှိသေးပါ။';
  @override
  String get noTransactionsYet => 'ငွေလွှဲမှတ်တမ်း မရှိသေးပါ။';

  // Admin Dashboard
  @override
  String get totalUsers => 'စုစုပေါင်း အသုံးပြုသူ';
  @override
  String get pendingDeposits => 'စောင့်ဆိုင်းဆဲ ငွေသွင်းမှုများ';
  @override
  String get pendingWithdrawals => 'စောင့်ဆိုင်းဆဲ ငွေထုတ်မှုများ';
  @override
  String get userManagement => 'အသုံးပြုသူ စီမံခန့်ခွဲမှု';
  @override
  String get settings => 'ဆက်တင်များ';
  @override
  String get requests => 'တောင်းဆိုမှုများ';
}

/// Centralized Manager and Riverpod Provider for App Localization
class AppLocalization {
  static final EnglishLanguage _english = EnglishLanguage();
  static final BurmeseLanguage _burmese = BurmeseLanguage();

  /// Gets [AppLanguage] instance for the given language code ('en' or 'my')
  static AppLanguage fromCode(String? code) {
    if (code == 'my') return _burmese;
    return _english;
  }
}

/// App Language StateNotifier to allow dynamic language changes across the app
class AppLanguageNotifier extends StateNotifier<AppLanguage> {
  AppLanguageNotifier(String initialCode)
      : super(AppLocalization.fromCode(initialCode));

  Future<void> changeLanguage(String code) async {
    final newLanguage = AppLocalization.fromCode(code);
    state = newLanguage;
    await LocalStorageService.saveLanguage(code);

    final uid = await LocalStorageService.getUserUid();
    if (uid != null) {
      await AuthService().updateUserLanguage(uid, code);
    }
  }
}

/// Riverpod provider for active [AppLanguage]
final appLanguageProvider =
    StateNotifierProvider<AppLanguageNotifier, AppLanguage>((ref) {
  return AppLanguageNotifier('en');
});
