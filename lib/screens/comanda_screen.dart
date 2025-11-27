import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/pedidos.dart';
import 'package:intl/intl.dart';

class ComandaScreen extends StatefulWidget {
  final Pedido pedido;
  const ComandaScreen({super.key, required this.pedido});

  @override
  State<ComandaScreen> createState() => _ComandaScreenState();
}

class _ComandaScreenState extends State<ComandaScreen> {
  bool _loading = false;
  String? _uploadedUrl;

  Future<String> _uploadPdf(Uint8List bytes, String filename) async {
    final ref = FirebaseStorage.instance.ref().child('comandas/$filename');
    final meta = SettableMetadata(contentType: 'application/pdf');
    final task = await ref.putData(bytes, meta);
    final url = await task.ref.getDownloadURL();
    return url;
  }

  Future<Uint8List> _buildPdfBytes(Pedido pedido) async {
    final pdf = pw.Document();
    final now = DateTime.fromMillisecondsSinceEpoch(pedido.timestamp);
    final fecha = DateFormat('dd/MM/yyyy – HH:mm').format(now);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  "PIZZABROSA",
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text("Fecha: $fecha"),
              pw.SizedBox(height: 6),
              pw.Text(
                "Cliente: ${pedido.clienteNombre.isEmpty ? 'Sin nombre' : pedido.clienteNombre}",
              ),
              if (pedido.clienteCel.isNotEmpty)
                pw.Text("Tel: ${pedido.clienteCel}"),
              if (pedido.clienteDireccion.isNotEmpty)
                pw.Text("Dir: ${pedido.clienteDireccion}"),
              pw.Divider(),
              pw.Text(
                "Items:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 6),
              ...pedido.items.map((i) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("- ${i.paquete} - ${i.tamano}"),
                    if (i.notas.isNotEmpty) pw.Text("  Notas: ${i.notas}"),
                    pw.SizedBox(height: 4),
                  ],
                );
              }).toList(),
              pw.SizedBox(height: 14),
              pw.Text("Observaciones: "),
              pw.SizedBox(height: 30),
              pw.Center(
                child: pw.Text(
                  "Gracias por su preferencia",
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _generarYSubir() async {
    setState(() {
      _loading = true;
      _uploadedUrl = null;
    });

    try {
      final bytes = await _buildPdfBytes(widget.pedido);
      final filename =
          (widget.pedido.id ??
              DateTime.now().millisecondsSinceEpoch.toString()) +
          '.pdf';
      final url = await _uploadPdf(bytes, filename);

      setState(() {
        _uploadedUrl = url;
      });

      // Opcional: abrir preview usando printing
      await Printing.layoutPdf(onLayout: (format) => bytes);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Comanda subida. URL: $url')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generando comanda: $e')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedido = widget.pedido;
    final fecha = DateFormat(
      'dd/MM/yyyy – HH:mm',
    ).format(DateTime.fromMillisecondsSinceEpoch(pedido.timestamp));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comanda'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Cliente: ${pedido.clienteNombre.isEmpty ? 'Sin nombre' : pedido.clienteNombre}',
            ),
            const SizedBox(height: 6),
            Text('Tel: ${pedido.clienteCel.isEmpty ? '-' : pedido.clienteCel}'),
            const SizedBox(height: 6),
            Text('Fecha: $fecha'),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: pedido.items.map((i) {
                  return ListTile(
                    title: Text('${i.paquete} - ${i.tamano}'),
                    subtitle: i.notas.isNotEmpty
                        ? Text('Notas: ${i.notas}')
                        : null,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading) const CircularProgressIndicator(),
            if (!_loading)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _generarYSubir,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Generar & Subir PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            if (_uploadedUrl != null) ...[
              const SizedBox(height: 8),
              SelectableText('URL: $_uploadedUrl'),
            ],
          ],
        ),
      ),
    );
  }
}
