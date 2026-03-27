import 'package:flutter/material.dart';
import '../constants/spacing.dart';

class CustomDrawerHeader extends StatelessWidget {
  const CustomDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final screenType = AppSpacing.getScreenType(context);
    final isLargeScreen =
        screenType == ScreenType.tablet ||
        screenType == ScreenType.laptop ||
        screenType == ScreenType.desktop;

    return Container(
      decoration: AppSpacing.headerContainerDecoration,
      padding: AppSpacing.getHeaderPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSpacing.getLogoSize(context),
            height: AppSpacing.getLogoSize(context),
            margin: EdgeInsets.only(
              bottom: isLargeScreen ? AppSpacing.lg : AppSpacing.md,
            ),
            decoration: AppSpacing.logoContainerDecoration,
            child: Icon(
              Icons.image,
              color: Colors.white70,
              size: AppSpacing.getLogoSize(context) * 0.5,
            ),
          ),
          Text('ፍኖተ ያሬድ', style: AppSpacing.getTitleStyle(context)),
          isLargeScreen ? AppSpacing.vSpaceMD : AppSpacing.vSpaceSM,
          Text(
            'የፍኖተ ሰላም ሰንበት ት/ቤት መዝሙሮች',
            style: AppSpacing.getSubtitleStyle(context),
          ),
        ],
      ),
    );
  }
}
