import 'dart:async';
import 'package:flutter/services.dart';

import 'package:flutter_br_printer_pt_sdk/flutter_br_printer_pt_sdk.dart';
import 'package:flutter_br_printer_pt_sdk/src/brp_touch_print_info.dart';

class BRPtouchPrinter extends BRPBasic{

  //didFinishPrint([sender, result, error_code])
  static final String cb_didFinishPrint = "cb_BRPtouchPrinter_didFinishPrint";
  Completer<bool> _printFinish;

  BRPtouchPrinter(String target):super(target);

  Future<bool> doPrintPdfFiles(BRPtouchPrintInfo info, List<String> pdfList) async {

    if(_printFinish != null){
      return false;
    }

    FlutterBrPrinterPtSdk.addListener(this, cb_didFinishPrint);
    _printFinish = Completer<bool>();

    return FlutterBrPrinterPtSdk.c_BRPtouchPrinter_doPrintPdfFiles(this, info, pdfList).then((bool result){
      if(result == false){
        print("start print failed");
        _printFinish = null;
        return false;
      }

      return _printFinish.future;
    });
  }

  Future<bool> cancelPrinting(){
    return FlutterBrPrinterPtSdk.c_BRPtouchPrinter_cancelPrinting(this);
  }

  @override
  void onCallback(MethodCall call) {

    if(call.method == cb_didFinishPrint){
      FlutterBrPrinterPtSdk.removeListener(this, cb_didFinishPrint);

      if(_printFinish == null)
        return;

      bool printResult = false;

      if(call.arguments is List){
        List args = call.arguments;
        if(args.length >2){
          int result = args[2];
          if(result != 0){
            print("print end with result:$result");
          }else{
            printResult = true;
          }
        }
      }

      _printFinish.complete(printResult);
    }
  }
}