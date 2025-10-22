import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // para compute

Future<String> imageFileToBase64(File file) async {
  // Ler bytes de forma assíncrona para não bloquear a UI
  final bytes = await file.readAsBytes();
  // Codificar em base64 (pode ser feito em isolate para imagens grandes)
  return await compute(base64Encode, bytes);
}