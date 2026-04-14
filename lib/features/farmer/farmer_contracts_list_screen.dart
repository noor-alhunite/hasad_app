import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/models/factory_contract_model.dart';
import '../../core/providers/factory_contract_provider.dart';
import '../../core/providers/user_provider.dart';
import '../factory/factory_contract_detail_screen.dart';

/// قائمة عقود التوريد مع المصانع — للمزارع فقط (عرض وتفاعل).
class FarmerContractsListScreen extends StatelessWidget {
  const FarmerContractsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<UserProvider>().currentUser?.id;
    final provider = context.watch<FactoryContractProvider>();
    final list = provider.contractsForFarmerId(uid);
    final dateFmt = DateFormat.yMMMd('ar');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'عقود التوريد',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: list.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'لا توجد عقود مرتبطة بحسابك حالياً.\n'
                  'عند إرسال مصنع عقداً لك سيظهر هنا.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Cairo', height: 1.4),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final c = list[index];
                return _FarmerContractTile(
                  contract: c,
                  dateFmt: dateFmt,
                  onTap: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => FactoryContractDetailScreen(
                          contractId: c.id,
                          viewer: ContractDetailViewer.farmer,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _FarmerContractTile extends StatelessWidget {
  const _FarmerContractTile({
    required this.contract,
    required this.dateFmt,
    required this.onTap,
  });

  final FactoryContract contract;
  final DateFormat dateFmt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusLabel(contract.status);
    final statusColor = _statusColor(contract.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha((255 * 0.15).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      contract.productName,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${contract.totalQuantityTons} طن • ${contract.pricePerKgDinar} د.أ/كجم',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${dateFmt.format(contract.startDate)} ← ${dateFmt.format(contract.endDate)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: AppColors.grey),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(FactoryContractStatus s) {
    switch (s) {
      case FactoryContractStatus.pendingFarmerApproval:
        return 'بانتظار موافقتك';
      case FactoryContractStatus.activeCertified:
        return 'نشط';
      case FactoryContractStatus.ended:
        return 'منتهي';
      case FactoryContractStatus.rejected:
        return 'مرفوض';
    }
  }

  Color _statusColor(FactoryContractStatus s) {
    switch (s) {
      case FactoryContractStatus.pendingFarmerApproval:
        return AppColors.warning;
      case FactoryContractStatus.activeCertified:
        return AppColors.primaryGreen;
      case FactoryContractStatus.ended:
        return AppColors.textSecondary;
      case FactoryContractStatus.rejected:
        return AppColors.error;
    }
  }
}
