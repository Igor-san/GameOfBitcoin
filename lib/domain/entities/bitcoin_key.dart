import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:equatable/equatable.dart';
import 'package:game_of_bitcoin/crypto/utils.dart';

class BitcoinKey extends Equatable {
  final BigInt bigIntKey;
  final BasedUtxoNetwork network;
  final ECPrivate privateKey;
  late final ECPublic publicKey;

  BitcoinKey({
    required this.bigIntKey,
    required this.privateKey,
    this.network = BitcoinNetwork.mainnet,
  }): publicKey = privateKey.getPublic();

  factory BitcoinKey.fromBits(List<int> bits) {
    try{
      var bytes = bitsToBytes(bits);
      var privateKey = ECPrivate.fromBytes(bytes);
      var bigInt = bitsToBigInt(bits);

      return BitcoinKey(bigIntKey: bigInt, privateKey: privateKey);

    } catch(ex){
      //Если все 0 подать то AffinePointt does not lay on the curve
      throw ArgumentError('Unexpected error while create BitcoinKey: $ex');
    }
  }

  ///value - строковое представление десятичного ключа
  factory BitcoinKey.parseInt(String value) {
    try{
      BigInt bigInt =BigInt.parse(value, radix: 10);
      var bytes = bigIntToUint8List(bigInt);
      var privateKey = ECPrivate.fromBytes(bytes);

      return BitcoinKey(bigIntKey: bigInt, privateKey: privateKey);

    } catch(ex){
      throw ArgumentError('Unexpected error while create BitcoinKey: $ex');
    }
  }

  String get ripemd160compressed => publicKey.toHash160(mode: PublicKeyType.compressed);
  String get ripemd160uncompressed => publicKey.toHash160(mode: PublicKeyType.uncompressed);
  String get p2PKHcompressed => publicKey.toP2pkAddress(mode: PublicKeyType.compressed).toAddress(network);
  String get p2PKHuncompressed => publicKey.toP2pkAddress(mode: PublicKeyType.uncompressed).toAddress(network);

  String get segwitAddress => publicKey.toSegwitAddress().toAddress(network);

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('key ${bigIntKey} \n');
    buffer.write('privateKey.toHex ${ privateKey.toHex()} \n');
    buffer.write('privateKey.toWif ${ privateKey.toWif()} \n');
    buffer.write('address ${ publicKey.toAddress().toAddress(network)} \n');

    return buffer.toString();
  }
  @override
  List<Object> get props {
    return [bigIntKey, network, privateKey];
  }

}