import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/BPAutodijeloviAutoservis.dart';
import 'package:flutter_mobile/models/narudzba_stavke.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/BPAutodijeloviAutoservis_provider.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/autoservis_provider.dart';
import 'package:flutter_mobile/provider/klijent_provider.dart';
import 'package:flutter_mobile/provider/narudzba_stavka_provider.dart';
import 'package:flutter_mobile/provider/product_provider.dart';
import 'package:flutter_mobile/provider/zaposlenik_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';


class NarudzbaStavkaScreen extends StatefulWidget {
  final int narudzbaId;

  const NarudzbaStavkaScreen({super.key, required this.narudzbaId});

  @override
  State<NarudzbaStavkaScreen> createState() => _NarudzbaStavkaScreenState();
}

class _NarudzbaStavkaScreenState extends State<NarudzbaStavkaScreen> {
  SearchResult<NarudzbaStavke>? result;
  bool _isLoading = false;
  String? _errorMessage;
late AutoservisProvider _autoservisProvider;
late KlijentProvider _klijentProvider;
late ZaposlenikProvider _zaposlenikProvider;


  @override
  void initState() {
    super.initState();
    _autoservisProvider = context.read<AutoservisProvider>();
    _zaposlenikProvider = context.read<ZaposlenikProvider>();
    _klijentProvider = context.read<KlijentProvider>();




    WidgetsBinding.instance.addPostFrameCallback((_) {

      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = Provider.of<NarudzbaStavkeProvider>(
        context,
        listen: false,
      );
      final data = await provider.getStavkeZaNarudzbu(widget.narudzbaId);
      setState(() {
        result = data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Detalji narudžbe",
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : result == null || result!.result.isEmpty
                  ? const Center(child: Text('Nema stavki za prikaz'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildOrderHeader(),
                          const SizedBox(height: 24),
                          _buildProductsTable(),
                          const SizedBox(height: 24),
                          _buildOrderSummary(),
                          const SizedBox(height: 24),
                          _buildStatusIndicator(),
                        ],
                      ),
                    ),
    );
  }
  Widget _buildOrderHeader() {
  final firstItem = result!.result.first;
  final dateFormat = DateFormat('dd/MM/yyyy');
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Detalji narudžbe:",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      
      // Display orderer information
      _buildOrdererInfo(firstItem),
      
      _buildDetailRow(
        "Datum narudžbe:", 
        dateFormat.format(firstItem.narudzba?.datumNarudzbe ?? DateTime.now())
      ),
      if (firstItem.narudzba?.adresa != null)
        _buildDetailRow("Adresa:", firstItem.narudzba!.adresa!),
    ],
  );
}
Widget _buildOrdererInfo(dynamic firstItem) {
  // Check for autoservis first
  if (firstItem.narudzba?.autoservisId != null) {
    final autoservisId = firstItem.narudzba!.autoservisId!;
    return FutureBuilder(
      future: _autoservisProvider.getById(autoservisId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildDetailRow("Autoservis:", "Učitavanje...");
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildDetailRow("Autoservis:", "AC Herc - autoservis");
        }
        final autoservis = snapshot.data!.first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Autoservis:", autoservis.naziv ?? "AC Herc - autoservis"),
            if (autoservis.adresa != null) 
              _buildDetailRow("Adresa servisa:", autoservis.adresa!),
          ],
        );
      },
    );
  }
  // Check for zaposlenik (with ID)
  else if (firstItem.narudzba?.zaposlenikId != null) {
    final zaposlenikId = firstItem.narudzba!.zaposlenikId!;
    return FutureBuilder(
      future: _zaposlenikProvider.getById(zaposlenikId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildDetailRow("Zaposlenik:", "Učitavanje...");
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildDetailRow("Zaposlenik:", "Radnik1");
        }
        final zaposlenik = snapshot.data!.first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              "Zaposlenik:",
              "${zaposlenik.ime ?? ''} ${zaposlenik.prezime ?? ''}".trim().isEmpty 
                  ? "Radnik1" 
                  : "${zaposlenik.ime ?? ''} ${zaposlenik.prezime ?? ''}".trim(),
            ),
            if (zaposlenik.email != null)
              _buildDetailRow("Email:", zaposlenik.email!),
            if (zaposlenik.brojTelefona != null)
              _buildDetailRow("Telefon:", zaposlenik.brojTelefona!),
          ],
        );
      },
    );
  }
  // Check for klijent (with ID)
  else if (firstItem.narudzba?.klijentId != null) {
    final klijentId = firstItem.narudzba!.klijentId!;
    return FutureBuilder(
      future: _klijentProvider.getById(klijentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildDetailRow("Klijent:", "Učitavanje...");
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildDetailRow("Klijent:", "Klijent");
        }
        final klijent = snapshot.data!.first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              "Klijent:",
              "${klijent.ime ?? ''} ${klijent.prezime ?? ''}".trim().isEmpty
                  ? "Klijent"
                  : "${klijent.ime ?? ''} ${klijent.prezime ?? ''}".trim(),
            ),
            if (klijent.email != null)
              _buildDetailRow("Email:", klijent.email!),
            if (klijent.brojTelefona != null)
              _buildDetailRow("Telefon:", klijent.brojTelefona!),
          ],
        );
      },
    );
  }
  // Default case
  else {
    return _buildDetailRow("Naručilac:", "Nepoznato");
  }
}
Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(value),
      ],
    ),
  );
}

