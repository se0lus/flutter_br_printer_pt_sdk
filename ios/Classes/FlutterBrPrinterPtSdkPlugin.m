#import <BRPtouchPrinterKit/BRPtouchPrinterKit.h>
#import "FlutterBrPrinterPtSdkPlugin.h"
#import "BRPtouchPrintInfo+Map.h"
#import "BRWLANPrintOperation.h"

@interface FlutterBrPrinterPtSdkPlugin ()<BRPtouchNetworkDelegate, BRWLANPrintOperationDelegate>
@property (nonatomic, retain) NSOperationQueue* printQueue;
@end

//didFinishSearch([sender])
static NSString* cb_BRPtouchNetworkManager_didFinishSearch = @"cb_BRPtouchNetworkManager_didFinishSearch";
//didFinishPrint([sender, result, error_code])
static NSString* cb_BRPtouchPrinter_didFinishPrint = @"cb_BRPtouchPrinter_didFinishPrint";
static NSString* kP750WPrinterName = @"Brother PT-P750W";

@implementation FlutterBrPrinterPtSdkPlugin

//override
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    NSLog(@"regist channel %@", @"FlutterBrPrinterPtSdkPlugin");
    
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"FlutterBrPrinterPtSdkPlugin"
            binaryMessenger:[registrar messenger]];
    
  FlutterBrPrinterPtSdkPlugin* instance = [[FlutterBrPrinterPtSdkPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
    instance.channel = channel;
}

- (id)init{
    if([super init]){
        NSLog(@"create object:%@", self.className);
        //flutter call native methods
        NSDictionary* methods = @{
            mapMethod(delete_Objects),
            mapMethod(delete_AllObjects),
            
            //netwrok
            mapMethod(new_BRPtouchNetworkManager),
            mapMethod(c_BRPtouchNetworkManager_startSearch),
            mapMethod(c_BRPtouchNetworkManager_getPrinterNetInfo),
            
            //printer
            mapMethod(new_BRPtouchPrinter),
            mapMethod(c_BRPtouchPrinter_doPrintPdfFiles),
            mapMethod(c_BRPtouchPrinter_cancelPrinting),
        };
        [self.methodMap addEntriesFromDictionary:methods];
        
        SEL selector = @selector(new_BRPtouchNetworkManager:);
        if([self respondsToSelector:selector]){
            NSLog(@"YES");
        }
        
//        //native call flutter methods
//        NSDictionary* callbacks = @{
//            cbMethod(cb_BRPtouchNetworkManager_didFinishSearch),
//        };
//        [self.callbackMap addEntriesFromDictionary:callbacks];
        
        self.printQueue = [[NSOperationQueue alloc] init];
        self.printQueue.maxConcurrentOperationCount = 1;
        self.printQueue.name = @"FlutterBrPrinterPtSdkPlugin.Print";
    }
    return self;
}

-(void) dealloc{
    NSLog(@"%@ dealloc", self.className);
}

#pragma mark - common

-(nullable id) delete_AllObjects:(NSArray*) args{
    [self removeAllObjects];
    return nil;
}

-(nullable id) delete_Objects:(NSArray*) args{
    if (args == nil) return nil;
    
    for (id target in args) {
        if ([target isKindOfClass:[NSString class]]) {
            [self removeObject:target];
        }
        else{
            [self removeObject:[ObjectHolder classKey:target]];
        }
    }
    
    return nil;
}

#pragma mark - BRPtouchNetworkManager
//channel methods
-(NSString*) new_BRPtouchNetworkManager:(id)arg{
    BRPtouchNetworkManager* manager = [[BRPtouchNetworkManager alloc] init];
    NSString* key = [self addObject:manager];
    manager.delegate = self;
    //TODO: add more printer support
    [manager setPrinterNames:@[kP750WPrinterName]];
    return key;
}

-(NSNumber*) c_BRPtouchNetworkManager_startSearch:(NSArray*) args{
    if (args.count < 2
        || ![args[0] isKindOfClass:[BRPtouchNetworkManager class]]
        || ![args[1] isKindOfClass:[NSNumber class]]) {
        NSLog(@"invaild arg:%@", args);
        return nil;
    }
    
    BRPtouchNetworkManager* manager = args.firstObject;
    return [NSNumber numberWithInt:[manager startSearch:[(NSNumber*)args[1] intValue]]];
}

- (void)didFinishSearch:(id)sender {
    
    //callback to flutter
    id target = [ObjectHolder classKey:sender];
    if (sender == nil) {
        target = [NSNull null];
    }
    
    NSArray* results = @[];
    if([sender isKindOfClass:[ BRPtouchNetworkManager class]]){
        results = [self c_BRPtouchNetworkManager_getPrinterNetInfo:@[sender]];
        if (results == nil)results = @[];
    }
    
    [self callbackToFlutter:cb_BRPtouchNetworkManager_didFinishSearch args:@[target, results]];
}

-(nullable NSArray*) c_BRPtouchNetworkManager_getPrinterNetInfo:(NSArray*) args{
    if (args.count < 1
        || ![args[0] isKindOfClass:[BRPtouchNetworkManager class]]) {
        NSLog(@"invaild arg:%@", args);
        return nil;
    }
    
    BRPtouchNetworkManager* manager = args.firstObject;
    NSArray* printerInfos = [manager getPrinterNetInfo];
    NSMutableArray* result = [NSMutableArray array];
    
    for (BRPtouchDeviceInfo* info in printerInfos) {
        if([info isKindOfClass:[BRPtouchDeviceInfo class]] == false)
            continue;
        
#define safeValue(v) ((v)?(v):@"")
        NSDictionary* map = @{
            @"strIPAddress":safeValue(info.strIPAddress),
            @"strLocation":safeValue(info.strLocation),
            @"strModelName":safeValue(info.strModelName),
            @"strPrinterName":safeValue(info.strPrinterName),
            @"strSerialNumber":safeValue(info.strSerialNumber),
            @"strNodeName":safeValue(info.strNodeName),
            @"strMACAddress":safeValue(info.strMACAddress),
            @"strBLEAdvertiseLocalName":safeValue(info.strBLEAdvertiseLocalName),
        };
        
        [result addObject:map];
    }
    
    return result;
}

#pragma mark - BRPtouchPrinter

-(NSString*) new_BRPtouchPrinter:(NSArray*)args{
    if (args.count < 1
        || ![args[0] isKindOfClass:[NSString class]]) {
        NSLog(@"invaild arg:%@", args);
        return nil;
    }
    
    //TODO:support more printers later
    BRPtouchPrinter* printer = [[BRPtouchPrinter alloc] initWithPrinterName:kP750WPrinterName interface:CONNECTION_TYPE_WLAN];
    NSString* key = [self addObject:printer];
    [printer setIPAddress:args[0]];
    return key;
}

//param:printer, printInfoMap, pdfpathList
-(NSNumber*) c_BRPtouchPrinter_doPrintPdfFiles:(NSArray*)args{
    if (args.count < 3
        || ![args[0] isKindOfClass:[BRPtouchPrinter class]]
        || ![args[1] isKindOfClass:[NSDictionary class]]
        || ![args[2] isKindOfClass:[NSArray class]]) {
        NSLog(@"invaild arg:%@", args);
        return @(0);
    }
    
    BRPtouchPrinter* printer = args[0];
    BRPtouchPrintInfo* info = [BRPtouchPrintInfo fromMap:args[1]];
    
    BRWLANPrintOperation* op = [[BRWLANPrintOperation alloc] initWithOperation:printer printInfo:info pages:args[2]];
    op.delegate = self;
    [self.printQueue addOperation:op];
    return @(1);
}

-(NSNumber*) c_BRPtouchPrinter_cancelPrinting:(NSArray*)args{
    if (args.count < 1
        || ![args[0] isKindOfClass:[BRPtouchPrinter class]]) {
        NSLog(@"invaild arg:%@", args);
        return @(0);
    }
    
    BRPtouchPrinter* printer = args[0];
    [printer cancelPrinting];
    return @(1);
}

-(void) printComplete:(id)sender{
    
    if(![sender isKindOfClass:[BRWLANPrintOperation class]])return;
    BRWLANPrintOperation* result = sender;
    
    //callback
    [self callbackToFlutter:cb_BRPtouchPrinter_didFinishPrint args:@[
        [ObjectHolder classKey:result.ptp],
        @(result.status),
        @(result.error),
    ]];
}

#pragma mark - private methods
//private methods

@end
