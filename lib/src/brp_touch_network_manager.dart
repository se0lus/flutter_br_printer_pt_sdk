import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_br_printer_pt_sdk/flutter_br_printer_pt_sdk.dart';
import 'package:flutter_br_printer_pt_sdk/src/brp_touch_device_info.dart';

class BRPtouchNetworkManager extends BRPBasic{

  //didFinishSearch([sender])
  static final String cb_didFinishSearch = "cb_BRPtouchNetworkManager_didFinishSearch";

  Completer<List<BRPtouchDeviceInfo>> _searchComplete;

  BRPtouchNetworkManager(String target):super(target);

  //future will return until search complete;
  Future<List<BRPtouchDeviceInfo>> startSearch({int searchTimeInSec = 5}) {

    if(_searchComplete != null){
      return _searchComplete.future;
    }

    //add listener and wait for it complete
    FlutterBrPrinterPtSdk.addListener(this, cb_didFinishSearch);

    _searchComplete = Completer();
    return FlutterBrPrinterPtSdk.c_BRPtouchNetworkManager_startSearch(this, searchTimeInSec).then((bool value) async{
      if(!value){
        print("start search failed");
        _searchComplete = null;
        return [];
      }

      return _searchComplete.future;
    });
  }

  Future<List<BRPtouchDeviceInfo>> getPrinterNetInfo(){
    return FlutterBrPrinterPtSdk.c_BRPtouchNetworkManager_getPrinterNetInfo(this);
  }

  @override
  void onCallback(MethodCall call) {
    super.onCallback(call);

    if(call.method == cb_didFinishSearch){
      FlutterBrPrinterPtSdk.removeListener(this, cb_didFinishSearch);

      final infoList = List<BRPtouchDeviceInfo>();

      if(call.arguments is List){
        List args = call.arguments;
        if(args.length >= 2 && args[1] is List){

          List result = args[1];
            for(var map in result){
              if((map is Map) == false)continue;
              final info = BRPtouchDeviceInfo.fromMap(map);
              if(info != null)infoList.add(info);}}
      }

        var complete = _searchComplete;
        _searchComplete = null;
        complete.complete(infoList);
    }
  }
}
