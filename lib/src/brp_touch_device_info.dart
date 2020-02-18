class BRPtouchDeviceInfo {

//  @property (copy,nonatomic)NSString* strIPAddress;
//  @property (copy,nonatomic)NSString* strLocation;
//  @property (copy,nonatomic)NSString* strModelName;
//  @property (copy,nonatomic)NSString* strPrinterName;
//  @property (copy,nonatomic)NSString* strSerialNumber;
//  @property (copy,nonatomic)NSString* strNodeName;
//  @property (copy,nonatomic)NSString* strMACAddress;
//  @property (copy,nonatomic)NSString* strBLEAdvertiseLocalName;

  final String strIPAddress;
  final String strLocation;
  final String strPrinterName;
  final String strSerialNumber;
  final String strNodeName;
  final String strMACAddress;
  final String strBLEAdvertiseLocalName;

  BRPtouchDeviceInfo(
      this.strIPAddress,
      this.strLocation,
      this.strPrinterName,
      this.strSerialNumber,
      this.strNodeName,
      this.strMACAddress,
      this.strBLEAdvertiseLocalName);

  factory BRPtouchDeviceInfo.fromMap(Map map) => BRPtouchDeviceInfo(
      map['strIPAddress'],
      map['strLocation'],
      map['strPrinterName'],
      map['strSerialNumber'],
      map['strNodeName'],
      map['strMACAddress'],
      map['strBLEAdvertiseLocalName'],
  );

  Map toMap(){
    final map = {};
    map['strIPAddress'] = strIPAddress;
    map['strLocation'] = strLocation;
    map['strPrinterName'] = strPrinterName;
    map['strSerialNumber'] = strSerialNumber;
    map['strNodeName'] = strNodeName;
    map['strMACAddress'] = strMACAddress;
    map['strBLEAdvertiseLocalName'] = strBLEAdvertiseLocalName;
    return map;
  }

  String toString(){
    return toMap().toString();
  }
}