
class ErrorMessage {
  final int code;
  final String message;

  ErrorMessage({this.code, this.message});

  factory ErrorMessage.fromJson(Map<String, dynamic> json) =>
      ErrorMessage(
        code: json["code"] as int,
        message: json["message"] as String
      );
}
class ObpResponse {
  final int code;
  final String message;
  final Map<String, dynamic> data;

  ObpResponse({this.code, this.message, this.data});

  bool isSuccess() => 200 <= code && code <= 299;
}

class User {
  final String user_id;
  final String email;
  final String provider_id;
  final String provider;
  final String username;
  final List<Entitlement> entitlements;
  String photoUrl;

  User(
      {this.user_id,
      this.email,
      this.provider_id,
      this.provider,
      this.username,
      this.entitlements});

  factory User.fromJson(Map<String, dynamic> json) {
    List<Entitlement> entitlements = json["entitlements"]["list"]
          .map<Entitlement>((it) => Entitlement.fromJson(it))
          .toList();

    return User(
      user_id: json["user_id"] as String,
      email: json["email"] as String,
      provider_id: json["provider_id"] as String,
      username: json["username"] as String,
      entitlements: entitlements,
    );
  }
}

class Entitlement {
  final String entitlement_id;
  final String role_name;
  final String bank_id;

  Entitlement({this.entitlement_id, this.role_name, this.bank_id});

  factory Entitlement.fromJson(Map<String, dynamic> json) => Entitlement(
      entitlement_id: json["entitlement_id"] as String,
      role_name: json["role_name"] as String,
      bank_id: json["bank_id"] as String);
}

class Bank {
  final String id;
  final String short_name;
  final String full_name;
  final String logo;
  final String website;
  final List<BankRouting> bank_routings;

  Bank(
      {this.id,
      this.short_name,
      this.full_name,
      this.logo,
      this.website,
      this.bank_routings});

  factory Bank.fromJson(Map<String, dynamic> json){
    var bankRoutings = json["bank_routings"] as List<dynamic>;
    var bankRoutingList = bankRoutings.map<BankRouting>((it) => BankRouting.fromJson(it)).toList();
    return Bank(
      id: json["id"] as String,
      short_name: json["short_name"] as String,
      full_name: json["full_name"] as String,
      logo: json["logo"] as String,
      website: json["website"],
      bank_routings: bankRoutingList,
    );
  }
}

class BankRouting {
  final String scheme;
  final String address;

  BankRouting({this.scheme, this.address});

  factory BankRouting.fromJson(Map<String, dynamic> json) =>
      BankRouting(
        scheme: json["scheme"] as String,
        address: json["address"] as String,
      );
}

class Customer {
  final String bank_id;
  final String customer_id;
  final String customer_number;
  final String legal_name;
  final String mobile_phone_number;
  final String email;

  final FaceImage face_image;

  final String date_of_birth;
  final String relationship_status;
  final int dependants;
  final List<String> dob_of_dependants;

  final CreditRating credit_rating;

  final CreditLimit credit_limit;

  final String highest_education_attained;
  final String employment_status;
  final bool kyc_status;
  final String last_ok_date;
  final String title;
  final String branch_id;
  final String name_suffix;

  Customer(
      {this.bank_id,
      this.customer_id,
      this.customer_number,
      this.legal_name,
      this.mobile_phone_number,
      this.email,
      this.face_image,
      this.date_of_birth,
      this.relationship_status,
      this.dependants,
      this.dob_of_dependants,
      this.credit_rating,
      this.credit_limit,
      this.highest_education_attained,
      this.employment_status,
      this.kyc_status,
      this.last_ok_date,
      this.title,
      this.branch_id,
      this.name_suffix});

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
      bank_id: json["bank_id"] as String,
      customer_id: json["customer_id"] as String,
      customer_number: json["customer_number"] as String,
      legal_name: json["legal_name"] as String,
      mobile_phone_number: json["mobile_phone_number"] as String,
      email: json["email"] as String,
      face_image: FaceImage.fromJson(json["face_image"]),
      date_of_birth: json["date_of_birth"] as String,
      relationship_status: json["relationship_status"] as String,
      dependants: json["dependants"] as int,
      dob_of_dependants: json["dob_of_dependants"]
          .map<String>((it) => (it as String))
          .toList(),
      credit_rating: CreditRating.fromJson(json["credit_rating"]),
      credit_limit: CreditLimit.fromJson(json["credit_limit"]),
      highest_education_attained: json["highest_education_attained"] as String,
      employment_status: json["employment_status"] as String,
      kyc_status: json["kyc_status"] as bool,
      last_ok_date: json["last_ok_date"] as String,
      title: json["title"] as String,
      branch_id: json["branch_id"] as String,
      name_suffix: json["name_suffix"] as String);

  Map<String, dynamic> toJson() => {
    "bank_id": this.bank_id,
    "customer_id": this.customer_id,
    "customer_number": this.customer_number,
    "legal_name": this.legal_name,
    "mobile_phone_number": this.mobile_phone_number,
    "email": this.email,
    "face_image":{
      "url": this.face_image?.url,
      "date": this.face_image?.date
    },
    "date_of_birth": this.date_of_birth,
    "relationship_status": this.relationship_status,
    "dependants": this.dependants,
    "dob_of_dependants": this.dob_of_dependants,

    "credit_rating":{
      "rating": this.credit_rating?.rating,
      "source": this.credit_rating?.source
    },
    "credit_limit":{
      "currency": this.credit_limit?.currency,
      "amount": this.credit_limit?.amount
    },
    "highest_education_attained": this.highest_education_attained,
    "employment_status": this.employment_status,
    "kyc_status": this.kyc_status,
    "last_ok_date": this.last_ok_date,
    "title": this.title,
    "branch_id": this.branch_id,
    "name_suffix": this.name_suffix
  };
}

class FaceImage {
  final String url; // "face_image"
  final String date; // "face_image"

  FaceImage({this.url, this.date});

  factory FaceImage.fromJson(Map<String, dynamic> json) => json == null
      ? null
      : FaceImage(url: json["url"] as String, date: json["date"] as String);
}

class CreditRating {
  final String rating; // "credit_rating"
  final String source; // "credit_rating"

  CreditRating({this.rating, this.source});

  factory CreditRating.fromJson(Map<String, dynamic> json) => json == null
      ? null
      : CreditRating(
          rating: json["rating"] as String, source: json["source"] as String);
}

class CreditLimit {
  final String currency; // "credit_limit"
  final String amount; // "credit_limit"

  CreditLimit({this.currency, this.amount});

  factory CreditLimit.fromJson(Map<String, dynamic> json) => json == null
      ? null
      : CreditLimit(
          currency: json["currency"] as String,
          amount: json["amount"] as String);
}
