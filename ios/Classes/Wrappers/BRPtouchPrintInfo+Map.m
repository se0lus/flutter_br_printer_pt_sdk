//
//  BRPtouchPrintInfo+Map.m
//  flutter_br_printer_pt_sdk
//
//  Created by 夸克 on 2020/2/16.
//

#import "BRPtouchPrintInfo+Map.h"

@implementation BRPtouchPrintInfo

-(NSDictionary*) toMap{
    
#define safeValue(v) ((v)?(v):@"")
    
    //TODO: suppport more configs
    return @{
        @"strPaperName":safeValue(self.strPaperName),
        //cut every page, 0,OPTION_AUTOCUT
        @"nAutoCutFlag":@(self.nAutoCutFlag),
        //cut when print end, this will waste a little pice of tape when next print.
        @"bEndCut":@(self.bEndcut),
        //only cut the surface of the tape
        @"bHalfCut":@(self.bHalfCut),
//        #define PRINTQUALITY_LOW_RESOLUTION  1 // 高速
//        #define PRINTQUALITY_NORMAL          2 // ノーマル(高品質)
//        #define PRINTQUALITY_DOUBLE_SPEED    3 // ノーマル(高速)
//        #define PRINTQUALITY_HIGH_RESOLUTION 4 // 高品質
        @"nPrintQuality":@(self.nPrintQuality)
    };
}

+(BRPtouchPrintInfo*) fromMap:(NSDictionary*)map{
    if(!map)return nil;
    
    BRPtouchPrintInfo* info = [[BRPtouchPrintInfo alloc] init];
    
#define safeSetStr(key) if(map[@#key]){info.key = map[@#key];}
#define safeSetInt(key) if(map[@#key]){info.key = [map[@#key] intValue];}
    
    safeSetStr(strPaperName);
    safeSetInt(nAutoCutFlag);
    safeSetInt(bEndcut);
    safeSetInt(bHalfCut);
    safeSetInt(nPrintQuality);
    
    //set to default value, copy from SDK example
    info.nHalftoneBinaryThreshold = 127;
    info.nExtFlag = 8;
    //Whether or not the status should be checked before printing. It will be checked if YES
    info.bBidirection = 1;
    info.nDensity = 65535;
    info.scaleValue = 1.0;
    info.nAutoCutCopies = 1;
    info.bMode9 = 1;
    info.strSaveFilePath = @"";
    
    return info;
}

@end
