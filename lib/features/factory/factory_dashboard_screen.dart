// لوحة المصنع: توريد، عقود، مواعيد — لا تُعرض لمستخدم التاجر (مسار `TraderMainScreen` منفصل).
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/models/factory_contract_model.dart';
import '../../core/models/product_model.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/factory_contract_provider.dart';
import '../../core/providers/product_provider.dart';
import '../../core/providers/shell_tab_bridge.dart';
import '../../core/providers/user_provider.dart';
import '../shared/ai_chatbot_screen.dart';
import 'factory_contract_detail_screen.dart';

class FactoryDashboardScreen extends StatelessWidget {
  const FactoryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    final productProvider = context.watch<ProductProvider>();
    final contractProv = context.watch<FactoryContractProvider>();
    final shell = context.read<ShellTabBridge>();
    final dateFmt = DateFormat.MMMd('ar');

    // إحصاءات العقود من المزوّد (بيانات وهمية قابلة للتحديث)
    final activeCertCount = contractProv.contracts
        .where((c) => c.status == FactoryContractStatus.activeCertified)
        .length;
    final pendingCount = contractProv.contracts
        .where((c) => c.status == FactoryContractStatus.pendingFarmerApproval)
        .length;
    final upcoming = contractProv.upcomingSupplyWithinDays(14);
    final farmerStats = contractProv.farmerQualityStats();
    final topFarmers = farmerStats.entries.toList()
      ..sort((a, b) => b.value.avgStars.compareTo(a.value.avgStars));

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            AiChatbotScreen.open(context, userRole: UserRole.factory),
        backgroundColor: const Color(0xFF4CAF50),
        child: const Text('🤖', style: TextStyle(fontSize: 26)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFBF360C), Color(0xFFE65100)],
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                bottom: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.notifications_outlined,
                            color: Colors.white, size: 26),
                        onPressed: () => shell.goToTab(5),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            user?.name ?? 'مصنع الأغذية الوطني',
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const Text('لوحة تحكم المصنع',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                        child: _StatCard(
                            icon: Icons.inventory,
                            value: '8',
                            label: 'طلبات توريد',
                            color: const Color(0xFFE65100))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _StatCard(
                            icon: Icons.description,
                            value: '$activeCertCount',
                            label: 'عقود نشطة',
                            color: AppColors.primaryGreen)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _StatCard(
                            icon: Icons.pending_actions,
                            value: '$pendingCount',
                            label: 'عقود بانتظار المزارع',
                            color: const Color(0xFF0288D1))),
                  ],
                ),
              ),
            ),
          ),
          // وصول سريع: نفس تجربة التاجر (خريطة) + عقود المصنع
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => shell.goToTab(1),
                      icon: const Icon(Icons.description_outlined),
                      label: const Text(
                        'عقودي',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => shell.goToTab(0),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text(
                        'الخريطة الذكية',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _DashboardSectionCard(
              title: 'إشعارات مواعيد التوريد (خلال 14 يوماً)',
              child: upcoming.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'لا مواعيد توريد في هذه الفترة',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : Column(
                      children: upcoming.map((u) {
                        return ListTile(
                          onTap: () {
                            Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (_) => FactoryContractDetailScreen(
                                  contractId: u.contractId,
                                ),
                              ),
                            );
                          },
                          leading: const Icon(
                            Icons.schedule,
                            color: Color(0xFFE65100),
                          ),
                          title: Text(
                            '${u.productName} — ${u.tons} طن',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            dateFmt.format(u.date),
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: _DashboardSectionCard(
              title: 'تميز المزارعين بالالتزام بالجودة',
              child: topFarmers.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'سجّل تقييمات على التوريدات ليظهر التقرير',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : Column(
                      children: topFarmers.take(3).map((e) {
                        final s = e.value;
                        return ListTile(
                          leading: const Icon(
                            Icons.verified,
                            color: AppColors.primaryGreen,
                          ),
                          title: Text(
                            s.name,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${s.avgStars.toStringAsFixed(1)} ⭐ (${s.count} تقييم)',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),
          // Supply Requests
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: const Text('طلبات التوريد',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                  textAlign: TextAlign.right),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final requests = [
                  {
                    'title': 'طماطم',
                    'qty': '500 كجم',
                    'date': '2026-03-01',
                    'status': 'قيد الانتظار'
                  },
                  {
                    'title': 'خيار',
                    'qty': '300 كجم',
                    'date': '2026-03-05',
                    'status': 'مقبول'
                  },
                  {
                    'title': 'فلفل أحمر',
                    'qty': '200 كجم',
                    'date': '2026-03-10',
                    'status': 'قيد الانتظار'
                  },
                ];
                if (index >= requests.length) return null;
                final req = requests[index];
                final isAccepted = req['status'] == 'مقبول';
                return Material(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(req['title']!, textAlign: TextAlign.right),
                          content: Text(
                            'الكمية: ${req['qty']}\nالموعد: ${req['date']}\nالحالة: ${req['status']}',
                            textAlign: TextAlign.right,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('إغلاق'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isAccepted
                              ? AppColors.lightGreen
                              : const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          req['status']!,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: isAccepted
                                ? AppColors.primaryGreen
                                : AppColors.warning,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(req['title']!,
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                          Text('${req['qty']} • ${req['date']}',
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                      const Icon(Icons.inventory_2,
                          color: Color(0xFFE65100), size: 24),
                    ],
                  ),
                    ),
                  ),
                );
              },
              childCount: 3,
            ),
          ),
          // Available Raw Materials
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: const Text('المواد الخام المتاحة',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                  textAlign: TextAlign.right),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final products = productProvider.filteredProducts;
                if (index >= products.length.clamp(0, 4)) return null;
                final p = products[index];
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withAlpha((255 * 0.04).round()),
                          blurRadius: 6,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _factorySupplyDialog(context, p),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                              color: const Color(0xFFE65100),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Text('طلب توريد',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(p.cropType,
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                          Text('${p.farmerName} • ${p.quantity} ${p.unit}',
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                          Text('${p.price} ${p.priceUnit}',
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  color: Color(0xFFE65100),
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                            color: const Color(0xFFFBE9E7),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.eco,
                            color: Color(0xFFE65100), size: 22),
                      ),
                    ],
                  ),
                );
              },
              childCount: productProvider.filteredProducts.length.clamp(0, 4),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  void _factorySupplyDialog(BuildContext context, ProductModel p) {
    final qty = TextEditingController(text: '200');
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text('طلب توريد — ${p.cropType}', textAlign: TextAlign.right),
          content: TextField(
            controller: qty,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            decoration: const InputDecoration(labelText: 'الكمية المطلوبة (كجم)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم إرسال طلب توريد لـ ${p.farmerName}')),
                );
              },
              child: const Text('إرسال الطلب'),
            ),
          ],
        );
      },
    );
  }
}

/// قسم بعنوان داخل لوحة المصنع (مواعيد / تقرير جودة).
class _DashboardSectionCard extends StatelessWidget {
  const _DashboardSectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha((255 * 0.06).round()),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
