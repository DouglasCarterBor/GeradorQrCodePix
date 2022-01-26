class ConversorBases {
  static String toHexadecimal(int value) {
    var lista = [];
    int i = 0;

    while (value > 0) {
      lista.add(value % 16);
      value = (value ~/ 16);
      i++;
    }
    var hexadecimal = lista.reversed.toString();
    return hexadecimal
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .replaceAll('10', 'A')
        .replaceAll('11', 'B')
        .replaceAll('12', 'C')
        .replaceAll('13', 'D')
        .replaceAll('14', 'E')
        .replaceAll('15', 'F');
  }
}
