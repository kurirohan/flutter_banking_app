import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int currentIndex = 0;

  final List<Map<String, dynamic>> transactions = [
    {
      'icon': Icons.local_cafe_outlined,
      'title': 'Starbucks',
      'date': 'Aug 5, 10:02 AM',
      'amount': '-₱4.50',
      'category': 'Food & Drinks',
      'positive': false,
    },
    {
      'icon': Icons.shopping_bag_outlined,
      'title': 'Amazon',
      'date': 'Aug 4, 12:02 PM',
      'amount': '-₱89.99',
      'category': 'Shopping',
      'positive': false,
    },
    {
      'icon': Icons.movie_outlined,
      'title': 'Netflix',
      'date': 'Aug 3, 12:02 PM',
      'amount': '-₱15.99',
      'category': 'Entertainment',
      'positive': false,
    },
    {
      'icon': Icons.account_balance_outlined,
      'title': 'Salary Credit - July 2024',
      'date': 'Aug 2, 12:02 PM',
      'amount': '+₱5,000.00',
      'category': 'Income',
      'positive': true,
    },
    {
      'icon': Icons.directions_car_outlined,
      'title': 'Shell',
      'date': 'Jul 31, 12:02 PM',
      'amount': '-₱45.00',
      'category': 'Transport',
      'positive': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 22),
                    _buildAccountCarousel(),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 28),
                    _buildRecentTransactions(),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Afternoon,',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Alex Johnson',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryDark,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            'AJ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildAccountCarousel() {
  //   return Column(
  //     children: [
  //       SizedBox(
  //         height: 190,
  //         child: ListView(
  //           scrollDirection: Axis.horizontal,
  //           children: const [
  //             BalanceCard(
  //               title: 'Personal Current Account',
  //               balance: '₱12,500.75',
  //               available: '₱12,000.00',
  //               masked: '**** **** **** 4521',
  //               gradient: [
  //                 AppColors.primaryDark,
  //                 AppColors.primary,
  //               ],
  //             ),
  //             SizedBox(width: 16),
  //             BalanceCard(
  //               title: 'Savings Account',
  //               balance: '₱45,200.00',
  //               available: '₱45,200.00',
  //               masked: '**** **** **** 8834',
  //               gradient: [
  //                 Color(0xFF2D242F),
  //                 Color(0xFF4B314F),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(height: 12),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           _dot(true),
  //           _dot(false),
  //         ],
  //       ),
  //     ],
  //   );
  // }

Widget _buildAccountCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 205, // Itinaas mula 190 para maiwasan ang vertical pixel overflow[cite: 5]
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              BalanceCard(
                title: 'Personal Current Account',
                balance: '₱12,500.75',
                available: '₱12,000.00',
                masked: '**** **** **** 4521',
                gradient: [
                  AppColors.primaryDark,
                  AppColors.primary,
                ],
              ),
              SizedBox(width: 16),
              BalanceCard(
                title: 'Savings Account',
                balance: '₱45,200.00',
                available: '₱45,200.00',
                masked: '**** **** **** 8834',
                gradient: [
                  Color(0xFF2D242F),
                  Color(0xFF4B314F),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _dot(true),
            _dot(false),
          ],
        ),
      ],
    );
  }
  Widget _dot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: active ? AppColors.primary : AppColors.border,
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.send_rounded, 'label': 'Transfer'},
      {'icon': Icons.receipt_long_outlined, 'label': 'Pay Bills'},
      {'icon': Icons.qr_code_2_rounded, 'label': 'QR Pay'},
      {'icon': Icons.bar_chart_rounded, 'label': 'Insights'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((item) {
            return QuickActionTile(
              icon: item['icon'] as IconData,
              label: item['label'] as String,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Expanded(
              child: Text(
                'Recent Transactions',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              'See All',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.06),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: transactions.map((tx) {
              return TransactionTile(
                icon: tx['icon'] as IconData,
                title: tx['title'] as String,
                date: tx['date'] as String,
                amount: tx['amount'] as String,
                category: tx['category'] as String,
                positive: tx['positive'] as bool,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.account_balance_rounded, 'label': 'Accounts'},
      {'icon': Icons.send_rounded, 'label': 'Transfer'},
      {'icon': Icons.bar_chart_rounded, 'label': 'Analytics'},
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isActive = currentIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                currentIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.accentPink.withValues(alpha: 0.30)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    items[index]['icon'] as IconData,
                    color: isActive
                        ? AppColors.primaryDark
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[index]['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? AppColors.primaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// class BalanceCard extends StatelessWidget {
//   final String title;
//   final String balance;
//   final String available;
//   final String masked;
//   final List<Color> gradient;

//   const BalanceCard({
//     super.key,
//     required this.title,
//     required this.balance,
//     required this.available,
//     required this.masked,
//     required this.gradient,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 320,
//       padding: const EdgeInsets.all(22),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: gradient,
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(28),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primaryDark.withOpacity(0.20),
//             blurRadius: 28,
//             offset: const Offset(0, 12),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Align(
//             alignment: Alignment.topRight,
//             child: Icon(
//               Icons.credit_card_rounded,
//               color: Colors.white70,
//             ),
//           ),
//           Text(
//             title,
//             style: const TextStyle(
//               color: Colors.white70,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 14),
//           Text(
//             balance,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 34,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Available: $available',
//             style: const TextStyle(
//               color: Colors.white70,
//               fontSize: 15,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const Spacer(),
//           Text(
//             masked,
//             style: const TextStyle(
//               color: Colors.white70,
//               fontSize: 18,
//               letterSpacing: 1.4,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class BalanceCard extends StatelessWidget {
  final String title;
  final String balance;
  final String available;
  final String masked;
  final List<Color> gradient;

  const BalanceCard({
    super.key,
    required this.title,
    required this.balance,
    required this.available,
    required this.masked,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    // Kunin ang total width ng screen para maging responsive
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.85, // Gagamit na ito ng 85% ng screen width para mag-adjust
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.20),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.topRight,
            child: Icon(
              Icons.credit_card_rounded,
              color: Colors.white70,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            balance,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Available: $available',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            masked,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
class QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      child: Column(
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String date;
  final String amount;
  final String category;
  final bool positive;

  const TransactionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.date,
    required this.amount,
    required this.category,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: positive ? AppColors.success : AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category,
                style: TextStyle(
                  color: positive ? AppColors.success : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
