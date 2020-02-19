import 'package:flutter/services.dart';
import 'src/brp_touch_network_manager.dart';
import 'src/brp_touch_device_info.dart';
import 'src/brp_touch_print_info.dart';
import 'src/brp_touch_printer.dart';

export 'src/brp_touch_network_manager.dart';
export 'src/brp_touch_device_info.dart';
export 'src/brp_touch_print_info.dart';
export 'src/brp_touch_printer.dart';

class FlutterBrPrinterPtSdk {
  static const MethodChannel _channel =
      const MethodChannel('FlutterBrPrinterPtSdkPlugin');

  /// impotent: you need to delete ALL objects create with new_xxx after use
  /// this will let the native platform to release the memory.
  static Future delete_Objects(List<BRPBasic> objects) async {
    final args = List<String>();
    for(var target in objects){
      args.add(target.target);
      removeOBject(target);
    }

    return _channel.invokeMethod('delete_Objects', args);
  }

  /// dispose all objects currently we create, same as delete_Objects
  /// objects can not use after this call
  /// but you can create new objects after this call.
  static Future dispose_AllCurrentObjects() async {
    var objMap = _objectMap;
    _objectMap = {};
    _listenerMap = {};
    
    for(var target in objMap.values){
      target.disposed = true;
    }
    return _channel.invokeMethod('delete_AllObjects', null);
  }

  /*
  BRPtouchNetworkManager methods
   */


  static Future<BRPtouchNetworkManager> new_BRPtouchNetworkManager() async {
    final String manager = await _channel.invokeMethod('new_BRPtouchNetworkManager');
    var object = BRPtouchNetworkManager(manager);
    addObject(object);
    return object;
  }

  static Future<bool> c_BRPtouchNetworkManager_startSearch(BRPtouchNetworkManager target, int searchTimeInSec){
    return _channel.invokeMethod('c_BRPtouchNetworkManager_startSearch', [target.target, searchTimeInSec]).then((value){
      if(value == 0 || value == null)return false;
        return true;
    });
  }

  static Future<List<BRPtouchDeviceInfo>> c_BRPtouchNetworkManager_getPrinterNetInfo(BRPtouchNetworkManager target){
    return _channel.invokeMethod('c_BRPtouchNetworkManager_getPrinterNetInfo', [target.target]).then((result){
      final infoList = List<BRPtouchDeviceInfo>();
      if(result is List){
        for(var map in result){
          if((map is Map) == false)continue;
          final info = BRPtouchDeviceInfo.fromMap(map);
          if(info != null)infoList.add(info);}}
      return infoList;
    });
  }

  /*
  BRPtouchPrinter methods
   */

  static Future<BRPtouchPrinter> new_BRPtouchPrinter(String ip) async{
    final String printer = await _channel.invokeMethod('new_BRPtouchPrinter', [ip]);
    if(printer == null || printer.length == 0){
      return null;
    }

    var object = BRPtouchPrinter(printer);
    addObject(object);
    return object;
  }

  static Future<bool> c_BRPtouchPrinter_doPrintPdfFiles(BRPtouchPrinter printer, BRPtouchPrintInfo info, List<String> paths){
    return _channel.invokeMethod('c_BRPtouchPrinter_doPrintPdfFiles', [printer.target, info.toMap(), paths]).then((value){
      if(value == 0 || value == null)return false;
      return true;
    });
  }

  static Future<bool> c_BRPtouchPrinter_cancelPrinting(BRPtouchPrinter printer){
    return _channel.invokeMethod('c_BRPtouchPrinter_cancelPrinting', [printer.target]).then((value){
      if(value == 0 || value == null)return false;
      return true;
    });
  }

  /*
  listeners
   */

  static bool _listenerReady = false;
  static Map<String, List<BRPBasic>> _listenerMap = {};
  static Map<String, BRPBasic> _objectMap = {};

  // all callbacks should looks like callback(List[String target, args...])
  static Future<dynamic> handleCallbacks(MethodCall call){
    print("cb method:$call");
    String method = call.method;

    final targets = _listenerMap[method];
    if(targets == null)
      return null;

    String targetString;
    if(call.arguments is List) {
      List args = call.arguments;
      if(args.length > 0 && args.first is String){
        targetString = args.first;
      }
    }

    //print("cb on $targetString");
    var targetsCpy = List.from(targets);
    for(var target in targetsCpy){
      if(target.target == targetString)
        target.onCallback(call);
    }

    return null;
  }

  static void addListener(BRPBasic target, String method){
    if(_listenerReady == false){
      _listenerReady = true;
      _channel.setMethodCallHandler(handleCallbacks);
    }

    if(_listenerMap[method] == null){
      _listenerMap[method] = [];
    }
    _listenerMap[method].add(target);
  }

  static void removeListener(BRPBasic target, String method){
    if(_listenerMap[method] != null){
      _listenerMap[method].remove(target);
    }
  }

  static void addObject(BRPBasic object){
    _objectMap[object.target] = object;
  }

  static void removeOBject(BRPBasic object){
    _objectMap.remove(object.target);
    for(var cbList in _listenerMap.values){
      cbList.remove(object);
    }
    object.disposed = true;
  }
}

class BRPBasic{
  //target is a object desc from platform side
  //on ios, it is a "className:memAddress"
  final String target;
  var disposed = false;

  BRPBasic(this.target);

  void onCallback(MethodCall call){

  }

  void dispose(){
    if(disposed)return;
    FlutterBrPrinterPtSdk.delete_Objects([this]);
  }
}