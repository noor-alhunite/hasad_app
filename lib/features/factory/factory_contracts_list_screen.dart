import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/models/factory_contract_model.dart';
import '../../core/providers/factory_contract_provider.dart';
import 'factory_contract_detail_screen.dart';
import 'factory_new_contract_screen.dart';

/// شاشة «عقودي»: قائمة بالعقود النشطة والمنتهية وقيد موافقة المزارع.
class FactoryContractsListScreen extends StatefulWidget {
  const FactoryContractsListScreen({super.key});

  @override
  State<FactoryContractsListScreen> createState() =>
      _FactoryContractsListScreenState();
}

class _FactoryContractsListScreenState
    extends State<FactoryContractsListScreen> {
  /// فلتر العرض: الكل / نشطة موثقة / منتهية / بانتظار المزارع
  _ContractFilter _filter = _ContractFilter.all;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FactoryContractProvider>();
    final all = provider.contracts;
    final filtered = _applyFilter(all, _filter);
    final dateFmt = DateFormat.yMMMd('ar');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'العقود الإلكترونية',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => const FactoryNewContractScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFFE65100),
        icon: const Icon(Icons.add),
        label: const Text('إنشاء عقد جديد', style: TextStyle(fontFamily: 'Cairo')),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'الكل',
                    selected: _filter == _ContractFilter.all,
                    onTap: () => setState(() => _filter = _ContractFilter.all),
                  ),
                  _FilterChip(
                    label: 'نشطة موثقة',
                    selected: _filter == _ContractFilter.active,
                    onTap: () =>
                        setState(() => _filter = _ContractFilter.active),
                  ),
                  _FilterChip(
                    label: 'منتهية',
                    selected: _filter == _ContractFilter.ended,
                    onTap: () => setState(() => _filter = _ContractFilter.ended),
                  ),
                  _FilterChip(
                    label: 'بانتظار المزارع',
                    selected: _filter == _ContractFilter.pending,
                    onTap: () =>
                        setState(() => _filter = _ContractFilter.pending),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد عقود في هذا الفلتر',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final c = filtered[index];
                      return _ContractCard(
                        contract: c,
                        dateFmt: dateFmt,
                        onTap: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute(
                              builder: (_) =>
                                  FactoryContractDetailScreen(contractId: c.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<FactoryContract> _applyFilter(
    List<FactoryContract> list,
    _ContractFilter f,
  ) {
    switch (f) {
      case _ContractFilter.all:
        return list;
      case _ContractFilter.active:
        return list
            .where((c) => c.status == FactoryContractStatus.activeCertified)
            .toList();
      case _ContractFilter.ended:
        return list
            .where((c) => c.status == FactoryContractStatus.ended)
            .toList();
      case _ContractFilter.pending:
        return list
            .where(
              (c) => c.status == FactoryContractStatus.pendingFarmerApproval,
            )
            .toList();
    }
  }
}

enum _ContractFilter { all, active, ended, pending }

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontFamily: 'Cairo')),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: const Color(0xFFFFE0B2),
      ),
    );
  }
}

class _ContractCard extends StatelessWidget {
  const _ContractCard({
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
                      '${contract.productName} — ${contract.farmerName}',
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
        return 'بانتظار المزارع';
      case FactoryContractStatus.activeCertified:
        return 'موثق • نشط';
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
