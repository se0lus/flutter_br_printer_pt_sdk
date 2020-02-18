//
//  BRWLANPrintOperation.h
//  SDK_Sample_Ver2
//
//  Copyright (c) 2015-2018 Brother Industries, Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BRPtouchPrinterKit/BRPtouchPrinterKit.h>

typedef NS_ENUM(NSInteger, BRWLANPrintQperationStatus) {
    BRWPS_idle = 0,
    BRWPS_working = 1,
    BRWPS_complete = 2,
};

typedef NS_ENUM(NSInteger, BRWLANPrintQperationError) {
    BRWPE_no_error = 0,
    BRWPE_commuication_error = 1,
    //... more errors in BRPtouchPrinter.h
};

@protocol BRWLANPrintOperationDelegate <NSObject>
@optional
- (void) printComplete:(id)sender;
@end


@interface BRWLANPrintOperation : NSOperation

@property(nonatomic, readonly) BRPtouchPrinter *ptp;
//TODO: print process callback
@property (nonatomic, assign) BRWLANPrintQperationError error;
@property (nonatomic, assign) BRWLANPrintQperationStatus status;

@property (nonatomic, weak)id<BRWLANPrintOperationDelegate> delegate;

//TODO: support image print and custom papper;
- (id)initWithOperation:(BRPtouchPrinter *)targetPtp
              printInfo:(BRPtouchPrintInfo *)targetPrintInfo
                  pages:(NSArray *)pdfPathArray;

@end
