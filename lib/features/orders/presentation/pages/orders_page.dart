import 'package:flutter/material.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/common_app_bar.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: context.l10n.myOrders),
      body: Center(
        child: Text(
          context.l10n.noOrdersYet,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.bodySmall.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ),
    );
  }
}
