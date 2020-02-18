//
//  BRPtouchPrintInfo+Map.h
//  flutter_br_printer_pt_sdk
//
//  Created by 夸克 on 2020/2/16.
//

#import <BRPtouchPrinterKit/BRPtouchPrinterKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRPtouchPrintInfo (toMap)
-(NSDictionary*) toMap;
+(BRPtouchPrintInfo*) fromMap:(NSDictionary*)map;
@end

NS_ASSUME_NONNULL_END
