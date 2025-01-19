// To parse this JSON data, do
//
//     final payoutModel = payoutModelFromJson(jsonString);

import 'dart:convert';

PayoutModel payoutModelFromJson(String str) => PayoutModel.fromJson(json.decode(str));

String payoutModelToJson(PayoutModel data) => json.encode(data.toJson());

class PayoutModel {
  dynamic status;
  PayoutData? message;

  PayoutModel({
    this.status,
    this.message,
  });

  factory PayoutModel.fromJson(Map<String, dynamic> json) => PayoutModel(
        status: json["status"],
        message: json["message"] == null ? null : PayoutData.fromJson(json["message"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message?.toJson(),
      };
}

class PayoutData {
  dynamic balance;
  dynamic depositAmount;
  dynamic interestAmount;
  dynamic interestBalance;
  List<Gateway>? gateways;
  List<dynamic>? openDaysList;
  dynamic today;
  dynamic isOffDay;

  PayoutData({
    this.balance,
    this.depositAmount,
    this.interestAmount,
    this.interestBalance,
    this.gateways,
    this.openDaysList,
    this.today,
    this.isOffDay,
  });

  factory PayoutData.fromJson(Map<String, dynamic> json) => PayoutData(
        balance: json["balance"],
        depositAmount: json["depositAmount"],
        interestAmount: json["interestAmount"],
        interestBalance: json["interest_balance"],
        gateways: json["gateways"] == null ? [] : List<Gateway>.from(json["gateways"]!.map((x) => Gateway.fromJson(x))),
        openDaysList: json["openDaysList"] == null ? [] : List<String>.from(json["openDaysList"]!.map((x) => x)),
        today: json["today"],
        isOffDay: json["isOffDay"],
      );

  Map<String, dynamic> toJson() => {
        "balance": balance,
        "depositAmount": depositAmount,
        "interestAmount": interestAmount,
        "interest_balance": interestBalance,
        "gateways": gateways == null ? [] : List<dynamic>.from(gateways!.map((x) => x.toJson())),
        "openDaysList": openDaysList == null ? [] : List<dynamic>.from(openDaysList!.map((x) => x)),
        "today": today,
        "isOffDay": isOffDay,
      };
}

class Gateway {
  dynamic id;
  dynamic code;
  dynamic name;
  dynamic image;
  dynamic sortBy;
  dynamic parameters;
  dynamic currencies;
  ExtraParameters? extraParameters;
  List<dynamic>? supportedCurrency;
  List<dynamic>? banks;
  List<ReceivableCurrencies>? receivableCurrencies;
  dynamic description;
  dynamic currencyType;
  dynamic isSandbox;
  dynamic environment;
  dynamic isManual;
  dynamic note;
  dynamic createdAt;
  dynamic updatedAt;

  Gateway(
      {this.id,
      this.code,
      this.name,
      this.image,
      this.sortBy,
      this.parameters,
      this.currencies,
      this.extraParameters,
      this.supportedCurrency,
      this.banks,
      this.receivableCurrencies,
      this.description,
      this.currencyType,
      this.isSandbox,
      this.environment,
      this.isManual,
      this.note,
      this.createdAt,
      this.updatedAt});

  Gateway.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    image = json['logo'];
    sortBy = json['sort_by'];
    parameters = json['inputForm'] ?? null;
    currencies = json['currencies'] ?? null;
    extraParameters = json['extra_parameters'] != null ? new ExtraParameters.fromJson(json['extra_parameters']) : null;
    supportedCurrency = json['supported_currency'].cast<String>();
    banks = json['banks'] ?? null;
    if (json['payout_currencies'] != null) {
      receivableCurrencies = <ReceivableCurrencies>[];
      json['payout_currencies'].forEach((v) {
        receivableCurrencies!.add(new ReceivableCurrencies.fromJson(v));
      });
    }
    description = json['description'];
    currencyType = json['currency_type'];
    isSandbox = json['is_sandbox'];
    environment = json['environment'];
    isManual = json['is_manual'];
    note = json['note'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name'] = this.name;
    data['logo'] = this.image;
    data['sort_by'] = this.sortBy;
    if (this.parameters != null) {
      data['inputForm'] = this.parameters!.toJson();
    }
    if (this.currencies != null) {
      data['currencies'] = this.currencies!.toJson();
    }
    if (this.extraParameters != null) {
      data['extra_parameters'] = this.extraParameters!.toJson();
    }
    data['supported_currency'] = this.supportedCurrency;
    data['banks'] = this.banks;
    if (this.receivableCurrencies != null) {
      data['payout_currencies'] = this.receivableCurrencies!.map((v) => v.toJson()).toList();
    }
    data['description'] = this.description;
    data['currency_type'] = this.currencyType;
    data['is_sandbox'] = this.isSandbox;
    data['environment'] = this.environment;
    data['is_manual'] = this.isManual;
    data['note'] = this.note;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class ReceivableCurrencies {
  String? name;
  String? currencySymbol;
  String? conversionRate;
  String? minLimit;
  String? maxLimit;
  String? percentageCharge;
  String? fixedCharge;
  String? currency;

  ReceivableCurrencies(
      {this.name,
      this.currencySymbol,
      this.conversionRate,
      this.minLimit,
      this.maxLimit,
      this.percentageCharge,
      this.fixedCharge,
      this.currency});

  ReceivableCurrencies.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    currencySymbol = json['currency_symbol'];
    conversionRate = json['conversion_rate'];
    minLimit = json['min_limit'];
    maxLimit = json['max_limit'];
    percentageCharge = json['percentage_charge'];
    fixedCharge = json['fixed_charge'];
    currency = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['currency_symbol'] = this.currencySymbol;
    data['conversion_rate'] = this.conversionRate;
    data['min_limit'] = this.minLimit;
    data['max_limit'] = this.maxLimit;
    data['percentage_charge'] = this.percentageCharge;
    data['fixed_charge'] = this.fixedCharge;
    data['currency'] = this.currency;
    return data;
  }
}

class ExtraParameters {
  dynamic cron;
  dynamic ipnUrl;
  dynamic webhook;
  dynamic paymentNotificationUrl;
  dynamic finishRedirectUrl;
  dynamic unfinishRedirectUrl;
  dynamic errorRedirectUrl;
  dynamic callback;
  dynamic status;
  dynamic approvedUrl;

  ExtraParameters({
    this.cron,
    this.ipnUrl,
    this.webhook,
    this.paymentNotificationUrl,
    this.finishRedirectUrl,
    this.unfinishRedirectUrl,
    this.errorRedirectUrl,
    this.callback,
    this.status,
    this.approvedUrl,
  });

  factory ExtraParameters.fromJson(Map<String, dynamic> json) => ExtraParameters(
        cron: json["cron"],
        ipnUrl: json["ipn_url"],
        webhook: json["webhook"],
        paymentNotificationUrl: json["payment_notification_url"],
        finishRedirectUrl: json["finish redirect_url"],
        unfinishRedirectUrl: json["unfinish redirect_url"],
        errorRedirectUrl: json["error redirect_url"],
        callback: json["callback"],
        status: json["status"],
        approvedUrl: json["approved_url"],
      );

  Map<String, dynamic> toJson() => {
        "cron": cron,
        "ipn_url": ipnUrl,
        "webhook": webhook,
        "payment_notification_url": paymentNotificationUrl,
        "finish redirect_url": finishRedirectUrl,
        "unfinish redirect_url": unfinishRedirectUrl,
        "error redirect_url": errorRedirectUrl,
        "callback": callback,
        "status": status,
        "approved_url": approvedUrl,
      };
}

class AccountNumber {
  dynamic fieldName;
  dynamic fieldLevel;
  dynamic type;
  dynamic validation;

  AccountNumber({
    this.fieldName,
    this.fieldLevel,
    this.type,
    this.validation,
  });

  factory AccountNumber.fromJson(Map<String, dynamic> json) => AccountNumber(
        fieldName: json["field_name"],
        fieldLevel: json["field_level"],
        type: json["type"],
        validation: json["validation"],
      );

  Map<String, dynamic> toJson() => {
        "field_name": fieldName,
        "field_level": fieldLevel,
        "type": type,
        "validation": validation,
      };
}


// class Gateway {
//   dynamic id;
//   dynamic name;
//   dynamic image;
//   dynamic currencySymbol;
//   dynamic currency;
//   dynamic minimumAmount;
//   dynamic maximumAmount;
//   dynamic fixedCharge;
//   dynamic percentCharge;
//   dynamic dynamicForm;
//   dynamic bankName;
//   dynamic supportedCurrency;
//   dynamic convertRate;
//   dynamic isAutomatic;

//   Gateway({
//     this.id,
//     this.name,
//     this.image,
//     this.currencySymbol,
//     this.currency,
//     this.minimumAmount,
//     this.maximumAmount,
//     this.fixedCharge,
//     this.percentCharge,
//     this.dynamicForm,
//     this.bankName,
//     this.supportedCurrency,
//     this.convertRate,
//     this.isAutomatic,
//   });

//   factory Gateway.fromJson(Map<String, dynamic> json) => Gateway(
//         id: json["id"],
//         name: json["name"],
//         image: json["logo"],
//         currencySymbol: json["currencySymbol"],
//         currency: json["currency"],
//         minimumAmount: json["minimumAmount"],
//         maximumAmount: json["maximumAmount"],
//         fixedCharge: json["fixedCharge"],
//         percentCharge: json["percentCharge"],
//         dynamicForm: json["dynamicForm"],
//         bankName: json["bankName"],
//         supportedCurrency: json["supportedCurrency"],
//         convertRate: json["convertRate"],
//         isAutomatic: json["isAutomatic"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//         "logo": image,
//         "currencySymbol": currencySymbol,
//         "currency": currency,
//         "minimumAmount": minimumAmount,
//         "maximumAmount": maximumAmount,
//         "fixedCharge": fixedCharge,
//         "percentCharge": percentCharge,
//         "dynamicForm": dynamicForm,
//         "bankName": bankName,
//         "supportedCurrency": supportedCurrency,
//         "convertRate": convertRate,
//         "isAutomatic": isAutomatic,
//       };
// }

// class ConvertRateClass {
//   dynamic usd;
//   dynamic kes;
//   dynamic ghs;
//   dynamic ngn;
//   dynamic gbp;
//   dynamic eur;
//   dynamic tzs;
//   dynamic inr;
//   dynamic zar;
//   dynamic bnb;
//   dynamic btc;
//   dynamic xrp;
//   dynamic eth;
//   dynamic eth2;
//   dynamic usdt;
//   dynamic bch;
//   dynamic ltc;
//   dynamic xmr;
//   dynamic ton;
//   dynamic aud;
//   dynamic brl;
//   dynamic cad;
//   dynamic czk;
//   dynamic dkk;
//   dynamic hkd;
//   dynamic huf;
//   dynamic ils;
//   dynamic jpy;
//   dynamic myr;
//   dynamic mxn;
//   dynamic twd;
//   dynamic nzd;
//   dynamic nok;
//   dynamic php;
//   dynamic pln;
//   dynamic rub;
//   dynamic sgd;
//   dynamic sek;
//   dynamic chf;
//   dynamic thb;

//   ConvertRateClass({
//     this.usd,
//     this.kes,
//     this.ghs,
//     this.ngn,
//     this.gbp,
//     this.eur,
//     this.tzs,
//     this.inr,
//     this.zar,
//     this.bnb,
//     this.btc,
//     this.xrp,
//     this.eth,
//     this.eth2,
//     this.usdt,
//     this.bch,
//     this.ltc,
//     this.xmr,
//     this.ton,
//     this.aud,
//     this.brl,
//     this.cad,
//     this.czk,
//     this.dkk,
//     this.hkd,
//     this.huf,
//     this.ils,
//     this.jpy,
//     this.myr,
//     this.mxn,
//     this.twd,
//     this.nzd,
//     this.nok,
//     this.php,
//     this.pln,
//     this.rub,
//     this.sgd,
//     this.sek,
//     this.chf,
//     this.thb,
//   });

//   factory ConvertRateClass.fromJson(Map<String, dynamic> json) => ConvertRateClass(
//         usd: json["USD"],
//         kes: json["KES"],
//         ghs: json["GHS"],
//         ngn: json["NGN"],
//         gbp: json["GBP"],
//         eur: json["EUR"],
//         tzs: json["TZS"],
//         inr: json["INR"],
//         zar: json["ZAR"],
//         bnb: json["BNB"],
//         btc: json["BTC"],
//         xrp: json["XRP"],
//         eth: json["ETH"],
//         eth2: json["ETH2"],
//         usdt: json["USDT"],
//         bch: json["BCH"],
//         ltc: json["LTC"],
//         xmr: json["XMR"],
//         ton: json["TON"],
//         aud: json["AUD"],
//         brl: json["BRL"],
//         cad: json["CAD"],
//         czk: json["CZK"],
//         dkk: json["DKK"],
//         hkd: json["HKD"],
//         huf: json["HUF"],
//         ils: json["ILS"],
//         jpy: json["JPY"],
//         myr: json["MYR"],
//         mxn: json["MXN"],
//         twd: json["TWD"],
//         nzd: json["NZD"],
//         nok: json["NOK"],
//         php: json["PHP"],
//         pln: json["PLN"],
//         rub: json["RUB"],
//         sgd: json["SGD"],
//         sek: json["SEK"],
//         chf: json["CHF"],
//         thb: json["THB"],
//       );

//   Map<String, dynamic> toJson() => {
//         "USD": usd,
//         "KES": kes,
//         "GHS": ghs,
//         "NGN": ngn,
//         "GBP": gbp,
//         "EUR": eur,
//         "TZS": tzs,
//         "INR": inr,
//         "ZAR": zar,
//         "BNB": bnb,
//         "BTC": btc,
//         "XRP": xrp,
//         "ETH": eth,
//         "ETH2": eth2,
//         "USDT": usdt,
//         "BCH": bch,
//         "LTC": ltc,
//         "XMR": xmr,
//         "TON": ton,
//         "AUD": aud,
//         "BRL": brl,
//         "CAD": cad,
//         "CZK": czk,
//         "DKK": dkk,
//         "HKD": hkd,
//         "HUF": huf,
//         "ILS": ils,
//         "JPY": jpy,
//         "MYR": myr,
//         "MXN": mxn,
//         "TWD": twd,
//         "NZD": nzd,
//         "NOK": nok,
//         "PHP": php,
//         "PLN": pln,
//         "RUB": rub,
//         "SGD": sgd,
//         "SEK": sek,
//         "CHF": chf,
//         "THB": thb,
//       };
// }

// class DynamicFormClass {
//   BankName? email;
//   BankName? nidNumber;
//   BankName? passportNumber;
//   BankName? mazid;
//   BankName? bankName;
//   BankName? transactionProve;
//   BankName? yourAddress;
//   BankName? bayazid;
//   AccountNumber? name;
//   AccountNumber? dynamicFormEmail;
//   AccountNumber? ifsc;
//   AccountNumber? accountNumber;
//   AccountNumber? cryptoAddress;
//   AccountNumber? receiver;
//   AccountNumber? network;
//   AccountNumber? address;

//   DynamicFormClass({
//     this.email,
//     this.nidNumber,
//     this.passportNumber,
//     this.mazid,
//     this.bankName,
//     this.transactionProve,
//     this.yourAddress,
//     this.bayazid,
//     this.name,
//     this.dynamicFormEmail,
//     this.ifsc,
//     this.accountNumber,
//     this.cryptoAddress,
//     this.receiver,
//     this.network,
//     this.address,
//   });

//   factory DynamicFormClass.fromJson(Map<String, dynamic> json) => DynamicFormClass(
//         email: json["Email"] == null ? null : BankName.fromJson(json["Email"]),
//         nidNumber: json["NIDNumber"] == null ? null : BankName.fromJson(json["NIDNumber"]),
//         passportNumber: json["PassportNumber"] == null ? null : BankName.fromJson(json["PassportNumber"]),
//         mazid: json["Mazid"] == null ? null : BankName.fromJson(json["Mazid"]),
//         bankName: json["BankName"] == null ? null : BankName.fromJson(json["BankName"]),
//         transactionProve: json["TransactionProve"] == null ? null : BankName.fromJson(json["TransactionProve"]),
//         yourAddress: json["YourAddress"] == null ? null : BankName.fromJson(json["YourAddress"]),
//         bayazid: json["Bayazid"] == null ? null : BankName.fromJson(json["Bayazid"]),
//         name: json["name"] == null ? null : AccountNumber.fromJson(json["name"]),
//         dynamicFormEmail: json["email"] == null ? null : AccountNumber.fromJson(json["email"]),
//         ifsc: json["ifsc"] == null ? null : AccountNumber.fromJson(json["ifsc"]),
//         accountNumber: json["account_number"] == null ? null : AccountNumber.fromJson(json["account_number"]),
//         cryptoAddress: json["crypto_address"] == null ? null : AccountNumber.fromJson(json["crypto_address"]),
//         receiver: json["receiver"] == null ? null : AccountNumber.fromJson(json["receiver"]),
//         network: json["network"] == null ? null : AccountNumber.fromJson(json["network"]),
//         address: json["address"] == null ? null : AccountNumber.fromJson(json["address"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "Email": email?.toJson(),
//         "NIDNumber": nidNumber?.toJson(),
//         "PassportNumber": passportNumber?.toJson(),
//         "Mazid": mazid?.toJson(),
//         "BankName": bankName?.toJson(),
//         "TransactionProve": transactionProve?.toJson(),
//         "YourAddress": yourAddress?.toJson(),
//         "Bayazid": bayazid?.toJson(),
//         "name": name?.toJson(),
//         "email": dynamicFormEmail?.toJson(),
//         "ifsc": ifsc?.toJson(),
//         "account_number": accountNumber?.toJson(),
//         "crypto_address": cryptoAddress?.toJson(),
//         "receiver": receiver?.toJson(),
//         "network": network?.toJson(),
//         "address": address?.toJson(),
//       };
// }

// class AccountNumber {
//   dynamic name;
//   dynamic label;
//   Type? type;
//   Validation? validation;

//   AccountNumber({
//     this.name,
//     this.label,
//     this.type,
//     this.validation,
//   });

//   factory AccountNumber.fromJson(Map<String, dynamic> json) => AccountNumber(
//         name: json["name"],
//         label: json["label"],
//         type: typeValues.map[json["type"]]!,
//         validation: validationValues.map[json["validation"]]!,
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "label": label,
//         "type": typeValues.reverse[type],
//         "validation": validationValues.reverse[validation],
//       };
// }

// enum Type { TEXT }

// final typeValues = EnumValues({"text": Type.TEXT});

// enum Validation { REQUIRED }

// final validationValues = EnumValues({"required": Validation.REQUIRED});

// class BankName {
//   dynamic fieldName;
//   dynamic fieldLevel;
//   dynamic type;
//   dynamic validation;

//   BankName({
//     this.fieldName,
//     this.fieldLevel,
//     this.type,
//     this.validation,
//   });

//   factory BankName.fromJson(Map<String, dynamic> json) => BankName(
//         fieldName: json["field_name"],
//         fieldLevel: json["field_level"],
//         type: json["type"],
//         validation: json["validation"],
//       );

//   Map<String, dynamic> toJson() => {
//         "field_name": fieldName,
//         "field_level": fieldLevel,
//         "type": type,
//         "validation": validation,
//       };
// }

// class EnumValues<T> {
//   Map<String, T> map;
//   late Map<T, String> reverseMap;

//   EnumValues(this.map);

//   Map<T, String> get reverse {
//     reverseMap = map.map((k, v) => MapEntry(v, k));
//     return reverseMap;
//   }
// }
