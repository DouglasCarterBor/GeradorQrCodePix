import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';

class GerarQRcode extends StatelessWidget {
  final String valores;

  const GerarQRcode({Key? key, required this.valores}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: QrImage(
        data: valores,
        version: QrVersions.auto,
        size: 320,
        gapless: false,
      ),
    );
  }
}
