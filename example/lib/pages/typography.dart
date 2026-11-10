import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class TypographyPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SemiTitle("h1. Semi Design", heading: 1),
        SemiTitle("h2. Semi Design", heading: 2),
        SemiTitle("h3. Semi Design", heading: 3),
        SemiTitle("h4. Semi Design", heading: 4),
        SemiTitle("h5. Semi Design", heading: 5),
        SemiTitle("h6. Semi Design", heading: 6),
      ],
    );
  }
}
