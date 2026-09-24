import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String language;

  const HomePage({
    super.key,
    required this.language,
  });

  // ============================================================
  // COLORS
  // ============================================================

  static const Color gold = Color(0xFFDDB83A);
  static const Color background = Color(0xFF090D13);
  static const Color cardColor = Color(0xFF171920);
  static const Color borderColor = Color(0xFF50525A);
  static const Color green = Color(0xFF4CAF50);

  // ============================================================
  // LANGUAGE
  // ============================================================

  bool get isBurmese => language == 'my';

  String text(String english, String burmese) {
    return isBurmese ? burmese : english;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,

          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.15),
              radius: 1.2,
              colors: [
                Color(0xFF171A1E),
                Color(0xFF0D1117),
                Color(0xFF090D13),
              ],
            ),
          ),

          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(
              14,
              20,
              14,
              15,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ==========================================================
                // PAM HEADER CARD
                // ==========================================================

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.symmetric(
                    vertical: 19,
                    horizontal: 10,
                  ),

                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.95),

                    borderRadius: BorderRadius.circular(20),

                    border: Border.all(
                      color: borderColor,
                      width: 1.3,
                    ),
                  ),

                  child: Column(
                    children: [

                      // LOGO
                      Image.asset(
                        'assets/pam_logo.jpeg',

                        width: 70,
                        height: 70,

                        fit: BoxFit.contain,

                        errorBuilder: (
                            context,
                            error,
                            stackTrace,
                            ) {
                          return const Icon(
                            Icons.public,
                            size: 80,
                            color: gold,
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      // TITLE
                      const Text(
                        'PAM Wealth Flow',

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: gold,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // SUBTITLE
                      const Text(
                        'Intelligent Wealth Flow',

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ==========================================================
                // OPERATIONAL ANALYTICS
                // ==========================================================

                Text(
                  text(
                    'Operational Analytics',
                    'လုပ်ငန်းဆိုင်ရာ ခွဲခြမ်းစိတ်ဖြာမှု',
                  ),

                  style: const TextStyle(
                    color: gold,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 10),

                // ==========================================================
                // PORTFOLIO PERFORMANCE
                // ==========================================================

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 21,
                  ),

                  decoration: BoxDecoration(
                    color: cardColor,

                    borderRadius: BorderRadius.circular(20),

                    border: Border.all(
                      color: borderColor,
                      width: 1.3,
                    ),
                  ),

                  child: Row(
                    children: [

                      // ICON
                      Container(
                        width: 42,
                        height: 42,

                        decoration: BoxDecoration(
                          color: const Color(0xFF292823),
                          borderRadius:
                          BorderRadius.circular(18),
                        ),

                        child: const Icon(
                          Icons.trending_up,
                          color: green,
                          size: 25,
                        ),
                      ),

                      const SizedBox(width: 20),

                      // TEXT
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            Text(
                              text(
                                'Portfolio Performance',
                                'ရင်းနှီးမြှုပ်နှံမှု အခြေအနေ',
                              ),

                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              '+24.8% This Month',

                              style: TextStyle(
                                color: green,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // ==========================================================
                // INCOME TIERS
                // ==========================================================

                Text(
                  text(
                    'Income Tiers',
                    'ဝင်ငွေအဆင့်များ',
                  ),

                  style: const TextStyle(
                    color:gold,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                // ==========================================================
                // TABLE
                // ==========================================================

                _IncomeTable(
                  language: language,
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================================================
// INCOME TABLE
// ==========================================================================

class _IncomeTable extends StatelessWidget {
  final String language;

  const _IncomeTable({
    required this.language,
  });

  bool get isBurmese => language == 'my';

  String text(String english, String burmese) {
    return isBurmese ? burmese : english;
  }

  final List<Map<String, String>> data = const [
    {
      'tier': 'Internship',
      'deposit': '0',
      'tasks': '3',
      'rate': '10',
      'daily': '30',
      '30d': '—',
    },
    {
      'tier': 'SV1',
      'deposit': '500',
      'tasks': '3',
      'rate': '10',
      'daily': '30',
      '30d': '450',
    },
    {
      'tier': 'SV2',
      'deposit': '1200',
      'tasks': '3',
      'rate': '12',
      'daily': '36',
      '30d': '1080',
    },
    {
      'tier': 'SV3',
      'deposit': '3900',
      'tasks': '6',
      'rate': '20',
      'daily': '120',
      '30d': '3600',
    },
    {
      'tier': 'GV1',
      'deposit': '11000',
      'tasks': '12',
      'rate': '30',
      'daily': '360',
      '30d': '10800',
    },
    {
      'tier': 'GV2',
      'deposit': '28000',
      'tasks': '25',
      'rate': '40',
      'daily': '1000',
      '30d': '30000',
    },
    {
      'tier': 'GV3',
      'deposit': '70000',
      'tasks': '30',
      'rate': '85',
      'daily': '2550',
      '30d': '76500',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // ================================================================
        // TABLE HEADER
        // ================================================================

        Container(
          height: 50,

          decoration: const BoxDecoration(
            color: Color(0xFF292D37),

            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),

          child: Row(
            children: [
              _TableHeader(
                text(
                  'Tier',
                  'အဆင့်',
                ),
                1.35,
              ),

              _TableHeader(
                text(
                  'Deposit',
                  'အပ်ငွေ',
                ),
                1.35,
              ),

              _TableHeader(
                text(
                  'Tasks',
                  'လုပ်ငန်းများ',
                ),
                1.0,
              ),

              _TableHeader(
                text(
                  'Rate',
                  'နှုန်း',
                ),
                1.0,
              ),

              _TableHeader(
                text(
                  'Daily',
                  'နေ့စဉ်',
                ),
                1.0,
              ),

              _TableHeader(
                '30D',
                1.0,
              ),
            ],
          ),
        ),

        // ================================================================
        // TABLE ROWS
        // ================================================================

        ...data.map(
              (item) => _IncomeRow(
            item: item,
          ),
        ),
      ],
    );
  }
}

// ==========================================================================
// TABLE HEADER
// ==========================================================================

class _TableHeader extends StatelessWidget {
  final String title;
  final double flex;

  const _TableHeader(
      this.title,
      this.flex,
      );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: (flex * 10).toInt(),

      child: Center(
        child: Text(
          title,

          textAlign: TextAlign.center,

          style: const TextStyle(
            color: Color(0xFFDDB83A),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ==========================================================================
// TABLE ROW
// ==========================================================================

class _IncomeRow extends StatelessWidget {
  final Map<String, String> item;

  const _IncomeRow({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,

      margin: const EdgeInsets.only(top: 8),

      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),

        border: Border.all(
          color: const Color(0xFF50525A),
          width: 1,
        ),
      ),

      child: Row(
        children: [

          _TableCell(
            item['tier']!,
            1.35,
          ),

          _TableCell(
            item['deposit']!,
            1.35,
          ),

          _TableCell(
            item['tasks']!,
            1.0,
          ),

          _TableCell(
            item['rate']!,
            1.0,
          ),

          _TableCell(
            item['daily']!,
            1.0,
          ),

          _TableCell(
            item['30d']!,
            1.0,
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// TABLE CELL
// ==========================================================================

class _TableCell extends StatelessWidget {
  final String value;
  final double flex;

  const _TableCell(
      this.value,
      this.flex,
      );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: (flex * 10).toInt(),

      child: Center(
        child: Text(
          value,

          textAlign: TextAlign.center,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}