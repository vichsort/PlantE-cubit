import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

Future<String> imageFileToBase64(File file) async {
  final bytes = await file.readAsBytes();
  return await compute(base64Encode, bytes);
}
