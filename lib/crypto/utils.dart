import 'dart:typed_data';

import 'package:bitcoin_base/bitcoin_base.dart';

BasedUtxoNetwork network = BitcoinNetwork.mainnet;

Uint8List bigIntToUint8List(final BigInt bigInt) {
  //https://stackoverflow.com/questions/61075549/bigint-to-bytes-array-in-dart
  final length = 32; //чтобы получить 32 элемента в Uint8List

  final data = ByteData((length).ceil());
  var _bigInt = bigInt;

  for (var i = 1; i <= data.lengthInBytes; i++) {
    data.setUint8(data.lengthInBytes - i, _bigInt.toUnsigned(8).toInt());
    _bigInt = _bigInt >> 8;
  }

  return data.buffer.asUint8List();

}

int assembleBits(Uint8List byte) {
  if (byte.length != 8) {
    throw Exception('byte_incorrect_size');
  }
  int assembled = 0;
  for (int i = 0; i < 8; ++i) {
    if (byte[i] != 1 && byte[i] != 0) {
      throw Exception('bit_not_0_or_1');
    }
    assembled = assembled << 1;
    assembled = assembled | byte[i];
  }
  return assembled;
}

///Преобразуем список из 256 0 и 1 в список из 32 байтов, принимает и Uint8List
Uint8List bitsToBytes(List<int> bits) {
  assert(bits.length == 256, "Поддерживается только 256 элементов");
  int byteCnt = bits.length ~/ 8;
  Uint8List byteMsg = Uint8List(byteCnt);
  for (int i = 0; i < byteCnt; ++i) {
    Uint8List bitsOfByte = Uint8List.fromList(bits.getRange(i * 8, i * 8 + 8).toList());
    int byte = assembleBits(bitsOfByte);
    byteMsg[i] = byte;
  }
  return byteMsg;
}

///Тут из списка Битов!, принимает и Uint8List
BigInt bitsToBigInt(List<int> bits) {
  //Т.е. сначала нужно биты (Список 256 из 1 и 0) преобразовать в байты (Список 32 из 0...255) а уж потом в BigInt
  Uint8List list = bitsToBytes(bits);
  return  bytesToBigInt(list);
}

//https://github.com/dart-lang/sdk/issues/32803
///Тут из списка Байтов!
BigInt bytesToBigInt(Uint8List bytes) {
  BigInt result = BigInt.zero;

  for (final byte in bytes) {
// reading in big-endian, so we essentially concat the new byte to the end
    result = (result << 8) | BigInt.from(byte & 0xff);
  }
  return result;
}

///Преобразуем байт в биты в виде Uint8List
Uint8List byteToBits(int input) {

  Uint8List bytes = Uint8List(8);
  if (input<=0) return bytes; //особый случай 0, отрицательные не используем

  int i = 7;//тут младший бит справа
  while(input > 0) {
    var rem = input % 2;
    bytes[i]= rem;
    input = (input/2).floor();
    i--; //тут младший бит справа
  }
  return bytes;
}
///Преобразуем список из 32 байтов (0...255) в список из 256 0 и 1
Uint8List bytesToBits(Uint8List bytes) {
 final length = bytes.length;
  assert(length == 32, "Только для 32 элементов");
  final result = Uint8List(length * 8);
  for (var i = 0; i < length; i++) {
    Uint8List bits = byteToBits(bytes[i]);
    for (var j=0; j< 8; j++){
      result[i*8 + j] =  bits[j];
    }
  }
  return result;
}

//https://stackoverflow.com/questions/67409300/how-convert-function-byte-to-dart
// The hex representation of the first [length] bytes of [bytes].
String toHex(Uint8List bytes, int length) {
  const hexDigits = "0123456789ABCDEF";
  final resultBytes = Uint8List(length * 2);
  if (length > bytes.length) length = bytes.length;
  for (var i = 0, j = 0; i < length; i++) {
    var byte = bytes[i];
    resultBytes[j++] = hexDigits.codeUnitAt(byte >> 4);
    resultBytes[j++] = hexDigits.codeUnitAt(byte & 15);
  }
  return String.fromCharCodes(resultBytes);
}
