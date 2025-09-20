import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class ServiceDetailsView extends StatelessWidget {
  const ServiceDetailsView({super.key});

  // demo data
  static const String _serviceName = 'Brake Oil Service';
  static const String _status = 'IN-PROGRESS';
  static const String _plate = 'BFP 1975';
  static const String _eta = '3:00 PM';
  static const double _price = 200.00;

  // 0-based index for the CURRENT step (“In Repair” in your screenshot)
  static const int _currentStep = 3;

  // Connector sizing (tweak these to taste)
  static const double _kNodeSize = 22; // circle size
  static const double _kTopSegH = 42; // was 26 — longer
  static const double _kBotSegH = 58; // was 26 — longer

  static const List<Map<String, String>> _timeline = [
    {"time": "12:00 AM", "text": "In Inspection"},
    {"time": "12:38 AM", "text": "Paid"},
    {"time": "1:04 PM", "text": "Parts Awaiting"},
    {"time": "1:51 PM", "text": "In Repair"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.softWhite,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: AppColor.primaryGreen,
          toolbarHeight: 80,
          titleSpacing: 0,
          leadingWidth: 56,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColor.softWhite),
            onPressed: () => Navigator.pop(context),
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 10), // keep your left padding
            child: const Text(
              "Service Details",
              style: TextStyle(
                color: AppColor.softWhite,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.darkCharcoal.withAlpha(40),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top row: title + status/plate tags ────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // left icon block
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColor.primaryGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.car_repair,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // title and tags
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // title
                            const Expanded(
                              child: Text(
                                _serviceName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColor.darkCharcoal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // right: status + plate (kept compact & never overflows)
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 180),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // status pill
                                  Container(
                                    child: const Text(
                                      _status,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColor.darkCharcoal,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // plate badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.darkCharcoal,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.black),
                                    ),
                                    child: const Text(
                                      _plate,
                                      style: TextStyle(
                                        color: AppColor.softWhite,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // ── thin divider to separate top & bottom rows ───────────────────────
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 10),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColor.slateGray.withOpacity(0.15),
                    ),
                  ),

                  // ── Bottom row: ETA left, price right (green) ────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ETA : $_eta',
                        style: TextStyle(
                          color: AppColor.darkCharcoal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'RM ${_price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColor.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // TIMELINE (no vertical padding between items; connectors touch)
            Column(
              children: List.generate(_timeline.length, (index) {
                final item = _timeline[index];
                final isFirst = index == 0;
                final isLast = index == _timeline.length - 1;
                final isCompleted = index < _currentStep;
                final isCurrent = index == _currentStep;

                // continuous connector colors
                //  - top segment: green until/including current node, dark after
                //  - bottom segment: green before current, dark from current downwards
                final Color topLine = isFirst
                    ? Colors.transparent
                    : (index <= _currentStep
                          ? AppColor.primaryGreen
                          : AppColor.darkCharcoal);

                final Color bottomLine = index < _currentStep
                    ? AppColor.primaryGreen
                    : AppColor.darkCharcoal;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // time (fixed width)
                    SizedBox(
                      width: 80,
                      child: Text(
                        item['time']!,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: AppColor.darkCharcoal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // track: top connector + node + bottom connector (heights sum; NO extra padding)
                    // track: top connector + node + bottom connector
                    Column(
                      children: [
                        // top connector (longer)
                        Container(width: 2, height: _kTopSegH, color: topLine),

                        // node
                        Container(
                          width: _kNodeSize,
                          height: _kNodeSize,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppColor.darkCharcoal
                                : (isCompleted
                                      ? AppColor.accentMint
                                      : AppColor.slateGray.withOpacity(0.25)),
                            shape: BoxShape.circle,
                          ),
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : (isCurrent ? null : const SizedBox.shrink()),
                        ),

                        // bottom connector (longer; keep continuous color logic)
                        Container(
                          width: 2,
                          height: isLast ? _kTopSegH : _kBotSegH,
                          color: isLast ? Colors.transparent : bottomLine,
                        ),
                      ],
                    ),

                    const SizedBox(width: 16),

                    // status text
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item['text']!,
                          style: const TextStyle(
                            color: AppColor.darkCharcoal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
