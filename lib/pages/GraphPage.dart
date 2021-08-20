import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lukex/states/GraphPageState.dart';

class GraphPage extends StatefulWidget {
  GraphPage({Key? key, required this.title, required this.animate})
      : super(key: key);

  final String title;
  final bool animate;

  @override
  GraphPageState createState() => GraphPageState();
}
