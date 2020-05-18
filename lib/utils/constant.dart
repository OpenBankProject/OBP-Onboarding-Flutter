
class Constants {
  Constants._privateConstructor();

  static final Constants instance = Constants._privateConstructor();


//  static final String _baseUrl="http://baishuang.51vip.biz";
  static final String _baseUrl="http://baishuang.space:22222";
  final String directLoginUrl="$_baseUrl/my/logins/direct";
  final String currentUserUrl="$_baseUrl/obp/v4.0.0/users/current";
  final String getBanksUrl = '$_baseUrl/obp/v4.0.0/banks';
  final String requestRoleUrl = '$_baseUrl/obp/v4.0.0/entitlement-requests';
  final String createCustomerUrl ='$_baseUrl/obp/v4.0.0/banks/BANK_ID/customers';
  final String createUserCustomerLinkUrl ='$_baseUrl/obp/v4.0.0/banks/BANK_ID/user_customer_links';
  final String createAuthContextUpdateUrl ='$_baseUrl/obp/v4.0.0/banks/BANK_ID/users/current/auth-context-updates/SCA_METHOD';
  final String answerAuthContextUpdateChallengeUrl ='$_baseUrl/obp/v4.0.0/users/current/auth-context-updates/AUTH_CONTEXT_UPDATE_ID/challenge';
  final String getCurrentUserLinkedCustomerUrl ='$_baseUrl/obp/v4.0.0/users/current/customers';

  final String consumerKey="yp5tgl0thzjj1jk0sobqljpxyo514dsjvxoe1ngy";
  // http connect timeout milliseconds.
  final int httpConnectTimeout = 30000;
}

Constants constants = Constants.instance;


