import 'package:flutter/material.dart';

import '../../../../Settings/utils/p_colors.dart';
import '../../../../Settings/utils/p_text_styles.dart';

class HeadingSection extends StatelessWidget {
  final String title;
  const HeadingSection({
    super.key, required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title, style: PTextStyles.displaySmall.copyWith(color: PColors.primaryColor)));
  }
}
