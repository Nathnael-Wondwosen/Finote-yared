import 'package:flutter/material.dart';
import 'base_layout.dart';

class AboutZemaScreen extends StatelessWidget {
  const AboutZemaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final double fontSize = textTheme.bodyLarge?.fontSize ?? 16;

    return BaseLayout(
      child: Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          backgroundColor: colorScheme.background,
          elevation: 1,
          iconTheme: IconThemeData(color: colorScheme.primary),
          title: Text(
            'ስለ ዜማ',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saint Yared image and introduction
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/Drum.jpeg',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // const SizedBox(height: 24),
              // Text(
              //   'ዜማ በኢትዮጵያ ታሪክና ባህል',
              //   style: textTheme.headlineSmall?.copyWith(
              //     color: colorScheme.primary,
              //     fontWeight: FontWeight.bold,
              //     fontSize: fontSize + 6,
              //   ),
              //   textAlign: TextAlign.center,
              // ),
              // const SizedBox(height: 16),
              // Text(
              //   'ዜማ በኢትዮጵያ ታሪክ ውስጥ አስፈላጊ ሚና ያለው የመዝሙር እና የመዝሙር ቅርንጫፍ ነው። ቅዱስ ያሬድ የዜማን መሠረት በማጣጣም የኢትዮጵያ ቤተ ክርስቲያን መዝሙሮችን በልዩ ልዩ ዜማዎች አዘጋጀ። ዜማ የመንፈሳዊ ህይወትን የሚያሳይ ባህላዊ እና መንፈሳዊ ትምህርት ነው።',
              //   style: textTheme.bodyLarge?.copyWith(
              //     color: colorScheme.onBackground,
              //     fontSize: fontSize + 2,
              //     height: 1.7,
              //   ),
              //   textAlign: TextAlign.justify,
              // ),
              const SizedBox(height: 24),

              // Voice Production Section
              _buildSectionCard(
                context,
                title: '፩ ድምጽ ከየት ይወጣል?',
                content: 'በአንደበት ክፍሎች በኩል ዲያትራም በሚባለው ከሆድ በትንፋሽ አማካኝነት ይወጣል።',
                color: colorScheme.primary,
                children: [
                  _buildListItem(context, '1) የጭንቅላት ድምጽ (Head Voice)'),
                  _buildListItem(context, '2) የደረት ድምጽ (Chest Voice)'),
                  _buildListItem(
                    context,
                    '3) የሁለቱ ውህድ (Mixed Voice): ጥሩ ዜመኛ አዋቂ የአዘማመር ስልት ነው።',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                context,
                title: '፨ የድምጽ ጉልበት (Vocal Range)',
                content:
                    'እያንዳንዱ ሰው የድምጽ ጉልበት አለው ነገር ግን ጉልበቱ የተለያየ ነው። ይህም በዝቅተኛውና በከፍተኛው ድምጽ በምንዘምርበት ጊዜ ምቾት የሚሰጠን ቦታ ነው።',
                color: colorScheme.primary,
                children: [
                  _buildListItem(
                    context,
                    '* ዝቅተኛ (ወደታች): ወደታች እስኪሰማ በምቾት የምንዘምርበት ነው።',
                  ),
                  _buildListItem(
                    context,
                    '* ከፍተኛ (ወደላይ): ወደላይ እየጨመርን በምቾት የምንዘምረው።',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Melody Section
              _buildSectionCard(
                context,
                title: '፪ ዜማ (Melody) ምንድን ነው',
                content:
                    'ዜማ ማለት ድምጾች ስርአት ባለውና ስነ ጥበባዊነትን በጠበቀ መልኩ ሲደረደሩ የምናገኘው ስልት ወይም የጩኸት ስልት ማለት ነው።',
                color: colorScheme.secondary,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    '፨ የዜማ ጠባይ',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildListItem(context, '- ቀጥ ብሎ የሚዜም'),
                  _buildListItem(context, '- ወደላይ የሚወጣ'),
                  _buildListItem(context, '- ወደታች የሚወርድ'),
                  _buildListItem(context, '- ርክርክ ያለው'),
                  _buildListItem(context, '- ቅላጼ የበዛበት'),
                  _buildListItem(context, '- ከአንድ ቅኝት ወደሌላ ቅኝት የሚሄድ'),
                  _buildListItem(context, '- በቅብብል የሚዜም ናቸው'),
                  const SizedBox(height: 8),
                  Text(
                    'ዜማን መረዳት ጆሮ ይጠይቃል በጣም በትኩረት ማዳመጥ አለብዎ ይህም ማለት ከብዙ ድምጾች መካከል ለይቶ አንዱን ማድመጥ መቻል ነው።',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onBackground,
                      fontSize: fontSize,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Singer Techniques Section
              _buildSectionCard(
                context,
                title: '፫ አንድ ዘማሪ ሊያውቃቸው ሊያደርጋቸው የሚገቡ ስልቶች ምንድን ናቸው?',
                color: colorScheme.tertiary,
                children: [
                  _buildNumberedItem(
                    context,
                    '1) ቅላጼ (Ornament): ዜማው ከተዋቀረበት በተጨማሪ ለማስዋቢያነት የምንጠቀመው ቅላጼ ይባላል። ልኬት ባለው የቅላጼ መጠን መዝሙርን ማስዋብ ነው።',
                  ),
                  _buildNumberedItem(
                    context,
                    '2) የድምጽ ቃና (Pitch): አንዱን የዜማ ጣእም ከሌላው ከፍተኛና ዝቅተኛ የዜማ ጣእም የምንለይበት ነው።',
                  ),
                  _buildNumberedItem(
                    context,
                    '3) ኢንተርቫል (Interval): በሁለት ድምጾች መሀል ያለ የድምጽ ወሰነ ርቀት ነው።',
                  ),
                  _buildNumberedItem(
                    context,
                    '4) እስኬል (Scale): ማለት የድምጾች አደራደር �ስርአት ነው። ፔንታቶኒክ እና ዲያቶሚክ ስኬል አሉ።',
                  ),
                  _buildNumberedItem(
                    context,
                    '5) ስልተ ምት (Rhythm): ማለት የዜማውን ፍሰት የሚመራና የሚቆጣጠር ነው። ለአንድ ጥሩ ዘማሪ የጀርባ አጥንት (ምሰሶ) ነው። ድምጽ ከእንቅስቃሴና ከምቱ ጋር በእኩል መንገድ መሄድ ማለት ነው። ምትን መጠበቅ በሞቾት ለመዘመር ያስችላል።',
                  ),
                  _buildNumberedItem(
                    context,
                    '6) የትንፋሽ አጠቃቀም: አየር በደንብ ወደውስጥ መሳብ ከዚያ በቀስታ እየተነፈሱ (ቀስበቀስ) ማዜም።',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '* ትንፋሽ መውሰድ ለምን ይጠቅማል?',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _buildListItem(context, '- አቅም ይሰጣል'),
                  _buildListItem(context, '- ዜማው ጣዕም እንዲኖረው ይጠቅማል'),
                  _buildListItem(
                    context,
                    '- የዜማ ፍሰቱ በምት (Rhythm) የተጠበቀ እንዲሆን ይረዳል።',
                  ),
                  _buildNumberedItem(
                    context,
                    '7) ቅኝት: ተቀምሮ በተቀመጠ የዜማ ፍሰት ብቻ መመላለስ ነው። የራስን መጨመርም ሆነ ማውጣት አይቻልም። ቅኝቶች የሚባሉት ብዙ ናቸው ዋናዎቹ ትዝታ፣ አምባሰል፣ አንቺሆዬ፣ ባቲ ሲሆኑ 3ቱ ከአንቺሆዬ ውጭ Minor አላቸው።',
                  ),
                  _buildNumberedItem(
                    context,
                    '8) ኪ (Key) መነሻ ዜማ: በመነሻ ድምጽ ጀምሮ በመነሻ ድምጽ መጨረስ ነው። መዝሙር የሚገለባበጠው ከመነሻ ድምጽ ወጥቶ በሌላ ሲጨርስ ነው። ድምጽ አራት መነሻ አሉት እነሱም: ከሆዶ፣ ከደረት፣ ከጉሮሮ፣ ከጭንቅላት ናቸው።',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '# ፍሰት: የመጨረሻው የወንድና የሴት ስልል ያለ ድምጽ ነው። ይሄ ድምጽ አይመከርም ነገር ግን አንደመንዴ የሚያስፈልግበት ሁኔታ ይኖራል ሲባልም በቴክኒክ መሆን አለበት።',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onBackground,
                      fontSize: fontSize,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '# ደረቅ ጩኸት: ወዝ የሌለው ጩኸት ነው ድምጽ አለኝ ተብሎ ዝም ተብሎ አይጮህም ቅላጼ ያስፈልገዋል።',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onBackground,
                      fontSize: fontSize,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '* አፍ አከፋፈት: እንደየ ዜማው ባህሪ በመጠን መክፈት ያስፈልጋል።',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onBackground,
                      fontSize: fontSize,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    String? content,
    required Color color,
    List<Widget> children = const [],
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final double fontSize = textTheme.bodyLarge?.fontSize ?? 16;

    return Card(
      color: color.withOpacity(0.07),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: fontSize + 2,
              ),
            ),
            if (content != null) ...[
              const SizedBox(height: 10),
              Text(
                content,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onBackground,
                  fontSize: fontSize,
                  height: 1.6,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text.split(')')[0] + ') '),
          Expanded(
            child: Text(
              text.split(')')[1],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
