//
//  ObjectHolder.h
//  flutter_br_printer_pt_sdk
//
//  Created by 夸克 on 2020/2/15.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

#define mapMethod(method) @#method:[MethodHolder sel:@selector(method:)]
#define cbMethod(method) method:[FlutterCallbackHolder cb:method]

NS_ASSUME_NONNULL_BEGIN

//standard method export to flutter
typedef id _Nullable (*NativeExportMethod)(id, SEL, NSArray*);

@interface MethodHolder : NSObject
@property (nonatomic, assign) SEL selector;
+(id) sel:(SEL)selector;
@end

@interface FlutterCallbackHolder : NSObject
@property (nonatomic, copy) NSString* method;
+(id) cb:(NSString*)cb;
@end

/*
 * object holder will create a channel same as the class name.
 * flutter call methods with [classNameString, args..], objective c code will get call with [object, args...]
 * holder have a defaut method: c_setCallback(method, [optionalTarget])
 */
@interface ObjectHolder : NSObject<FlutterPlugin>
@property (nonatomic, retain) NSString* className;
@property (nonatomic, retain) FlutterMethodChannel* channel;

@property (nonatomic, retain) NSMutableDictionary* objectMap;
@property (nonatomic, retain) NSMutableDictionary* methodMap;
//@property (nonatomic, retain) NSMutableDictionary* callbackMap;

+(NSString*) classKey:(id)obj;
-( nullable NSString* ) addObject:(id)obj;
-( nullable id) object:(NSString*)key;
-( nullable id) removeObject:(NSString*)key;
-( nullable id) removeAllObjects;

//on flutter side, this will be method((target/Null), args...)
-(void) callbackToFlutter:(NSString*)method args:(NSArray*)args;

@end

NS_ASSUME_NONNULL_END
