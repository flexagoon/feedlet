import 'dart:convert';
import 'dart:typed_data';

import 'package:enough_convert/enough_convert.dart';

const _encodings = {
  'latin1': Latin1Decoder(allowInvalid: true),
  'latin2': Latin2Decoder(allowInvalid: true),
  'latin3': Latin3Decoder(allowInvalid: true),
  'latin4': Latin4Decoder(allowInvalid: true),
  'latin5': Latin5Decoder(allowInvalid: true),
  'latin6': Latin6Decoder(allowInvalid: true),
  'latin7': Latin7Decoder(allowInvalid: true),
  'latin8': Latin8Decoder(allowInvalid: true),
  'latin9': Latin9Decoder(allowInvalid: true),
  'latin10': Latin10Decoder(allowInvalid: true),
  'latin11': Latin11Decoder(allowInvalid: true),
  'latin13': Latin13Decoder(allowInvalid: true),
  'latin14': Latin14Decoder(allowInvalid: true),
  'latin15': Latin15Decoder(allowInvalid: true),
  'latin16': Latin16Decoder(allowInvalid: true),
  'iso-8859-1': Latin1Decoder(allowInvalid: true),
  'iso-8859-2': Latin2Decoder(allowInvalid: true),
  'iso-8859-3': Latin3Decoder(allowInvalid: true),
  'iso-8859-4': Latin4Decoder(allowInvalid: true),
  'iso-8859-5': Latin5Decoder(allowInvalid: true),
  'iso-8859-6': Latin6Decoder(allowInvalid: true),
  'iso-8859-7': Latin7Decoder(allowInvalid: true),
  'iso-8859-8': Latin8Decoder(allowInvalid: true),
  'iso-8859-9': Latin9Decoder(allowInvalid: true),
  'iso-8859-10': Latin10Decoder(allowInvalid: true),
  'iso-8859-11': Latin11Decoder(allowInvalid: true),
  'iso-8859-13': Latin13Decoder(allowInvalid: true),
  'iso-8859-14': Latin14Decoder(allowInvalid: true),
  'iso-8859-15': Latin15Decoder(allowInvalid: true),
  'iso-8859-16': Latin16Decoder(allowInvalid: true),
  'windows-1250': Windows1250Decoder(allowInvalid: true),
  'windows-1251': Windows1251Decoder(allowInvalid: true),
  'windows-1252': Windows1252Decoder(allowInvalid: true),
  'windows-1253': Windows1253Decoder(allowInvalid: true),
  'windows-1254': Windows1254Decoder(allowInvalid: true),
  'windows-1256': Windows1256Decoder(allowInvalid: true),
  'koi8-r': Koi8rDecoder(allowInvalid: true),
  'koi8-u': Koi8uDecoder(allowInvalid: true),
};

String fixEncoding(Uint8List bytes, String oldEncoding) {
  final decoder = _encodings[oldEncoding] ?? const Utf8Decoder();

  return decoder.convert(bytes);
}