Widget _buildProductsTable() {
     var isAutoservisUser = context.read<UserProvider>().role != "Klijent";

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Proizvodi:",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),

Table(
  border: TableBorder.all(color: Colors.grey.shade300),
  columnWidths: {
    0: const FlexColumnWidth(3),
    1: const FlexColumnWidth(1),
    2: const FlexColumnWidth(1),
    3: const FlexColumnWidth(1.3),
    if (isAutoservisUser) 4: const FlexColumnWidth(1.5),
  },
  children: [
    TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade200),
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text("Naziv", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text("Količina", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text("Osnovna", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text("Popust", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        if (isAutoservisUser)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text("Za autoservise", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
      ],
    ),
          ...result!.result.map((stavka) {
            final kolicina = stavka.kolicina ?? 1;
            final basePrice = stavka.proizvod?.cijena ?? 0.0;
            final discountPrice = stavka.proizvod?.cijenaSaPopustom;
            final autoservicePrice = stavka.proizvod?.cijenaSaPopustomZaAutoservis;
            
            final hasRegularDiscount = discountPrice != null && discountPrice < basePrice;
            final hasAutoserviceDiscount = autoservicePrice != null && autoservicePrice < basePrice;
            
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(stavka.proizvod?.naziv ?? "Nepoznato"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Center(child: Text(kolicina.toString())),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(_formatCurrency(basePrice * kolicina)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    hasRegularDiscount 
                      ? _formatCurrency(discountPrice * kolicina)
                      : "Nema",
                    style: TextStyle(
                      color: hasRegularDiscount ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
                 if (isAutoservisUser)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    hasAutoserviceDiscount
                      ? _formatCurrency(autoservicePrice * kolicina)
                      : "Nema",
                    style: TextStyle(
                      color: hasAutoserviceDiscount ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    ],
  );
}

String _formatCurrency(double amount) {
  return '${amount.toStringAsFixed(2).replaceAll('.', ',')} KM';
}
  Widget _buildOrderSummary() {
    final firstItem = result!.result.first;
    final ukupnaCijena = firstItem.narudzba?.ukupnaCijenaNarudzbe ?? 0;
    
    final total = ukupnaCijena ;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryRow("Ukupna cijena:", "${ukupnaCijena.toStringAsFixed(2)} KM"),
       
        const Divider(thickness: 1),
        _buildSummaryRow(
          "Total:",
          "${total.toStringAsFixed(2)} KM",
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final isCompleted = result!.result.first.narudzba?.zavrsenaNarudzba ?? false;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          isCompleted ? "Narudžba poslana" : "Narudžba u obradi",
          style: TextStyle(
            color: isCompleted ? Colors.green : Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}