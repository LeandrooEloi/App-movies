import 'package:flutter/material.dart';

class ErroWidget extends StatelessWidget {
  final String mensagem;
  final VoidCallback onTentarNovamente;

  const ErroWidget({
    super.key,
    required this.mensagem,
    required this.onTentarNovamente,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mensagem, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onTentarNovamente,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
