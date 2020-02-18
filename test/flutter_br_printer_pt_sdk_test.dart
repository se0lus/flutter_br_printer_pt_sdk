import 'package:flutter/services.dart';
import 'package:flutter_br_printer_pt_sdk/src/brp_touch_device_info.dart';
import 'package:flutter_br_printer_pt_sdk/src/brp_touch_network_manager.dart';
import 'package:flutter_br_printer_pt_sdk/src/brp_touch_print_info.dart';
import 'package:flutter_br_printer_pt_sdk/src/brp_touch_printer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_br_printer_pt_sdk/flutter_br_printer_pt_sdk.dart';

void main() {
  const MethodChannel channel = MethodChannel('FlutterBrPrinterPtSdkPlugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method){
        case "delete_Objects":
        case "delete_AllObjects":
          return null;

        case "new_BRPtouchNetworkManager":
          return "BRPtouchNetworkManager:0xabcdefg";

        case "c_BRPtouchNetworkManager_startSearch":
          Future.delayed(Duration(seconds: 1)).then((value){
            FlutterBrPrinterPtSdk.handleCallbacks(MethodCall(
              "cb_BRPtouchNetworkManager_didFinishSearch",
              ['BRPtouchNetworkManager:0xabcdefg', 1]
            ));
          });
          return 1;
          
        case "c_BRPtouchNetworkManager_getPrinterNetInfo":
          return [{"strIPAddress":"192.168.1.42"}];

        case "new_BRPtouchPrinter":
          return "BRPtouchPrinter:0x1234";

        case "c_BRPtouchPrinter_doPrintPdfFiles":
          Future.delayed(Duration(seconds: 1)).then((value){
            FlutterBrPrinterPtSdk.handleCallbacks(MethodCall(
                "cb_BRPtouchPrinter_didFinishPrint",
                ['BRPtouchPrinter:0x1234', 2, 0]
            ));
          });
          return 1;
        case "c_BRPtouchPrinter_cancelPrinting":
          return 1;

        default:
          return null;
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  group("sdk local test", (){

    test('new_BRPtouchNetworkManager', () async {

      expect((await FlutterBrPrinterPtSdk.new_BRPtouchNetworkManager()).target.startsWith("BRPtouchNetworkManager"), true);

    });

    test('delete_Objects', () async {

      var manager = await FlutterBrPrinterPtSdk.new_BRPtouchNetworkManager();
      manager.dispose();
      expect(manager.disposed, true);
    });

    test('dispose_AllCurrentObjects', () async {

      var manager = await FlutterBrPrinterPtSdk.new_BRPtouchNetworkManager();
      FlutterBrPrinterPtSdk.dispose_AllCurrentObjects();
      expect(manager.disposed, true);
      expect((await FlutterBrPrinterPtSdk.new_BRPtouchNetworkManager()).target.startsWith("BRPtouchNetworkManager"), true);
    });

    test('c_BRPtouchNetworkManager_startSearch', () async{
      BRPtouchNetworkManager manager = await FlutterBrPrinterPtSdk.new_BRPtouchNetworkManager();
      var result = await manager.startSearch(searchTimeInSec: 1);
      expect(result.length, 1);
    });

    test('c_BRPtouchNetworkManager_getPrinterNetInfo', () async{
      BRPtouchNetworkManager manager = await FlutterBrPrinterPtSdk.new_BRPtouchNetworkManager();
      await manager.startSearch(searchTimeInSec: 1);
      var result = await manager.getPrinterNetInfo();
      expect(result.first.strIPAddress, "192.168.1.42");
    });

    test('new_BRPtouchPrinter', () async {
      expect((await FlutterBrPrinterPtSdk.new_BRPtouchPrinter("192.168.1.42")).target.startsWith("BRPtouchPrinter"), true);
    });

    test('c_BRPtouchPrinter_doPrintPdfFiles', () async{
      BRPtouchPrinter printer = await FlutterBrPrinterPtSdk.new_BRPtouchPrinter("192.168.1.42");
      BRPtouchPrintInfo info = BRPtouchPrintInfo();

      var result = await printer.doPrintPdfFiles(info, []);
      expect(result, true);
    });

    test('c_BRPtouchPrinter_cancelPrinting', () async{
      BRPtouchPrinter printer = await FlutterBrPrinterPtSdk.new_BRPtouchPrinter("192.168.1.42");
      BRPtouchPrintInfo info = BRPtouchPrintInfo();

      printer.doPrintPdfFiles(info, []);
      var result = await printer.cancelPrinting();

      expect(result, true);
    });
  });
}
