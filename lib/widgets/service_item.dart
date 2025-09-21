import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app_assignment/core/theme/app_colors.dart';
import 'package:mobile_app_assignment/model/service.dart';
import 'package:mobile_app_assignment/services/feedback_service.dart';
import 'package:mobile_app_assignment/services/service_service.dart';
import 'package:mobile_app_assignment/view/feedback_view.dart';
import 'package:mobile_app_assignment/view/payment_view.dart';
import 'package:mobile_app_assignment/view/service_details_view.dart';
import 'package:provider/provider.dart';
import '../provider/navigation_provider.dart';

class ServiceItem extends StatefulWidget {
  final Service service;
  final bool? inProgress;

  const ServiceItem({
    super.key,
    required this.service,
    required this.inProgress,
  });

  @override
  State<StatefulWidget> createState() => _ServiceItemState();
}

class _ServiceItemState extends State<ServiceItem> {
  final serviceStatus = <String, String>{
    'inspection': "In Inspection",
    'pending': "Pending",
    'paid': "Paid",
    'parts_awaiting': "Parts Awaiting",
    'service': "Service Conducting",
    'completed': "Service Completed",
  };

  String serviceTitle = "";
  String? topRightCornerDisplay;
  String plateNoDisplay = "N/A";
  String? middleLeftDisplay;
  String? feeDisplay;

  /// 0 = no button row, 1 = only "View Details", 2 = two buttons
  int buttonDisplay = 2;

  /// "Pay", "Reschedule", "Feedback" (or null)
  String? buttonName;

  double defaultWidth = 360;
  double defaultHeight = 170;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    serviceTitle = widget.service.title ?? "Untitled";
    plateNoDisplay = widget.service.plateNo;

    // Fee
    feeDisplay = widget.service.fee != null
        ? "RM ${widget.service.fee!.toStringAsFixed(2)}"
        : "";

    // Appointment + end time
    final DateTime? appt = widget.service.appointmentDate;
    final int? durMin = widget.service.duration;
    final DateTime? endAppointment = (appt != null && durMin != null)
        ? appt.add(Duration(minutes: durMin))
        : null;

    // Top-right by default = appointment date-time
    if (appt != null) {
      final local = appt.toLocal();
      topRightCornerDisplay = DateFormat("dd MMM yyyy, h:mm a").format(local);
    } else {
      topRightCornerDisplay = "-";
    }

