import 'package:teachers/handlers/string_handlers.dart';

class FeedbackQuery {
  int QueryNo;
  String QueryType;
  String Query;
  double RatingScale;
  int RatingFrom;
  int RatingUpto;
  String OptionType;
  String OptionDesc;
  int OptionNo;

  FeedbackQuery({
    this.QueryNo,
    this.QueryType,
    this.Query,
    this.RatingScale,
    this.RatingFrom,
    this.RatingUpto,
    this.OptionType,
    this.OptionDesc,
    this.OptionNo,
  });

  FeedbackQuery.fromMap(Map<String, dynamic> map) {
    QueryNo = map[FeedbackQueryConst.QueryNoConst];
    QueryType = map[FeedbackQueryConst.QueryTypeConst];
    Query = map[FeedbackQueryConst.QueryConst];
    RatingScale = map[FeedbackQueryConst.RatingScaleConst];
    RatingFrom = map[FeedbackQueryConst.RatingFromConst];
    RatingUpto = map[FeedbackQueryConst.RatingUptoConst];
    OptionType = map[FeedbackQueryConst.OptionTypeConst];
    OptionDesc = map[FeedbackQueryConst.OptionDescConst];
    OptionNo = map[FeedbackQueryConst.OptionNoConst];
  }
  factory FeedbackQuery.fromJson(Map<String, dynamic> parsedJson) {
    return FeedbackQuery(
      QueryNo: parsedJson['QueryNo'] ?? 0,
      QueryType: parsedJson['QueryType'] ?? StringHandlers.NotAvailable,
      Query: parsedJson['Query'] ?? StringHandlers.NotAvailable,
      RatingScale: parsedJson['RatingScale'] ?? 0,
      RatingFrom: parsedJson['RatingFrom'] ?? 0,
      RatingUpto: parsedJson['RatingUpto'] ?? 0,
      OptionType: parsedJson['OptionType'] ?? StringHandlers.NotAvailable,
      OptionDesc: parsedJson['OptionDesc'] ?? StringHandlers.NotAvailable,
      OptionNo: parsedJson['OptionNo'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        FeedbackQueryConst.QueryNoConst: QueryNo,
        FeedbackQueryConst.QueryTypeConst: QueryType,
        FeedbackQueryConst.QueryConst: Query,
        FeedbackQueryConst.RatingScaleConst: RatingScale,
        FeedbackQueryConst.RatingFromConst: RatingFrom,
        FeedbackQueryConst.RatingUptoConst: RatingUpto,
        FeedbackQueryConst.OptionTypeConst: OptionType,
        FeedbackQueryConst.OptionDescConst: OptionDesc,
        FeedbackQueryConst.OptionNoConst: OptionNo,
      };
}

class FeedbackQueryConst {
  static const String QueryNoConst = "QueryNo";
  static const String QueryTypeConst = "QueryType";
  static const String QueryConst = "Query";
  static const String RatingScaleConst = "RatingScale";
  static const String RatingFromConst = "RatingFrom";
  static const String RatingUptoConst = "RatingUpto";
  static const String OptionTypeConst = "OptionType";
  static const String OptionDescConst = "OptionDesc";
  static const String OptionNoConst = "OptionNo";
}

class FeedbackQueryUrls {
  static const String GET_FEEDBACK_SUMMARY =
      'Feedback/GetUserTypewiseFeedbackQueries';
}
