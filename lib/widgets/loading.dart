import 'package:fl_croc/common/context.dart';
import 'package:material_ui/material_ui.dart';

class const LoadingWidget({super.key, this.message}) extends StatelessWidget {
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: context.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
