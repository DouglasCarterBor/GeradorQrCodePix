//https://crccalc.com/

import 'dart:convert';
import 'package:crclib/catalog.dart';
import 'package:geradorqrcodepix/componentes/converter_hexa.dart';

class CRC {
  static String gerarcrc16ccittfalse(String valor) {
    // ignore: prefer_typing_uninitialized_variables
    var t;
    String crchexa;
    String b;

    t = Crc16CcittFalse().convert(utf8.encode(valor));
    b = t.toString();
    int crc = int.tryParse(b)!;
    crchexa = ConversorBases.toHexadecimal(crc);

    return crchexa;
  }
}
