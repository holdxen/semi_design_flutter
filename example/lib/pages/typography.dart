import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class TypographyPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        spacing: 100,
        children: [
          Column(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SemiTitle("h1. Semi Design", heading: 1),
              SemiTitle("h2. Semi Design", heading: 2),
              SemiTitle("h3. Semi Design", heading: 3),
              SemiTitle("h4. Semi Design", heading: 4),
              SemiTitle("h5. Semi Design", heading: 5),
              SemiTitle("h6. Semi Design", heading: 6),
            ],
          ),
          Column(
            children: [
              //
              SemiText("Text"),
              SemiText("Secondary", type: SemiTextType.secondary),
              SemiText("Tertiary", type: SemiTextType.tertiary),
              SemiText("Quaternary", type: SemiTextType.quaternary),
              SemiText("Warning", type: SemiTextType.warning),
              SemiText("Danger", type: SemiTextType.danger),
              SemiText("Success", type: SemiTextType.success),
              SemiText("Disabled", disabled: true),
              SemiText("Default Mark", mark: true),
              SemiText("Example code", code: true),
              SemiText("Underline", underline: true),
              SemiText("Deleted", delete: true),
              SemiText("Strong", strong: true),
            ],
          ),
        ],
      ),
    );
  }
}
