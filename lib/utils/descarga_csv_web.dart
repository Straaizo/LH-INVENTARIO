import 'dart:html' as html;
import 'dart:typed_data';

/// Descarga un archivo en el navegador (solo Web).
void descargarCsvWeb(Uint8List bytes, String fileName) {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)..setAttribute('download', fileName);
  anchor.click();
  html.Url.revokeObjectUrl(url);
}
