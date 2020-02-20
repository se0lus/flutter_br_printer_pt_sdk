


class BRPtouchPrintInfo{

//  @"strPaperName":safeValue(self.strPaperName),
//  //cut every page, 0,OPTION_AUTOCUT
//  @"nAutoCutFlag":@(self.nAutoCutFlag),
//  //cut when print end, this will waste a little pice of tape when next print.
//  @"bEndCut":@(self.bEndcut),
//  //only cut the surface of the tape
//  @"bHalfCut":@(self.bHalfCut),
////        #define PRINTQUALITY_LOW_RESOLUTION  1 // 高速
////        #define PRINTQUALITY_NORMAL          2 // ノーマル(高品質)
////        #define PRINTQUALITY_DOUBLE_SPEED    3 // ノーマル(高速)
////        #define PRINTQUALITY_HIGH_RESOLUTION 4 // 高品質
//  @"nPrintQuality":@(self.nPrintQuality)

  static const String paperName_18mm = "18mm";
  static const String paperName_24mm = "24mm";
  static const int printQuality_Normal = 2;
  static const int printQuality_High = 4;

  //TODO:support more params
  final String strPaperName;
  final int nAutoCutFlag;
  final int bEndCut;
  final int bHalfCut;
  final int nPrintQuality;

  BRPtouchPrintInfo({
    this.strPaperName = paperName_24mm,
    this.nAutoCutFlag = 1,
    this.bEndCut = 1,
    this.bHalfCut = 0,
    this.nPrintQuality = printQuality_High});

  factory BRPtouchPrintInfo.fromMap(Map map){
    return BRPtouchPrintInfo(
      strPaperName: map['strPaperName']??paperName_24mm,
      nAutoCutFlag: map['nAutoCutFlag']??1,
      bEndCut: map['bEndCut']??1,
      bHalfCut: map['bHalfCut']??0,
      nPrintQuality: map['nPrintQuality']??4,
    );
  }

  Map toMap(){
    return {
      "strPaperName":strPaperName,
      "nAutoCutFlag":nAutoCutFlag,
      "bEndCut":bEndCut,
      "bHalfCut":bHalfCut,
      "nPrintQuality":nPrintQuality,
    };
  }
}