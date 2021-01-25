import 'package:flutter/material.dart';

class Symbols extends StatelessWidget {
  final symbols;

  Symbols(this.symbols);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemBuilder: (BuildContext context, int idx) => Text(symbols[idx]));
  }
}
