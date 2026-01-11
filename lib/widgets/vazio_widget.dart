import 'package:flutter/material.dart';

class VazioWidget extends StatelessWidget {
  final String mensagem;

  const VazioWidget({super.key, required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(mensagem, style: const TextStyle(color: Colors.white60)),
    );
  }
}
