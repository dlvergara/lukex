import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lukex/states/ConfigReferenceValueState.dart';

class ConfigReferenceValuePage extends StatefulWidget {
  ConfigReferenceValuePage({Key key, this.title, this.animate})
      : super(key: key);

  final String title;
  final bool animate;

  @override
  ConfigReferenceValueState createState() => ConfigReferenceValueState();
}
