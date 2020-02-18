//
//  BRWLANPrintOperation.m
//  SDK_Sample_Ver2
//
//  Copyright (c) 2015-2018 Brother Industries, Ltd. All rights reserved.
//

#import "BRWLANPrintOperation.h"

@interface BRWLANPrintOperation ()
@property(nonatomic, strong) BRPtouchPrinter      *ptp;
@property(nonatomic, strong) BRPtouchPrintInfo  *printInfo;
@property(nonatomic, strong) NSArray            *pdfPathArray;
@end

@implementation BRWLANPrintOperation

- (id)initWithOperation:(BRPtouchPrinter *)targetPtp
              printInfo:(BRPtouchPrintInfo *)targetPrintInfo
                  pages:(NSArray *)pdfPathArray
{
    self = [super init];
    if (self) {
        self.ptp            = targetPtp;
        self.printInfo      = targetPrintInfo;
        self.pdfPathArray   = pdfPathArray;
        
        self.status = BRWPS_idle;
        self.error = BRWPE_no_error;
    }
    
    return self;
}

- (void)main
{
    self.status = BRWPS_working;
    
    do{
        //start communication
        BOOL comm_result = [self.ptp startCommunication];
        if (!comm_result) {
            self.error = BRWPE_commuication_error;
            break;
        }
        
        [self.ptp setPrintInfo:self.printInfo];
        [self.ptp setCustomPaperFile:@""];
        [self.ptp setCustomPaperInfoCommand:nil];
        
        for (NSString* path in self.pdfPathArray) {
            if (![path isKindOfClass:[NSString class]]) {
                continue;
            }
            
            NSUInteger pageIndexes[] = {0};
            int printResult = [self.ptp printPDFAtPath:path pages:pageIndexes length:0 copy:1];
            if (printResult != ERROR_NONE_) {
                //error
                NSLog(@"print error with code:%d", printResult);
                self.error = printResult;
                break;
            }
        }
    }while(false);
    
    [self.ptp endCommunication];
    self.status = BRWPS_complete;
    if ([self.delegate respondsToSelector:@selector(printComplete:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate printComplete:self];
        });
    }
}

@end
