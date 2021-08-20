import 'package:flutter/material.dart';
import 'package:lukex/Util/Util.dart';
import 'package:lukex/pages/ConfigReferenceValue.dart';

class ConfigReferenceValueState extends State<ConfigReferenceValuePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Util util = new Util();
  double referenceValue = 0;

  @override
  void initState() {
    super.initState();
    this.referenceValue = util.getFromLocalStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Lukex - Valor de Referencia'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20),
            ),
            TextFormField(
              initialValue: this.referenceValue.toString(),
              decoration: const InputDecoration(
                hintText: 'Valor de referencia',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty || !util.isNumeric(value)) {
                  return 'Por favor ingrese un numero';
                }
                return null;
              },
              onSaved: (String? value) {
                String data = value ?? "0";
                this.referenceValue = double.parse(data);
                util.saveToLocalStorage(this.referenceValue);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    //Scaffold.of(context).openEndDrawer();
                    Navigator.pop(context);
                  }
                },
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
