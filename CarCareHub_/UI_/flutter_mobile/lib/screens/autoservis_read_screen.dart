import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/autoservis.dart';
import 'package:flutter_mobile/models/chatAutoservisKlijent.dart';
import 'package:flutter_mobile/models/chatKlijentZaposlenik.dart';
import 'package:flutter_mobile/models/usluge.dart';
import 'package:flutter_mobile/models/zaposlenik.dart';
import 'package:flutter_mobile/models/grad.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/autoservis_provider.dart';
import 'package:flutter_mobile/provider/chatAutoservisKlijent_provider.dart';
import 'package:flutter_mobile/provider/chatKlijentZaposlenik_provider.dart';
import 'package:flutter_mobile/provider/usluge_provider.dart';
import 'package:flutter_mobile/provider/zaposlenik_provider.dart';
import 'package:flutter_mobile/provider/grad_provider.dart';
import 'package:flutter_mobile/screens/autoservis_details_screen.dart';
import 'package:provider/provider.dart';

class AutoservisReadScreen extends StatefulWidget {
  final Autoservis? autoservis;

  const AutoservisReadScreen({super.key, this.autoservis});

  @override
  State<AutoservisReadScreen> createState() => _AutoservisReadScreenState();
}

class _AutoservisReadScreenState extends State<AutoservisReadScreen> {
  File? _imageFile;
  List<Usluge> usluge = [];
  List<Zaposlenik> zaposlenik = [];
  bool isLoading = true;

  late UslugeProvider _uslugaProvider;
  late ZaposlenikProvider _zaposlenikProvider;

  @override
  void initState() {
    super.initState();
    _uslugaProvider = context.read<UslugeProvider>();
    _zaposlenikProvider = context.read<ZaposlenikProvider>();

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);

    try {
      if (widget.autoservis?.slikaProfila != null) {
        _imageFile =
            await _getImageFileFromBase64(widget.autoservis!.slikaProfila!);
      }

      usluge =
          await _uslugaProvider.getById(widget.autoservis?.autoservisId ?? 0);

      if (widget.autoservis?.autoservisId != null) {
        zaposlenik = await _zaposlenikProvider
            .getzaposlenikById(widget.autoservis!.autoservisId!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri učitavanju podataka: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<File> _getImageFileFromBase64(String base64String) async {
    final bytes = base64Decode(base64String);
    final tempDir = await Directory.systemTemp.createTemp();
    final file = File('${tempDir.path}/image.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 204, 204, 204),
      appBar: AppBar(
        title: Text(widget.autoservis?.naziv ?? "Detalji autoservisa"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildAutoservisHeader(),
                  const SizedBox(height: 24),
                  _buildServiceDetailsCard(),
                  const SizedBox(height: 16),
                  _buildServicesSection(),
                  const SizedBox(height: 16),
                  _buildEmployeesSection(),
                ],
              ),
            ),
      floatingActionButton: _buildEditButton(),
    );
  }

  Widget _buildAutoservisHeader() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          child: _imageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                )
              : const Icon(Icons.business, size: 60, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.autoservis?.naziv ?? "",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (context.read<UserProvider>().role == "Klijent")
                ElevatedButton.icon(
                  icon: const Icon(Icons.message, size: 18),
                  label: const Text("Poruka"),
                  onPressed: () => _showSendMessageDialog(
                    context,
                    context.read<UserProvider>().userId,
                    widget.autoservis!.autoservisId!,
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceDetailsCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Table(
          columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(2)},
          children: [
            _buildTableRow("Vlasnik:", widget.autoservis?.vlasnikFirme),
            _buildTableRow("Adresa:", widget.autoservis?.adresa),
            _buildTableRow("Grad:", widget.autoservis?.grad?.nazivGrada),
            _buildTableRow("Telefon:", widget.autoservis?.telefon),
            _buildTableRow("Email:", widget.autoservis?.email),
            _buildTableRow("JIB:", widget.autoservis?.jib),
            _buildTableRow("MBS:", widget.autoservis?.mbs),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String? value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(value ?? 'N/A'),
        ),
      ],
    );
  }

  Widget _buildServicesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 15),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Usluge",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          usluge.isEmpty
              ? const Text(
                  "Nema dostupnih usluga",
                  style: TextStyle(color: Colors.grey),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: usluge.length,
                  itemBuilder: (context, index) {
                    final usluga = usluge[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(
                          usluga.nazivUsluge ?? "",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(usluga.opis ?? ""),
                        trailing: Text(
                          "${usluga.cijena?.toStringAsFixed(2) ?? ""} KM",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmployeesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 15),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Zaposlenici",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          zaposlenik.isEmpty
              ? const Text(
                  "Nema zaposlenika",
                  style: TextStyle(color: Colors.grey),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: zaposlenik.length,
                  itemBuilder: (context, index) {
                    final zap = zaposlenik[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(
                          "${zap.ime} ${zap.prezime}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(zap.email ?? ""),
                            Text(zap.brojTelefona ?? ""),
                          ],
                        ),
                        trailing: context.read<UserProvider>().role == "Klijent"
                            ? IconButton(
                                icon: const Icon(Icons.message),
                                onPressed: () => _showSendMessageDialog2(
                                  context,
                                  context.read<UserProvider>().userId,
                                  zap.zaposlenikId!,
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    final userProvider = context.read<UserProvider>();
    if (userProvider.role == "Admin" ||
        (userProvider.role == "Autoservis" &&
            userProvider.userId == widget.autoservis?.autoservisId)) {
      return FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AutoservisDetailsScreen(
              autoservis: widget.autoservis!,
            ),
          ),
        ).then((_) => _loadInitialData()),
        backgroundColor: Colors.red,
        child: const Icon(Icons.edit),
      );
    }
    return const SizedBox();
  }

  void _showSendMessageDialog(
      BuildContext context, int klijentId, int autoservisId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String message = "";
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Pošalji poruku",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Unesite poruku...",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => message = value,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      child: const Text("Otkaži"),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      child: const Text("Pošalji"),
                      onPressed: () async {
                        if (message.isNotEmpty) {
                          try {
                            await Provider.of<ChatAutoservisKlijentProvider>(
                              context,
                              listen: false,
                            ).sendMessage(klijentId, autoservisId, message);

                            if (mounted) Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Poruka poslana uspješno"),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Greška: ${e.toString()}"),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Poruka ne može biti prazna"),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showSendMessageDialog2(
      BuildContext context, int klijentId, int zaposleniId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String message = "";
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Pošalji poruku zaposleniku",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Unesite poruku...",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => message = value,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      child: const Text("Otkaži"),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      child: const Text("Pošalji"),
                      onPressed: () async {
                        if (message.isNotEmpty) {
                          try {
                            await Provider.of<ChatKlijentZaposlenikProvider>(
                              context,
                              listen: false,
                            ).sendMessage(klijentId, zaposleniId, message);

                            if (mounted) Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Poruka poslana uspješno"),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Greška: ${e.toString()}"),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Poruka ne može biti prazna"),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
