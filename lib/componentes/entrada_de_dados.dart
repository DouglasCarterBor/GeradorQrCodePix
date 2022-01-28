import 'dart:async';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geradorqrcodepix/uteis/tamanhos.dart';
import 'package:validadores/Validador.dart';

// ignore: must_be_immutable
class EntradaDeDados extends StatelessWidget {
  final TextEditingController controller;
  String valordigitado;

  EntradaDeDados(
      {Key? key, required this.controller, required this.valordigitado})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      elevation: Tamanhos.elevation,
      shadowColor: Colors.grey,
      child: TextFormField(
        controller: controller,
        onSaved: (valor) {
          valordigitado = valor!;
        },
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 10,
                style: BorderStyle.solid,
              ),
            ),
            // enabledBorder: OutlineInputBorder(
            //   borderSide: const BorderSide(
            //       color: Colors.grey),
            //   borderRadius:
            //       BorderRadius.circular(20),
            // ),
            // focusedBorder: OutlineInputBorder(
            //   borderSide: const BorderSide(
            //       color: Colors.blue),
            //   borderRadius:
            //       BorderRadius.circular(5),
            // ),
            labelText: "Chave",
            fillColor: Colors.white,
            filled: true,
            hintText: "Digite a chave"),
        validator: (valor) {
          return Validador()
              .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
              .valido(valor);
        },
      ),
    );
  }
}
