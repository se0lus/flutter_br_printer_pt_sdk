//
//  ObjectHolder.m
//  flutter_br_printer_pt_sdk
//
//  Created by 夸克 on 2020/2/15.
//

#import <objc/runtime.h>
#import "FlutterBrPrinterPtSdkPlugin.h"
#import "ObjectHolder.h"

@implementation FlutterCallbackHolder

+(id) cb:(NSString*)cb{
    FlutterCallbackHolder *holder = [[FlutterCallbackHolder alloc] init];
    holder.method = cb;
    return holder;
}

@end

@implementation MethodHolder

- (id)initWithSel:(SEL)selector{
    if (self = [super init]) {
        self.selector = selector;
    }
    return self;
}

+(id) sel:(SEL)selector{
    return [[MethodHolder alloc] initWithSel:selector];
}

@end

@implementation ObjectHolder

- (id)init{
    if(self = [super init]){
        self.objectMap = [[NSMutableDictionary alloc] init];
        self.methodMap = [[NSMutableDictionary alloc] init];
        self.className = [ObjectHolder classKey:self];
        
//        self.callbackMap = [[NSMutableDictionary alloc] init];
//        [self.methodMap setObject:[MethodHolder sel:@selector(c_setCallback:)] forKey:@"c_setCallback"];
    }
    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    //sub class should override this
}

+(NSString*) classKey:(id)obj{
    NSString* className = [NSString stringWithUTF8String:class_getName([obj class])];
    return [NSString stringWithFormat:@"%@:%p", className, obj];
}

-(NSString*) addObject:(id)obj{
    NSString* key = [ObjectHolder classKey:obj];
    NSLog(@"create object %@", key);
    self.objectMap[key] = obj;
    return key;
}

-(id) object:(NSString *)key{
    if([key isEqualToString:self.className]){
        return self;
    }
    return self.objectMap[key];
}

-(id) removeObject:(NSString *)key{
    NSLog(@"remove object %@", key);
    
    id obj = self.objectMap[key];
    if (obj) {
        [self.objectMap removeObjectForKey:key];
    }
    return obj;
}

-( nullable id) removeAllObjects{
    NSLog(@"remove all %lu objects", (unsigned long)self.objectMap.count);
    [self.objectMap removeAllObjects];
    return nil;
}

//-(id) c_setCallback:(NSArray*)args{
//    if(args.count < 1
//       || [args[0] isKindOfClass:[NSString class]] == false){
//        return nil;
//    }
//
//    FlutterCallbackHolder *cb = [FlutterCallbackHolder cb:args[0]];
//    self.callbackMap[args[0]] = cb;
//    return [NSNumber numberWithBool:TRUE];
//}

-(void) callbackToFlutter:(NSString *)method args:(NSArray *)args{
    if (self.channel == NULL) {
        NSLog(@"%@ callback %@ failed, channel is not ready", self.className, method);
        return;
    }
    
    NSLog(@"%@ callback %@ %@", self.className, method, args);
    [self.channel invokeMethod:method arguments:args];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {

    SEL method = ((MethodHolder*)self.methodMap[call.method]).selector;
    
    NSMutableArray* args = [NSMutableArray array];
    if([call.arguments isKindOfClass:[NSArray class]]){
        [args addObjectsFromArray:call.arguments];
    }else if(call.arguments){
        [args addObject:call.arguments];
    }
    
    if ([self respondsToSelector:method] == false) {
        NSLog(@"unknown method %@ send to:%@", call.method, self.className);
        result(nil);
        return;
    }
    
    if(args.count == 0){
        //call on self method
        NSLog(@"call %@ on %@", call.method, self.className);
        IMP imp = [self methodForSelector:method];
        NativeExportMethod func = (void *)imp;
        result(func(self, method, @[]));
    }else{
        if ([args.firstObject isKindOfClass:[NSString class]]) {
            
            NSString* targetName = args.firstObject;
            id target = [self object:targetName];
            if (target) {
                [args removeObjectAtIndex:0];
                [args insertObject:target atIndex:0];
                NSLog(@"call %@ on %@ target %@", call.method, self.className, targetName);
            }
        }else{
            NSLog(@"call %@ on %@", call.method, self.className);
        }
        
        IMP imp = [self methodForSelector:method];
        NativeExportMethod func = (void *)imp;
        result(func(self, method, args));
    }
}

@end
