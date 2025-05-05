// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/placanje_insert.dart';
import 'package:flutter_mobile/provider/narudzbe_provider.dart';
import 'package:flutter_mobile/provider/placanje_provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

class PlacanjeScreen extends StatefulWidget {
  final dynamic narudzba;
  const PlacanjeScreen({super.key, required this.narudzba});

  @override
  State<PlacanjeScreen> createState() => _PlacanjeScreenState();
}

class _PlacanjeScreenState extends State<PlacanjeScreen> {
  late PlacanjeProvider placanjeProvider;
  late NarudzbaProvider narudzbaProvider;

  @override
  void initState() {
    super.initState();

    placanjeProvider = context.read<PlacanjeProvider>();
    narudzbaProvider = context.read<NarudzbaProvider>();

    displayPaymentSheet(context);

  }

  void handlePayment() async {
    var paymentIntent = await placanjeProvider
        .create(PlacanjeInsert(ukupno: widget.narudzba * 100));

    await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent.clientSecret,
            merchantDisplayName: 'CarCareHub',
            billingDetails: const BillingDetails(
                address: Address(
                    city: 'Mostar',
                    country: 'BA',
                    line1: '',
                    line2: '',
                    postalCode: '',
                    state: ''))));
  }

  void displayPaymentSheet(BuildContext context) async {
    await Stripe.instance.presentPaymentSheet().then((value) async {
      handleSubmit();
    });
  }

  void handleSubmit() async {
    await narudzbaProvider.insert(widget.narudzba);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Narudžba je uspješno kreirana.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Placanje"),
      ),
      body: Container(), 
    );
  }
}