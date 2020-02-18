import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_br_printer_pt_sdk/flutter_br_printer_pt_sdk.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String printResult = "";
  bool isPrinting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Print Plugin Example app'),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MaterialButton(
                child: Text("> Start Print <"),
                onPressed: isPrinting
                    ? null
                    : () {
                        doPrint();
                      },
              ),
              Text(
                printResult,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> doPrint() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      isPrinting = true;
      printResult = "start search printer...\n";
    });

    var networkManager =
        await FlutterBrPrinterPtSdk.new_BRPtouchNetworkManager();
    List searchResult = await networkManager.startSearch();

    setState(() {
      printResult += "search result:${searchResult.length}\n";
      if (searchResult.length > 0) {
        BRPtouchDeviceInfo device = searchResult.first;
        printResult +=
            "first: ${device.strPrinterName} ip:${device.strIPAddress}\n";
      }
    });

    final pdfFileInAsset = "assets/label.pdf";
    var data = await rootBundle.load(pdfFileInAsset);
    setState(() {
      printResult += "load test asset:$pdfFileInAsset ${(data.lengthInBytes/1024).toStringAsFixed(2)}kb\n";
    });

    String docPath = (await getApplicationDocumentsDirectory()).path;
    String pdfPath = join(docPath, "label.pdf");
    await File(pdfPath).writeAsBytes(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));

    setState(() {
      printResult += "save to document path\n";
    });

    if(searchResult.length >0) {

      setState(() {
        printResult += "start create printer...\n";
      });

      BRPtouchDeviceInfo device = searchResult.first;
      BRPtouchPrinter printer = await FlutterBrPrinterPtSdk
          .new_BRPtouchPrinter(device.strIPAddress);

      setState(() {
        printResult += "get printer: ${printer.target}\nstart printing...\n";
      });

      BRPtouchPrintInfo info = BRPtouchPrintInfo(bEndCut: 0, nAutoCutFlag: 1);
      var result = await printer.doPrintPdfFiles(info, [pdfPath]);

      setState(() {
        printResult += "print result:$result\n";
      });
      printer.dispose();
    }else{
      printResult += "no printer found\n";
    }

    networkManager.dispose();

    setState(() {
      isPrinting = false;
    });
  }
}
