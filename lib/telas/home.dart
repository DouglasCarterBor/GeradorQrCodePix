import 'dart:async';
import 'dart:typed_data';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geradorqrcodepix/componentes/converter_hexa.dart';
import 'package:geradorqrcodepix/componentes/gerar_qrcode.dart';
import 'package:geradorqrcodepix/componentes/ler_qrcode.dart';
import 'package:geradorqrcodepix/transformadores/crc16_ccitt_false.dart';
import 'package:validadores/validadores.dart';
import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:brasil_fields/brasil_fields.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _chavePix = TextEditingController(text: "");
  final TextEditingController _nomeBeneficiario =
      TextEditingController(text: "");
  final TextEditingController _nomeCidade = TextEditingController(text: "");
  final TextEditingController _valorDoPix = TextEditingController(text: "");
  final TextEditingController _descricaoTransferencia =
      TextEditingController(text: "");

  final _formKey = GlobalKey<FormState>();

  //PayloadFormatIndicator
  final String IdPayloadFormatIndicator = "00";
  final String TamPayloadFormatIndicator =
      "02"; //QUANTIDADE DE CARACTERES DO PRÓXIMO ITEM
  final String DescricaoPayloadFormatIndicator = "01";
  String PayloadFormatIndicator = "";

  _gerarPayloadFormatIndicator() {
    setState(() {
      PayloadFormatIndicator = IdPayloadFormatIndicator +
          TamPayloadFormatIndicator +
          DescricaoPayloadFormatIndicator;
    });
  }

  //MerchantAccountInformation
  final String IdMerchantAccountInformation = "26";
  final String TamMerchantAccountInformation =
      "33"; //QUANTIDADE DE CARACTERES DO PRÓXIMO ITEM
  final String IdGUIMerchantAccountInformation = "00";
  final String TamGUIMerchantAccountInformation =
      "14"; //QUANTIDADE DE CARACTERES DO PRÓXIMO ITEM
  final String GUIMerchantAccountInformation = "BR.GOV.BCB.PIX";
  final String IdChavePixMerchantAccountInformation = "01";
  String TamChavePixMerchantAccountInformation =
      ""; //QUANTIDADE DE CARACTERES DE CHAVE PIX
  String ChavePixMerchantAccountInformation =
      ""; //QUANTIDADE DE CARACTERES DE CHAVE PIX

  String MerchantAccountInformation = "";

  _gerarMerchantAccountInformation() {
    setState(() {
      MerchantAccountInformation = IdMerchantAccountInformation +
          TamMerchantAccountInformation +
          IdGUIMerchantAccountInformation +
          TamGUIMerchantAccountInformation +
          GUIMerchantAccountInformation +
          IdChavePixMerchantAccountInformation;
      ChavePixMerchantAccountInformation = _chave!;
      TamChavePixMerchantAccountInformation = _chave!.length.toString();
      MerchantAccountInformation = MerchantAccountInformation +
          TamChavePixMerchantAccountInformation +
          ChavePixMerchantAccountInformation;
    });
  }

  //MerchantCategoryCode

  final String IdMerchantCategoryCode = "52";
  final String TamMerchantCategoryCode =
      "04"; //QUANTIDADE DE CARACTERES DO PRÓXIMO ITEM
  final String DataMerchantCategoryCode = "0000";
  String MerchantCategoryCode = "";

  _gerarMerchantCategoryCode() {
    setState(() {
      MerchantCategoryCode = IdMerchantCategoryCode +
          TamMerchantCategoryCode +
          DataMerchantCategoryCode;
    });
  }

  //TransactionCurrency

  final String IdTransactionCurrency = "53";
  final String TamTransactionCurrency =
      "03"; //QUANTIDADE DE CARACTERES DO PRÓXIMO ITEM
  final String ValorTransactionCurrency = "986";
  String TransactionCurrency = "";

  _gerarTransactionCurrency() {
    setState(() {
      TransactionCurrency = IdTransactionCurrency +
          TamTransactionCurrency +
          ValorTransactionCurrency;
    });
  }

  //TransactionAmount
  final String IdTransactionAmount = "54";
  String TamTransactionAmount = ""; //QUANTIDADE DE CARACTERES DO VALOR EM REAIS
  String ValorTransactionAmount = "";
  String TransactionAmount = "";

  _gerarTransactionAmount() {
    setState(() {
      if (_valor != "") {
        if (_valor!.length < 10) {
          TamTransactionAmount = 0.toString() + _valor!.length.toString();
        } else {
          TamTransactionAmount = _valor!.length.toString();
        }
        ValorTransactionAmount = _valor!;
        TransactionAmount =
            IdTransactionAmount + TamTransactionAmount + ValorTransactionAmount;
      } else {
        TransactionAmount = "";
      }
    });
  }

  //CountryCode
  final String IdCountryCode = "58";
  final String TamCountryCode = "02";
  final String DataCountryCode = "BR";

  String CountryCode = "";
  _gerarCountryCode() {
    setState(() {
      CountryCode = IdCountryCode + TamCountryCode + DataCountryCode;
    });
  }

  //MerchantName
  final String IdMerchantName = "59";
  String TamMerchantName = ""; //QUANTIDADE DE CARACTERES DO RECEBEDOR
  String DataMerchantName = "";
  String MerchantName = "";

  _gerarMerchantName() {
    setState(() {
      if (_beneficiario.length < 10) {
        TamMerchantName = 0.toString() + _beneficiario.length.toString();
      } else {
        TamMerchantName = _beneficiario.length.toString();
      }
      DataMerchantName = _beneficiario;
      MerchantName = IdMerchantName + TamMerchantName + DataMerchantName;
    });
  }

  //MerchantCity
  final String IdMerchantCity = "60";
  String TamMerchantCity = ""; //QUANTIDADE DE CARACTERES DA CIDADE
  String DataMerchantCity = "";
  String MerchantCity = "";

  _gerarMerchantCity() {
    setState(() {
      if (_cidade.length < 10) {
        TamMerchantCity = 0.toString() + _cidade.length.toString();
      } else {
        TamMerchantCity = _cidade.length.toString();
      }

      DataMerchantCity = _cidade;
      MerchantCity = IdMerchantCity + TamMerchantCity + DataMerchantCity;
    });
  }

  //AdditionalDataField
  final String IdAdditionalDataField = "62";
  String TamAdditionalDataField =
      ""; //QUANTIDADE DE CARACTERES DO PRÓXIMO ITEM, JUNTO A INDICES
  final String IdAdditionalDataFieldReferenceLabel = "05";
  String TamAdditionalDataFieldReferenceLabel =
      ""; //QUANTIDADE DE CARACTERES DA DESCRIÇÃO
  String DataAdditionalDataFieldReferenceLabel = "";
  String AdditionalDataField = "";

  int TamAdditionalDataField2 = 0;

  _gerarAdditionalDataField() {
    setState(() {
      if (_descricao.length < 10) {
        TamAdditionalDataFieldReferenceLabel =
            0.toString() + _descricao.length.toString();
      } else {
        TamAdditionalDataFieldReferenceLabel = _descricao.length.toString();
      }

      TamAdditionalDataField2 = IdAdditionalDataFieldReferenceLabel.length +
          TamAdditionalDataFieldReferenceLabel.length +
          _descricao.length;
      if (TamAdditionalDataField2 < 10) {
        TamAdditionalDataField =
            0.toString() + TamAdditionalDataField2.toString();
      } else {
        TamAdditionalDataField = TamAdditionalDataField2.toString();
      }

      DataAdditionalDataFieldReferenceLabel = _descricao;

      AdditionalDataField = IdAdditionalDataField + //62
          TamAdditionalDataField +
          IdAdditionalDataFieldReferenceLabel + //05
          TamAdditionalDataFieldReferenceLabel + //05
          DataAdditionalDataFieldReferenceLabel; //Teste
    });
  }

  //CRC16_CCITT
  final String IdCRC16_CCITT = "63";
  final String TamCRC16_CCITT = "04"; //QUANTIDADE DE CARACTERES
  String DataCRC16_CCITT = "";

  String _textoQRcodemenosCRC16CCITT = "";

  _gerartextoQRcodemenosCRC16CCITT(String valor) {
    setState(() {
      _textoQRcodemenosCRC16CCITT = valor + IdCRC16_CCITT + TamCRC16_CCITT;
    });
  }

  _gerarCRC16_CCITT(String valor) {
    setState(() {
      DataCRC16_CCITT = CRC.gerarcrc16ccittfalse(valor);
    });
  }

  String _TextoQRcodeCompleto = "";

  _gerarTextoQRcodeCompleto() {
    setState(() {
      _TextoQRcodeCompleto = _textoQRcodemenosCRC16CCITT + DataCRC16_CCITT;
    });
  }

  String? _valor;
  String? _chave;
  String _beneficiario = "NOME DO BENEFICIARIO";
  String _cidade = "CIDADE";
  String _descricao = "TESTE";
  bool QRcodeGerado = false;
  bool iscpf = false;

  String _textoQRcode = "";

  //_gerarPayloadFormatIndicator() {}

  _gerarQRcode() {
    return GerarQRcode(
      valores: _TextoQRcodeCompleto,
    );
  }

  _gerarCRC() {
    DataCRC16_CCITT = CRC.gerarcrc16ccittfalse(_textoQRcodemenosCRC16CCITT);
    _textoQRcode = _textoQRcodemenosCRC16CCITT + DataCRC16_CCITT;
  }

  _rolarParaFimScrollController() {
    Timer(const Duration(milliseconds: 100), () {
      setState(() {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

  double elevation = 2;
  double separacao = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerador de QrCode Pix"),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Center(
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(10)),
              QRcodeGerado
                  ? Container()
                  : SizedBox(
                      height: 450,
                      width: 450,
                      child: Card(
                        elevation: elevation,
                        color: const Color(0xfffcf7f7),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    Material(
                                      borderRadius: BorderRadius.circular(10),
                                      elevation: elevation,
                                      shadowColor: Colors.grey,
                                      child: TextFormField(
                                        controller: _chavePix,
                                        onSaved: (valor) {
                                          setState(() {
                                            _chave = valor!;
                                            if (_chave!.length == 11) {
                                              iscpf = true;
                                            }
                                          });
                                        },
                                        inputFormatters: iscpf
                                            ? [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                CpfInputFormatter()
                                              ]
                                            : null,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                            labelText: iscpf ? "CPF" : "Chave",
                                            fillColor: Colors.white,
                                            filled: true,
                                            hintText: "Digite a chave"),
                                        validator: (valor) {
                                          return Validador()
                                              .add(Validar.OBRIGATORIO,
                                                  msg: "Campo obrigatório")
                                              .valido(valor);
                                        },
                                      ),
                                    ),

                                    Padding(padding: EdgeInsets.all(separacao)),

                                    Material(
                                      borderRadius: BorderRadius.circular(10),
                                      elevation: elevation,
                                      shadowColor: Colors.grey,
                                      child: TextFormField(
                                        controller: _valorDoPix,
                                        keyboardType: TextInputType.number,
                                        onSaved: (valor) {
                                          _valor = valor!
                                              .replaceAll(".", "")
                                              .replaceAll(" ", "")
                                              .replaceAll(",", ".")
                                              .replaceAll("R\$", "");
                                        },
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          // RealInputFormatter(
                                          //   moeda: true,
                                          // ),
                                          CentavosInputFormatter(
                                              moeda: true, casasDecimais: 2)
                                        ],
                                        decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.blue),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            labelText: "Valor (opcional)",
                                            hintText: "Digite o valor"),
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.all(separacao)),
                                    Material(
                                      borderRadius: BorderRadius.circular(10),
                                      elevation: elevation,
                                      shadowColor: Colors.grey,
                                      child: TextFormField(
                                        //até 25 caracteres
                                        controller: _nomeBeneficiario,
                                        keyboardType: TextInputType.text,
                                        onSaved: (valor) {
                                          if (valor != "") {
                                            _beneficiario = valor!;
                                          }
                                        },
                                        decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.blue),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            labelText:
                                                "Beneficiário (opcional)",
                                            hintText:
                                                "Digite o nome do beneficiário"),
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.all(separacao)),
                                    //Até 15 caracteres
                                    Material(
                                      borderRadius: BorderRadius.circular(10),
                                      elevation: elevation,
                                      shadowColor: Colors.grey,
                                      child: TextFormField(
                                        controller: _nomeCidade,
                                        keyboardType: TextInputType.text,
                                        onSaved: (valor) {
                                          if (valor != "") {
                                            _cidade = valor!;
                                          }
                                        },
                                        decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.blue),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            labelText: "Cidade (opcional)",
                                            hintText: "Digite a cidade"),
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.all(separacao)),
                                    //Até 20 caracteres
                                    Material(
                                      borderRadius: BorderRadius.circular(10),
                                      elevation: elevation,
                                      shadowColor: Colors.grey,
                                      child: TextFormField(
                                        controller: _descricaoTransferencia,
                                        keyboardType: TextInputType.text,
                                        onSaved: (valor) {
                                          if (valor != "") {
                                            _descricao = valor!;
                                          }
                                        },
                                        decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.blue),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            labelText: "Descrição (opcional)",
                                            hintText: "Digite uma descrição"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(padding: EdgeInsets.all(separacao)),
                            ],
                          ),
                        ),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: QRcodeGerado
                    ? ElevatedButton(
                        onPressed: () {
                          setState(() {
                            QRcodeGerado = false;
                          });
                        },
                        child: const Text(
                          "Gerar outro QR code",
                          style: TextStyle(),
                        ))
                    : SizedBox(
                        width: 450,
                        height: 100,
                        child: Card(
                          elevation: elevation,
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: elevation,
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  _gerarPayloadFormatIndicator();
                                  _gerarMerchantAccountInformation();
                                  _gerarMerchantCategoryCode();
                                  _gerarTransactionCurrency();
                                  _gerarTransactionAmount();
                                  _gerarCountryCode();
                                  _gerarMerchantName();
                                  _gerarMerchantCity();
                                  _gerarAdditionalDataField();
                                  setState(() {
                                    _textoQRcode = PayloadFormatIndicator +
                                        MerchantAccountInformation +
                                        MerchantCategoryCode +
                                        TransactionCurrency +
                                        TransactionAmount +
                                        CountryCode +
                                        MerchantName +
                                        MerchantCity +
                                        AdditionalDataField;
                                    QRcodeGerado = true;
                                  });
                                  _gerartextoQRcodemenosCRC16CCITT(
                                      _textoQRcode);
                                  _gerarCRC16_CCITT(
                                      _textoQRcodemenosCRC16CCITT);
                                  _gerarTextoQRcodeCompleto();
                                  _gerarQRcode();
                                  _rolarParaFimScrollController();
                                }
                              },
                              child: QRcodeGerado
                                  ? const Text(
                                      "Gerar outro QRCode",
                                      style: TextStyle(),
                                    )
                                  : const Text(
                                      "Gerar QRCode",
                                      style: TextStyle(),
                                    ),
                            ),
                          ),
                        ),
                      ),
              ),
              QRcodeGerado
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              // Padding(
                              //   padding: EdgeInsets.all(8.0),
                              //   child: Center(
                              //     child: Text(_TextoQRcodeCompleto),
                              //   ),
                              // ),
                              Container(
                                child:
                                    QRcodeGerado ? _gerarQRcode() : Container(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
