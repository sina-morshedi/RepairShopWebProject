import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';

class RecentMessages extends StatelessWidget {
  const RecentMessages({
    required this.onPressedMore,
    Key? key,
  }) : super(key: key);

  final Function() onPressedMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(EvaIcons.messageCircle, color: Theme.of(context).primaryColor),
        const SizedBox(width: 10),
        Text(
          "Recent Messages",
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        const Spacer(),
        IconButton(
          onPressed: onPressedMore,
          icon: const Icon(EvaIcons.moreVertical),
          tooltip: "more",
        )
      ],
    );
  }
}
