import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../model/global_user.dart';
import '../model/service.dart';
import '../model/vehicle.dart';
import '../model/reminder.dart';

import '../provider/navigation_provider.dart';
import '../services/vehicle_service.dart';
import '../services/service_service.dart';
import '../services/reminder_service.dart';

import 'book_service_view.dart';
import 'vehicle_view.dart';
import 'custom_widgets/ui_helper.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final VehicleService _vs = VehicleService();
  final ServiceService _ss = ServiceService();
  final ReminderService _rs = ReminderService();

  final String _userId = GlobalUser.user!.uid;

  // --- vehicle selection (copied pattern from BookServiceView)
  String? _plateNo;
  String? _brand;
  String? _colorHex;
  bool _didSetDefault = false;

  // reminder cards
  List<Widget> _reminderCards = [];

  // categories shown
  final List<String> _categories = const [
    "Brake Service",
    "Engine Diagnostics",
    "Battery Replacement",
    "Air Conditioning Service",
    "Tire Replacement",
    "Suspension Inspection",
    "Transmission Service",
    "Radiator & Cooling System",
    "Power Steering Service",
    "Wiper Replacement",
    "Headlight/Taillight Replacement",
  ];

  final Map<String, IconData> categoriesIcons = {
    "Brake Service": Icons.car_repair_rounded,
    "Engine Diagnostics":Icons.handyman_rounded,
    "Battery Replacement":Icons.battery_5_bar_rounded,
    "Air Conditioning Service":Icons.air_rounded,
    "Tire Replacement":Icons.album_rounded,
    "Suspension Inspection":Icons.find_replace_rounded,
    "Transmission Service":Icons.settings_rounded,
    "Radiator & Cooling System":Icons.air_rounded,
    "Power Steering Service":Icons.settings_input_svideo_rounded,
    "Wiper Replacement":Icons.water_drop_rounded,
    "Headlight/Taillight Replacement":Icons.lightbulb_rounded,
  };

  // ---------- helpers (same style as BookServiceView) ----------
  Color _fromHex(String hex) {
    final c = hex.replaceAll('#', '');
    final withAlpha = c.length == 6 ? 'FF$c' : c;
    return Color(int.parse(withAlpha, radix: 16));
  }

  bool _isWhite(String? hex) => (hex ?? '').toUpperCase() == '#FFFFFF';

  // ---------- reminder helpers ----------
  double _progress0to1(DateTime start, DateTime end) {
    final now = DateTime.now();
    if (now.isBefore(start)) return 0.0;
    if (now.isAfter(end)) return 1.0;
    final total = end.difference(start).inMilliseconds;
    final elapsed = now.difference(start).inMilliseconds;
    if (total <= 0) return 0.0;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  Color _progressColor(double v) {
    if (v >= .75) return AppColor.wineRed;
    if (v >= .50) return Colors.deepOrangeAccent;
    return AppColor.primaryGreen;
  }

  Future<Service?> _lastCompletedFor(String plate, String category) async {
    // If you already have a getSelectedCompletedServices, feel free to use it.
    final all = await _ss.getAllCompletedServices(_userId);
    final filtered = all
        .where((s) =>
            s.plateNo.toUpperCase() == plate.toUpperCase() &&
            s.title?.trim() == category &&
            s.appointmentDate != null)
        .toList();
    filtered.sort((a, b) => b.appointmentDate!.compareTo(a.appointmentDate!));
    return filtered.isNotEmpty ? filtered.first : null;
  }

  Future<void> _loadCardsForPlate(String plate) async {
    final widgets = await Future.wait(
      _categories.map((c) => _buildReminderCard(c, plate)),
    );
    if (!mounted) return;
    setState(() => _reminderCards = widgets);
  }

  Future<Widget> _buildReminderCard(String category, String plate) async {
    // Always attempt to read reminder first so "Due At" is not '-'
    final reminder = await _rs.getReminder(_userId, plate, category);
    String dueAtDisplay = reminder?.reminderDate != null
        ? DateFormat('dd MMM yyyy').format(reminder!.reminderDate!)
        : "-";

    // Last service (for progress only; Due At shows even without last service)
    final last = await _lastCompletedFor(plate, category);
    String lastServiceDisplay =
        last?.appointmentDate != null ? DateFormat('dd MMM yyyy').format(last!.appointmentDate!) : "-";

    // compute progress only if we have both dates
    double progress = 0.0;
    if (last?.appointmentDate != null && reminder?.reminderDate != null) {
      progress = _progress0to1(last!.appointmentDate!, reminder!.reminderDate!);
    }
    final accent = _progressColor(progress);

    final nav = context.read<NavigationProvider>();
    final width = MediaQuery.of(context).size.width;
    final cardW = width - 24;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Container(
        width: cardW,
        decoration: BoxDecoration(
          border: Border.all(color: accent),
          color: AppColor.softWhite,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(.35),
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            children: [
              // header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(categoriesIcons[category],
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      category,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(.15),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      progress >= 1.0 ? "Due" : "Reminder",
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // info row
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text("Last Service",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(lastServiceDisplay,
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text("Due At",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(dueAtDisplay,
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // progress (always 0..1)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: AppColor.darkCharcoal.withOpacity(.15),
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
              ),
              const SizedBox(height: 12),

              // actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          nav.showFullPageContent(const BookServiceView()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(0, 40),
                      ),
                      child: const Text(
                        "Book Service",
                        style: TextStyle(
                          color: AppColor.softWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _openReminderSheet(category, plate, accent),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColor.darkCharcoal),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(0, 40),
                      ),
                      child: const Text(
                        "Set Reminder",
                        style: TextStyle(
                          color: AppColor.darkCharcoal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openReminderSheet(
      String category, String plate, Color accent) async {
    DateTime? pickedDate;
    final existing = await _rs.getReminder(_userId, plate, category);
    pickedDate = existing?.reminderDate;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setBS) {
            Future<void> pickDate() async {
              final now = DateTime.now();
              final init = pickedDate ?? now.add(const Duration(days: 90));
              final d = await showDatePicker(
                context: ctx,
                firstDate: now,
                lastDate: DateTime(now.year + 3),
                initialDate: init,
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColor.primaryGreen,
                      onPrimary: Colors.white,
                      onSurface: AppColor.darkCharcoal,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (d != null) setBS(() => pickedDate = d);
            }

            Future<void> save() async {
              if (pickedDate == null) {
                UiHelper.showSnackBar(ctx, 'Pick a date for the reminder.');
                return;
              }
              final reminder = Reminder(
                userId: _userId,
                plateNo: plate, // IMPORTANT: tie to the selected car
                type: category,
                reminderDate: pickedDate,
              );
              final ok = await _rs.updateReminder(reminder) ||
                  (await _rs.addReminder(reminder)) != null;

              if (!mounted) return;
              if (ok) {
                UiHelper.showSnackBar(context, 'Reminder saved', isError: false);
                Navigator.pop(ctx);
                await _loadCardsForPlate(plate); // refresh Due At now
              } else {
                UiHelper.showSnackBar(context, 'Failed to save reminder');
              }
            }

            Future<void> remove() async {
              final ok = await _rs.deleteReminder(_userId, plate, category);
              if (!mounted) return;
              if (ok) {
                UiHelper.showSnackBar(context, 'Reminder deleted', isError: false);
                Navigator.pop(ctx);
                await _loadCardsForPlate(plate);
              } else {
                UiHelper.showSnackBar(context, 'Failed to delete reminder');
              }
            }

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Set Reminder • $category\nPlate: $plate',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.event, color: accent),
                    title: const Text('Reminder date'),
                    subtitle: Text(pickedDate == null
                        ? 'Not set'
                        : DateFormat('dd MMM yyyy').format(pickedDate!)),
                    trailing: const Icon(Icons.edit_calendar),
                    onTap: pickDate,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: const Size(0, 44),
                          ),
                          child: const Text('Save',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (existing != null)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: remove,
                            style: OutlinedButton.styleFrom(
                              side:
                                  const BorderSide(color: AppColor.darkCharcoal),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: const Size(0, 44),
                            ),
                            child: const Text('Delete',
                                style:
                                    TextStyle(color: AppColor.darkCharcoal)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------- vehicle picker (copied behavior from BookServiceView) ----------
  Future<void> _openVehiclePicker() async {
    final user = GlobalUser.user;
    if (user == null) {
      UiHelper.showSnackBar(context, 'You must be logged in to pick a vehicle.');
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.75,
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text(
                'Select Vehicle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<List<Vehicle>>(
                  stream: _vs.streamUserVehicles(user.uid),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(child: Text('Error: ${snap.error}'));
                    }
                    final vehicles = snap.data ?? [];
                    if (vehicles.isEmpty) {
                      return _NoVehicleMessage(
                        onAddVehicle: () {
                          Navigator.pop(ctx);
                          context
                              .read<NavigationProvider>()
                              .showFullPageContent(VehicleView());
                        },
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: vehicles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final v = vehicles[i];
                        final hex = (v.color ?? '#A4A4A4').toUpperCase();
                        final white = _isWhite(hex);
                        final border = white ? Colors.black : _fromHex(hex);
                        final tileBg = white ? Colors.black : Colors.white;
                        final icon = white ? Colors.white : border;

                        return InkWell(
                          onTap: () async {
                            setState(() {
                              _plateNo = v.plateNo;
                              _brand = v.brand ?? 'Brand';
                              _colorHex = v.color ?? '#A4A4A4';
                            });
                            Navigator.pop(ctx);
                            await _loadCardsForPlate(_plateNo!);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: tileBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: border, width: 2),
                                  ),
                                  child: Icon(
                                    Icons.directions_car,
                                    color: icon,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        v.brand ?? 'Brand',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        v.plateNo.toUpperCase(),
                                        style: const TextStyle(
                                          color: AppColor.slateGray,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();
    final user = GlobalUser.user;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColor.softWhite,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: AppBar(
          toolbarHeight: 150,
          centerTitle: false,
          title: Padding(
            padding: const EdgeInsets.only(left: 0, top: 0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Welcome, ${user?.displayName ?? 'Guest'}",
                    style: const TextStyle(
                      color: AppColor.softWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),

                // ---- Vehicle header (same look/logic as BookServiceView)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: StreamBuilder<List<Vehicle>>(
                      stream: user == null
                          ? const Stream.empty()
                          : _vs.streamUserVehicles(user.uid),
                      builder: (context, snap) {
                        final vehicles = snap.data ?? [];
                        // default to first once
                        if (!_didSetDefault &&
                            _plateNo == null &&
                            vehicles.isNotEmpty) {
                          _didSetDefault = true;
                          final first = vehicles.first;
                          WidgetsBinding.instance.addPostFrameCallback((_) async {
                            if (!mounted) return;
                            setState(() {
                              _plateNo = first.plateNo;
                              _brand = first.brand ?? 'Brand';
                              _colorHex = first.color ?? '#A4A4A4';
                            });
                            await _loadCardsForPlate(_plateNo!);
                          });
                        }

                        final hex = (_colorHex ?? '#A4A4A4').toUpperCase();
                        final white = _isWhite(hex);
                        final borderColor =
                            white ? Colors.black : _fromHex(hex);
                        final tileBg = white ? Colors.black : Colors.white;
                        final iconColor = white ? Colors.white : borderColor;

                        return Container(
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
                          width: MediaQuery.of(context).size.width - 24,
                          height: 70,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: tileBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: borderColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.directions_car,
                                    color: iconColor,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: vehicles.isEmpty
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              'No vehicles found',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Add your vehicle to continue',
                                              style: TextStyle(
                                                  color: AppColor.slateGray),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _brand ?? 'Brand',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: AppColor.darkCharcoal,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: Border.all(
                                                    color: Colors.black),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              child: Text(
                                                (_plateNo ?? '').toUpperCase(),
                                                style: const TextStyle(
                                                  color: AppColor.softWhite,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.primaryGreen,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    minimumSize: const Size(35, 35),
                                  ),
                                  onPressed: vehicles.isEmpty
                                      ? () => nav
                                          .showFullPageContent(VehicleView())
                                      : _openVehiclePicker,
                                  child: Text(
                                    vehicles.isEmpty ? "Add" : "Switch",
                                    style: const TextStyle(
                                        color: AppColor.softWhite),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: AppColor.primaryGreen,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: _reminderCards),
      ),
    );
  }
}

// ---------- Simple "no vehicle" card for the sheet ----------
class _NoVehicleMessage extends StatelessWidget {
  const _NoVehicleMessage({required this.onAddVehicle});
  final VoidCallback onAddVehicle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_car_filled,
              size: 56, color: AppColor.slateGray),
          const SizedBox(height: 10),
          const Text('No vehicles found',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColor.darkCharcoal)),
          const SizedBox(height: 6),
          const Text('Add your vehicle to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColor.slateGray)),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onAddVehicle,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Go to My Vehicles'),
          ),
        ],
      ),
    );
  }
}
