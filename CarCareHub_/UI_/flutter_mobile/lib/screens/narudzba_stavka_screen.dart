// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/BPAutodijeloviAutoservis.dart';
import 'package:flutter_mobile/models/narudzba_stavke.dart';
import 'package:flutter_mobile/models/search_result.dart';
import 'package:flutter_mobile/provider/bpautodijelovi_autoservis_provider.dart';
import 'package:flutter_mobile/provider/user_provider.dart';
import 'package:flutter_mobile/provider/autoservis_provider.dart';
import 'package:flutter_mobile/provider/klijent_provider.dart';
import 'package:flutter_mobile/provider/narudzba_stavka_provider.dart';
import 'package:flutter_mobile/provider/product_provider.dart';
import 'package:flutter_mobile/provider/zaposlenik_provider.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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

  Future<List<int>> _getAutoservisIdsForFirma(int firmaId) async {
    try {
      final provider = Provider.of<BPAutodijeloviAutoservisProvider>(
        context,
        listen: false,
      );
      
      final filterParams = {
        'IsAllIncluded': 'true',
        'AutodijeloviID': firmaId.toString(),
      };
      
      final result = await provider.get(filter: filterParams);
      return result.result
          .where((e) => e.autoservis?.autoservisId != null)
          .map((e) => e.autoservis!.autoservisId!)
          .toList();
    } catch (e) {
      print("Error fetching autoservis IDs: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
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
                          _buildOrderHeader(isMobile),
                          const SizedBox(height: 16),
                          isMobile 
                            ? _buildMobileProductsList()
                            : _buildProductsTable(),
                          const SizedBox(height: 16),
                          _buildOrderSummary(),
                          const SizedBox(height: 16),
                          _buildStatusIndicator(),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildOrderHeader(bool isMobile) {
    final firstItem = result!.result.first;
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Detalji narudžbe:",
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 12),
        _buildOrdererInfo(firstItem, isMobile),
        _buildDetailRow(
          "Datum narudžbe:", 
          dateFormat.format(firstItem.narudzba?.datumNarudzbe ?? DateTime.now()),
          isMobile: isMobile
        ),
        if (firstItem.narudzba?.adresa != null)
          _buildDetailRow("Adresa:", firstItem.narudzba!.adresa!, isMobile: isMobile),
      ],
    );
  }

  Widget _buildOrdererInfo(dynamic firstItem, bool isMobile) {
    if (firstItem.narudzba?.autoservisId != null) {
      final autoservisId = firstItem.narudzba!.autoservisId!;
      return FutureBuilder(
        future: _autoservisProvider.getById(autoservisId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildDetailRow("Autoservis:", "Učitavanje...", isMobile: isMobile);
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildDetailRow("Autoservis:", "AC Herc - autoservis", isMobile: isMobile);
          }
          final autoservis = snapshot.data!.first;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow("Autoservis:", autoservis.naziv ?? "AC Herc - autoservis", isMobile: isMobile),
              if (autoservis.adresa != null) 
                _buildDetailRow("Adresa servisa:", autoservis.adresa!, isMobile: isMobile),
            ],
          );
        },
      );
    }
    else if (firstItem.narudzba?.zaposlenikId != null) {
      final zaposlenikId = firstItem.narudzba!.zaposlenikId!;
      return FutureBuilder(
        future: _zaposlenikProvider.getById(zaposlenikId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildDetailRow("Zaposlenik:", "Učitavanje...", isMobile: isMobile);
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildDetailRow("Zaposlenik:", "Radnik1", isMobile: isMobile);
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
                isMobile: isMobile
              ),
              if (zaposlenik.email != null)
                _buildDetailRow("Email:", zaposlenik.email!, isMobile: isMobile),
              if (zaposlenik.brojTelefona != null)
                _buildDetailRow("Telefon:", zaposlenik.brojTelefona!, isMobile: isMobile),
            ],
          );
        },
      );
    }
    else if (firstItem.narudzba?.klijentId != null) {
      final klijentId = firstItem.narudzba!.klijentId!;
      return FutureBuilder(
        future: _klijentProvider.getById(klijentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildDetailRow("Klijent:", "Učitavanje...", isMobile: isMobile);
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildDetailRow("Klijent:", "Klijent", isMobile: isMobile);
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
                isMobile: isMobile
              ),
              if (klijent.email != null)
                _buildDetailRow("Email:", klijent.email!, isMobile: isMobile),
              if (klijent.brojTelefona != null)
                _buildDetailRow("Telefon:", klijent.brojTelefona!, isMobile: isMobile),
            ],
          );
        },
      );
    }
    else {
      return _buildDetailRow("Naručilac:", "Nepoznato", isMobile: isMobile);
    }
  }

  Widget _buildDetailRow(String label, String value, {bool isMobile = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(value),
                const SizedBox(height: 8),
              ],
            )
          : Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Flexible(child: Text(value)),
              ],
            ),
    );
  }

  Widget _buildMobileProductsList() {
    var isAutoservisUser = context.read<UserProvider>().role != "Klijent" && 
                          context.read<UserProvider>().role != "Zaposlenik";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Proizvodi:",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: result!.result.length,
          itemBuilder: (context, index) {
            final stavka = result!.result[index];
            final kolicina = stavka.kolicina ?? 1;
            final basePrice = stavka.proizvod?.cijena ?? 0.0;
            final firmaId = stavka.proizvod?.firmaAutodijelovaID;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stavka.proizvod?.naziv ?? "Nepoznato",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildMobileProductDetailRow("Količina:", kolicina.toString()),
                    _buildMobileProductDetailRow("Osnovna cijena:", _formatCurrency(basePrice)),
                    
                
                    if (stavka.proizvod?.cijenaSaPopustom != null && 
                        stavka.proizvod!.cijenaSaPopustom! < basePrice)
                      _buildMobileProductDetailRow(
                        "Cijena s popustom:", 
                        _formatCurrency(stavka.proizvod!.cijenaSaPopustom!),
                        isDiscount: true
                      ),
                    
            
                    if (isAutoservisUser && 
                        stavka.proizvod?.cijenaSaPopustomZaAutoservis != null &&
                        stavka.proizvod!.cijenaSaPopustomZaAutoservis! < basePrice)
                      FutureBuilder<List<int>>(
                        future: firmaId != null ? _getAutoservisIdsForFirma(firmaId) : Future.value([]),
                        builder: (context, snapshot) {
                          final narudzbaAutoservisId = stavka.narudzba?.autoservisId;
                          final isLinked = snapshot.hasData && 
                                          narudzbaAutoservisId != null && 
                                          snapshot.data!.contains(narudzbaAutoservisId);
                          
                          return _buildMobileProductDetailRow(
                            "Cijena za autoservise:", 
                            _formatCurrency(stavka.proizvod!.cijenaSaPopustomZaAutoservis!),
                            isAutoservice: true,
                            isLinked: isLinked
                          );
                        },
                      ),
                    
                    const Divider(),
                    
                 
                    FutureBuilder<List<int>>(
                      future: firmaId != null ? _getAutoservisIdsForFirma(firmaId) : Future.value([]),
                      builder: (context, snapshot) {
                        final narudzbaAutoservisId = stavka.narudzba?.autoservisId;
                        final isLinked = snapshot.hasData && 
                                        narudzbaAutoservisId != null && 
                                        snapshot.data!.contains(narudzbaAutoservisId);
                        
                        double? shownPrice;
                        if (isLinked) {
                          shownPrice = stavka.proizvod?.cijenaSaPopustomZaAutoservis ?? 
                                      stavka.proizvod?.cijenaSaPopustom;
                        } else {
                          shownPrice = stavka.proizvod?.cijenaSaPopustom ?? 
                                      stavka.proizvod?.cijena;
                        }
                        
                        return _buildMobileProductDetailRow(
                          "Jedinična cijena:", 
                          shownPrice != null ? _formatCurrency(shownPrice) : "N/A",
                          isTotal: true
                        );
                      },
                    ),
                    
                 
                    FutureBuilder<List<int>>(
                      future: firmaId != null ? _getAutoservisIdsForFirma(firmaId) : Future.value([]),
                      builder: (context, snapshot) {
                        final narudzbaAutoservisId = stavka.narudzba?.autoservisId;
                        final isLinked = snapshot.hasData && 
                                        narudzbaAutoservisId != null && 
                                        snapshot.data!.contains(narudzbaAutoservisId);
                        
                        double? shownPrice;
                        if (isLinked) {
                          shownPrice = (stavka.proizvod?.cijenaSaPopustomZaAutoservis ?? 
                                       stavka.proizvod?.cijenaSaPopustom) ?? 
                                       stavka.proizvod?.cijena;
                        } else {
                          shownPrice = (stavka.proizvod?.cijenaSaPopustom ?? 
                                       stavka.proizvod?.cijena);
                        }
                        
                        final total = (shownPrice ?? 0) * kolicina;
                        
                        return _buildMobileProductDetailRow(
                          "Ukupno:", 
                          _formatCurrency(total),
                          isTotal: true,
                          isLarge: true
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMobileProductDetailRow(String label, String value, {
    bool isDiscount = false,
    bool isAutoservice = false,
    bool isLinked = false,
    bool isTotal = false,
    bool isLarge = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isLarge ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount 
                ? Colors.green 
                : isAutoservice 
                  ? (isLinked ? Colors.blue : Colors.grey)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTable() {
    var isAutoservisUser = context.read<UserProvider>().role != "Klijent" && 
                          context.read<UserProvider>().role != "Zaposlenik";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Proizvodi:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            columnWidths: {
              0: const FlexColumnWidth(3),  
              1: const FlexColumnWidth(1), 
              2: const FlexColumnWidth(1.5),  
              3: const FlexColumnWidth(1.5),
              if (isAutoservisUser) 4: const FlexColumnWidth(2), 
              5: const FlexColumnWidth(2),  
              6: const FlexColumnWidth(2),  
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
                    child: Text("Osnovna cijena", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("Popust", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  if (isAutoservisUser)
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Cijena za autoservise", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("Jedinična cijena", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("Ukupno", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              ...result!.result.map((stavka) {
                final kolicina = stavka.kolicina ?? 1;
                final basePrice = stavka.proizvod?.cijena ?? 0.0;
                final discountPrice = stavka.proizvod?.cijenaSaPopustom;
                final autoservicePrice = stavka.proizvod?.cijenaSaPopustomZaAutoservis;
                final firmaId = stavka.proizvod?.firmaAutodijelovaID;
                
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
                      child: Text(_formatCurrency(basePrice)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        hasRegularDiscount 
                          ? _formatCurrency(discountPrice)
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
                            ? _formatCurrency(autoservicePrice)
                            : "Nema",
                          style: TextStyle(
                            color: hasAutoserviceDiscount ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: FutureBuilder<List<int>>(
                        future: firmaId != null ? _getAutoservisIdsForFirma(firmaId) : Future.value([]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text("Učitavanje...", style: TextStyle(fontSize: 12));
                          }

                          if (snapshot.hasError || !snapshot.hasData) {
                            return const Text("Nema podataka", style: TextStyle(fontSize: 12));
                          }

                          final autoservisIds = snapshot.data!;
                          final narudzbaAutoservisId = stavka.narudzba?.autoservisId;

                          final isLinked = narudzbaAutoservisId != null && 
                                          autoservisIds.contains(narudzbaAutoservisId);
                      
                          final autoservisPrice = stavka.proizvod?.cijenaSaPopustomZaAutoservis;
                          final discountPrice = stavka.proizvod?.cijenaSaPopustom;
                          final regularPrice = stavka.proizvod?.cijena;

                          double? shownPrice;

                          if (isLinked) {
                            shownPrice = autoservisPrice ?? discountPrice;
                          } else {
                            shownPrice = discountPrice ?? regularPrice;
                          }

                          return Text(
                            shownPrice != null ? _formatCurrency(shownPrice) : "N/A",
                            style: TextStyle(
                              color: isLinked ? Colors.black : null,
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: FutureBuilder<List<int>>(
                        future: firmaId != null ? _getAutoservisIdsForFirma(firmaId) : Future.value([]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text("Učitavanje...", style: TextStyle(fontSize: 12));
                          }

                          if (snapshot.hasError || !snapshot.hasData) {
                            return const Text("Nema podataka", style: TextStyle(fontSize: 12));
                          }

                          final autoservisIds = snapshot.data!;
                          final narudzbaAutoservisId = stavka.narudzba?.autoservisId;

                          final isLinked = narudzbaAutoservisId != null && 
                                          autoservisIds.contains(narudzbaAutoservisId);
                          final autoservisPrice = stavka.proizvod?.cijenaSaPopustomZaAutoservis;
                          final discountPrice = stavka.proizvod?.cijenaSaPopustom;
                          final regularPrice = stavka.proizvod?.cijena;

                          double? shownPrice;

                          if (isLinked) {
                            shownPrice = autoservisPrice ?? discountPrice;
                          } else {
                            shownPrice = discountPrice ?? regularPrice;
                          }

                          return Text(
                            shownPrice != null ? _formatCurrency(shownPrice * kolicina) : "N/A",
                            style: TextStyle(
                              color: isLinked ? Colors.black : null,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    final firstItem = result!.result.first;
    final ukupnaCijena = firstItem.narudzba?.ukupnaCijenaNarudzbe ?? 0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sažetak narudžbe:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow("Ukupna cijena:", "${ukupnaCijena.toStringAsFixed(2)} KM"),
            const Divider(thickness: 1),
            _buildSummaryRow(
              "Total:",
              "${ukupnaCijena.toStringAsFixed(2)} KM",
              isTotal: true,
            ),
          ],
        ),
      ),
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
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final isCompleted = result!.result.first.narudzba?.zavrsenaNarudzba ?? false;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.access_time,
            color: isCompleted ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text(
            isCompleted ? "Narudžba završena" : "Narudžba u obradi",
            style: TextStyle(
              color: isCompleted ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2).replaceAll('.', ',')} KM';
  }
}