    if (widget.inProgress == true) {
      // In-progress card: show status on the top-right instead of date/time
      topRightCornerDisplay = serviceStatus[widget.service.status] ?? "-";

      // If not "pending", show only "View Details"
      if ((widget.service.status ?? '').toLowerCase() != "pending") {
        buttonDisplay = 1;
      }

      // Middle-left = ETA (end time) when available
      if (endAppointment != null) {
        middleLeftDisplay =
        "ETA ${DateFormat.jm().format(endAppointment.toLocal())}";
      } else {
        middleLeftDisplay = "";
      }

      // Pending: show Pay, hide fee + eta
      if ((widget.service.status ?? '').toLowerCase() == "pending") {
        buttonName = "Pay";
        middleLeftDisplay = "";
      } else if ((widget.service.status ?? '').toLowerCase() == "inspection") {
        feeDisplay = "";
        middleLeftDisplay = "";
      }
    } else if (widget.inProgress == false) {
      // Upcoming / scheduled card
      if ((widget.service.status ?? '') != "completed") {
        buttonName = "Reschedule";
        feeDisplay = "";
      } else {
        // Completed: maybe show Feedback
        isFeedback(widget.service.serviceId).then((hadFeedback) {
          if (!mounted) return;
          setState(() {
            if (hadFeedback) {
              buttonDisplay = 1; // only "View Details"
            } else {
              buttonName = "Feedback";
            }
          });
        });
      }
    } else {
      // History / no actions
      buttonDisplay = 0;
      defaultHeight = 115;
    }
  }

  Future<bool> isFeedback(String serviceId) async {
    final FeedbackService fs = FeedbackService();
    try {
      final feedback = await fs.getFeedback(widget.service.serviceId);
      if (feedback != null && (feedback.star ?? 0) != 0) {
        return true;
      }
    } catch (e) {
      debugPrint("Error fetching feedback: $e");
    }
    return false;
  }

  // ---------------- Reschedule flow ----------------

  Future<void> _reschedule() async {
    final DateTime initial = widget.service.appointmentDate ?? DateTime.now();

    // Pick date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(DateTime.now()) ? initial : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColor.primaryGreen,
            onPrimary: Colors.white,
            onSurface: AppColor.darkCharcoal,
          ),
        ),
        child: child!,
      ),
    );
    if (pickedDate == null) return;

    // Pick time
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColor.primaryGreen,
            onPrimary: Colors.white,
            onSurface: AppColor.darkCharcoal,
          ),
        ),
        child: child!,
      ),
    );
    if (pickedTime == null) return;

    // Compose DateTime
    final newAppt = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (!newAppt.isAfter(DateTime.now())) {
      _snack("Please choose a future date & time.", isError: true);
      return;
    }

    try {
      await ServiceService().rescheduleService(
        widget.service.serviceId,
        newAppt,
      );
      if (!mounted) return;

      // Update the small label immediately; outer stream will refresh data anyway
      setState(() {
        topRightCornerDisplay = DateFormat(
          "dd MMM yyyy, h:mm a",
        ).format(newAppt.toLocal());
      });

      _snack("Appointment rescheduled.");
    } catch (e) {
      _snack("Failed to reschedule: $e", isError: true);
    }
  }

  // ---------------- Buttons ----------------

  /// Always returns a Widget (never null) so it can be safely placed in a children list.
  Widget buttonRow(VoidCallback? action) {
    final navigationProvider = Provider.of<NavigationProvider>(
      context,
      listen: false,
    );

    if (buttonDisplay >= 2) {
      // Two buttons: primary action + View Details
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(165, 40),
            ),
            onPressed: action,
            child: Text(
              buttonName ?? '',
              style: const TextStyle(color: AppColor.softWhite),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.softWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColor.darkCharcoal, width: 1),
              ),
              minimumSize: const Size(165, 40),
            ),
            onPressed: () {
              navigationProvider.showFullPageContent(
                ServiceDetailsView(service: widget.service),
              );
            },
            child: const Text(
              "View Details",
              style: TextStyle(color: AppColor.darkCharcoal),
            ),
          ),
        ],
      );
    } else if (buttonDisplay == 1) {
      // Only "View Details"
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.softWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColor.darkCharcoal, width: 1),
          ),
          minimumSize: const Size(340, 40),
        ),
        onPressed: () {
          navigationProvider.showFullPageContent(
            ServiceDetailsView(service: widget.service),
          );
        },
        child: const Text(
          "View Details",
          style: TextStyle(color: AppColor.darkCharcoal),
        ),
      );
    }

    // No buttons to show
    return const SizedBox.shrink();
  }

  void _snack(String msg, {bool isError = false}) {
    final bg = isError ? Colors.redAccent : AppColor.primaryGreen;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: bg));
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, VoidCallback> actions = {
      "pay": () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentView(service: widget.service),
        ),
      ),
      "reschedule": _reschedule,
      "feedback": () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FeedbackView(service: widget.service),
        ),
      ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.softWhite,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColor.darkCharcoal.withAlpha(63),
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        width: defaultWidth,
        height: defaultHeight,
        child: Column(
          children: [
            // Top row
            // Top row (no more overflows)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT: icon + title (flexible)
                Expanded(
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 10, top: 10),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColor.primaryGreen,
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            child: Icon(
                              Icons.add,
                              color: AppColor.softWhite,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Title takes remaining space and ellipsizes
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            serviceTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // RIGHT: time/status + plate (cap width and ellipsize)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, right: 10),
                        child: Text(
                          (topRightCornerDisplay ?? "-").toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5, right: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.darkCharcoal,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.black),
                          ),
                          child: Text(
                            plateNoDisplay,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColor.softWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(
              indent: 10,
              endIndent: 10,
              color: AppColor.slateGray.withAlpha(63),
              thickness: 1,
            ),

            // Bottom section
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          middleLeftDisplay ?? "",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          feeDisplay ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColor.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Always pass a Widget (buttonRow handles empty state)
                buttonRow(
                  (buttonName != null && buttonName!.isNotEmpty)
                      ? actions[buttonName!.toLowerCase()]
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
