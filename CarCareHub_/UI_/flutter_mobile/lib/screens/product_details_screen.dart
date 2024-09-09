import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobile/models/product.dart';
import 'package:flutter_mobile/widgets/master_screen.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

// ignore: must_be_immutable
class ProductDetailScreen extends StatefulWidget {
  Product? product;
   ProductDetailScreen({Key? key,  this.product}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {

  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValues = {};
  
  void initState(){
    super.initState();
    _initialValues = { 'sifra': widget.product?.sifra};
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
 //       if(widget.product != null){
//      setState(() {
//      _formKey.currentState?.patchValue({
//        'sifra' : widget.product?.sifra
//    });
//    });
//  }

  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: widget.product?.naziv ?? "Detalji Proizvoda",
      child: _buildForm()
    );
  }
  
  FormBuilder _buildForm() {
    return FormBuilder(
        key: _formKey,
        initialValue: _initialValues,
        child: FormBuilderTextField(
          name: 'sifra'
          ),
        );
      }
}