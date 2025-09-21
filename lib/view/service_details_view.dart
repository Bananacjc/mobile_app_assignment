import 'package:flutter/material.dart';
import 'package:mobile_app_assignment/model/service.dart';
import 'package:mobile_app_assignment/provider/navigation_provider.dart';
import 'package:mobile_app_assignment/view/service_view.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';

class ServiceDetailsView extends StatefulWidget {
  final Service service;
  const ServiceDetailsView({super.key, required this.service});

  @override
  State<StatefulWidget> createState() => _ServiceDetailsViewState();
}

class _ServiceDetailsViewState extends State<ServiceDetailsView> {
  // Status order and labels
  static const List<String> _order = [
    'inspection',
    'pending',
    'paid',
    'parts_awaiting',
    'service',
    'completed',
  ];

  static const Map<String, String> _labels = {
    'inspection': 'In Inspection',
    'pending': 'Pending',
    'paid': 'Paid',
    'parts_awaiting': 'Parts Awaiting',
    'service': 'Service Conducting',
    'completed': 'Service Completed',
  };

  // Sizing for the timeline
  static const double _kNodeSize = 22;
  static const double _kTopSegH = 42;
  static const double _kBotSegH = 58;

  late final int _currentStep;
  late final List<String> _times; // formatted times for each step (length = 6)

  @override
  void initState() {
    super.initState();
    _currentStep = _statusToStep(widget.service.status);
    _times = _buildTimes(widget.service.appointmentDate);
  }

  int _statusToStep(String? raw) {
    final s = (raw ?? '').toLowerCase().trim();
    final idx = _order.indexOf(s);
    return idx >= 0 ? idx : 0; // default to inspection
  }

  String _fmtTime(DateTime dt) {
    final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h12:$m $p';
  }

  /// Build 6 times: appointment for inspection, then +30 mins each.
  List<String> _buildTimes(DateTime? start) {
    if (start == null) return List.filled(_order.length, 'TBD');
    return List.generate(
      _order.length,
      (i) => _fmtTime(start.add(Duration(minutes: 30 * i))),
    );
  }

  String _titleText() => (widget.service.title?.trim().isNotEmpty ?? false)
      ? widget.service.title!.trim()
      : 'Service';

  String _statusLabel() =>
      _labels[widget.service.status?.toLowerCase()] ?? (_labels['inspection']!);

  String _plateText() => widget.service.plateNo.isNotEmpty
      ? widget.service.plateNo.toUpperCase()
      : '—';

  /// Use the "completed" step time as an ETA. Falls back to TBD.
  String _etaText() => _times.isNotEmpty ? _times.last : 'TBD';

  String _priceText() => widget.service.fee != null
      ? 'RM ${widget.service.fee!.toStringAsFixed(2)}'
      : '—';

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);

    final serviceName = _titleText();
    final status = _statusLabel();
    final plate = _plateText();
    final eta = _etaText();
    final price = _priceText();

    final bool allDone =
        (widget.service.status ?? '').toLowerCase().trim() == 'completed';

    // Build timeline items from labels + generated times
    final timeline = List.generate(
      _order.length,
      (i) => {'time': _times[i], 'text': _labels[_order[i]]!},
    );

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
            onPressed: () => navigationProvider.showFullPageContent(ServiceView()),
          ),
          title: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
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
            // Header card
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                serviceName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColor.darkCharcoal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 180),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // status pill
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      status,
                                      style: const TextStyle(
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
                                    child: Text(
                                      plate,
                                      style: const TextStyle(
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

                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 10),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColor.slateGray.withOpacity(0.15),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ETA : $eta',
                        style: const TextStyle(
                          color: AppColor.darkCharcoal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        price,
                        style: TextStyle(
                          color: widget.service.fee != null
                              ? AppColor.primaryGreen
                              : AppColor.slateGray,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Timeline
            Column(
              children: List.generate(timeline.length, (index) {
                final item = timeline[index];
                final isFirst = index == 0;
                final isLast = index == timeline.length - 1;

                // When all done, treat the last node as completed (not current).
                final bool isCompleted =
                    allDone ? index <= _currentStep : index < _currentStep;
                final bool isCurrent =
                    allDone ? false : index == _currentStep;

                // continuous connector colors
                final Color topLine = isFirst
                    ? Colors.transparent
                    : ((isCompleted || isCurrent)
                        ? AppColor.primaryGreen
                        : AppColor.darkCharcoal);

                final Color bottomLine = isLast
                    ? Colors.transparent
                    : (isCompleted
                        ? AppColor.primaryGreen
                        : AppColor.darkCharcoal);

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

                    // track
                    Column(
                      children: [
                        Container(width: 2, height: _kTopSegH, color: topLine),
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
                        Container(
                          width: 2,
                          height: isLast ? _kTopSegH : _kBotSegH,
                          color: bottomLine,
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
