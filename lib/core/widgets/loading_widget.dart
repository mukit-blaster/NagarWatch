// TODO – loading / shimmer widget
import 'package:flutter/material.dart';
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});
  @override Widget build(BuildContext ctx) => const Center(child: CircularProgressIndicator());
}
