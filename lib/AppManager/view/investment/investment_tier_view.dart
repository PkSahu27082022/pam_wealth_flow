import 'package:flutter/material.dart';

class InvestmentTiersPage extends StatelessWidget {
  final String language;

  const InvestmentTiersPage({super.key, required this.language});

  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color gold = Color(0xFFDDB83A);
  static const Color background = Color(0xFF090D13);
  static const Color cardColor = Color(0xFF171920);
  static const Color borderColor = Color(0xFF50525A);
  static const Color white = Color(0xFFF2F2F3);

  // ===========================================================================
  // LANGUAGE
  // ===========================================================================

  String tr(String english, String burmese) {
    return language == 'my' ? burmese : english;
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,

      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.15),
          radius: 1.2,
          colors: [Color(0xFF15191F), Color(0xFF0D1117), Color(0xFF090D13)],
        ),
      ),

      child: SafeArea(
        bottom: false,

        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(28, 25, 28, 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ===============================================================
              // HEADER
              // ===============================================================
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        tr('Investment Tiers', 'ရင်းနှီးမြှုပ်နှံမှုအဆင့်များ'),

                        style: const TextStyle(
                          color: gold,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ===============================================================
              // ACTIVE PORTFOLIO
              // ===============================================================
              _activePortfolioCard(),

              const SizedBox(height: 20),

              // ===============================================================
              // INTERNSHIP
              // ===============================================================
              _tierCard(
                title: 'Internship',
                dailyCapacity: '3 Tasks',
                orderRate: '10 THB',
                potentialROI: '30 THB',
                capitalRequirement: '0 THB',
              ),

              const SizedBox(height: 28),

              // ===============================================================
              // SV1
              // ===============================================================
              _tierCard(
                title: 'SV1',
                dailyCapacity: '3 Tasks',
                orderRate: '10 THB',
                potentialROI: '30 THB',
                capitalRequirement: '500 THB',
              ),

              const SizedBox(height: 28),

              // ===============================================================
              // SV2
              // ===============================================================
              _tierCard(
                title: 'SV2',
                dailyCapacity: '3 Tasks',
                orderRate: '12 THB',
                potentialROI: '36 THB',
                capitalRequirement: '1200 THB',
              ),

              const SizedBox(height: 28),

              // ===============================================================
              // SV3
              // ===============================================================
              _tierCard(
                title: 'SV3',
                dailyCapacity: '6 Tasks',
                orderRate: '20 THB',
                potentialROI: '120 THB',
                capitalRequirement: '3900 THB',
              ),

              const SizedBox(height: 28),

              // ===============================================================
              // GV1
              // ===============================================================
              _tierCard(
                title: 'GV1',
                dailyCapacity: '12 Tasks',
                orderRate: '30 THB',
                potentialROI: '360 THB',
                capitalRequirement: '11000 THB',
              ),

              const SizedBox(height: 28),

              // ===============================================================
              // GV2
              // ===============================================================
              _tierCard(
                title: 'GV2',
                dailyCapacity: '25 Tasks',
                orderRate: '40 THB',
                potentialROI: '1000 THB',
                capitalRequirement: '28000 THB',
              ),

              const SizedBox(height: 28),

              // ===============================================================
              // GV3
              // ===============================================================
              _tierCard(
                title: 'GV3',
                dailyCapacity: '30 Tasks',
                orderRate: '85 THB',
                potentialROI: '2550 THB',
                capitalRequirement: '70000 THB',
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // ACTIVE PORTFOLIO CARD
  // ===========================================================================

  Widget _activePortfolioCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(17, 16, 15, 15),

      decoration: BoxDecoration(
        color: cardColor,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: borderColor, width: 1.3),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ===============================================================
          // ACTIVE PORTFOLIO
          // ===============================================================
          Text(
            tr('Active Portfolio: GV1', 'လက်ရှိ Portfolio: GV1'),

            style: const TextStyle(
              color: gold,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 14),

          // ===============================================================
          // ALLOCATION + EXPIRY
          // ===============================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Expanded(
                child: Text(
                  tr('Daily Allocation: 12 Units', 'နေ့စဉ်ခွဲဝေမှု: 12 Units'),

                  style: const TextStyle(
                    color: white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,

                children: [
                  Text(
                    tr('Expiry Date', 'သက်တမ်းကုန်ဆုံးရက်'),

                    style: const TextStyle(
                      color: white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 3),

                  const Text(
                    '03-09-2029',

                    style: TextStyle(
                      color: white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TIER CARD
  // ===========================================================================

  Widget _tierCard({
    required String title,
    required String dailyCapacity,
    required String orderRate,
    required String potentialROI,
    required String capitalRequirement,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(17, 14, 17, 15),

      decoration: BoxDecoration(
        color: cardColor,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ===============================================================
          // TITLE
          // ===============================================================
          Text(
            title,

            style: const TextStyle(
              color: gold,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          // ===============================================================
          // INFORMATION
          // ===============================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(
                    tr('Daily Capacity', 'နေ့စဉ်လုပ်ဆောင်နိုင်မှု'),
                    dailyCapacity,
                  ),

                  const SizedBox(height: 5),

                  _infoRow(tr('Order Rate', 'အော်ဒါနှုန်း'), orderRate),

                  const SizedBox(height: 5),

                  _infoRow(
                    tr('Potential ROI', 'ဖြစ်နိုင်သော ROI'),
                    potentialROI,
                  ),

                  const SizedBox(height: 5),

                  _infoRow(
                    tr('Capital Requirement', 'လိုအပ်သောမတည်ငွေ'),
                    capitalRequirement,
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () {
                  // Unlock action
                },

                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFF292823),

                  side: const BorderSide(color: gold, width: 1.7),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),

                child: Text(
                  tr('Unlock', 'ဖွင့်ရန်'),

                  style: const TextStyle(
                    color: gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          // const SizedBox(height: 20),

          // ===============================================================
          // UNLOCK BUTTON
          // ===============================================================
        ],
      ),
    );
  }

  // ===========================================================================
  // INFO ROW
  // ===========================================================================

  Widget _infoRow(String title, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$title: ',

            style: const TextStyle(
              color: white,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),

          TextSpan(
            text: value,

            style: const TextStyle(
              color: white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
