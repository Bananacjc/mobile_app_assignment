// view/book_service_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../model/service.dart';
import '../model/vehicle.dart';
import '../model/global_user.dart';
import '../provider/navigation_provider.dart';
import '../services/service_service.dart';
import '../services/vehicle_service.dart';
import 'vehicle_view.dart';
import 'custom_widgets/ui_helper.dart';

class BookServiceView extends StatefulWidget {
  const BookServiceView({super.key});

  @override
  State<BookServiceView> createState() => _BookServiceViewState();
}

class _BookServiceViewState extends State<BookServiceView> {
  // form state
  String? _selectedService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _notesController = TextEditingController();

  // selected vehicle (null until chosen / auto-defaulted)
  String? _plateNo;
  String? _brand;
  String? _colorHex;

  bool _didSetDefault = false; // ensure we only default once per load

  // ---------- helpers ----------
  Color _fromHex(String hex) {
    final c = hex.replaceAll('#', '');
    final withAlpha = c.length == 6 ? 'FF$c' : c;
    return Color(int.parse(withAlpha, radix: 16));
  }

  bool _isWhite(String? hex) => (hex ?? '').toUpperCase() == '#FFFFFF';

  InputDecoration _flatInput(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColor.slateGray, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColor.slateGray, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColor.primaryGreen, width: 2),
        ),
      );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
    if (picked != null) setState(() => _selectedTime = picked);
  }

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
                  stream: VehicleService().streamUserVehicles(user.uid),
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
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => VehicleView()),
                          );
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
                          onTap: () {
                            setState(() {
                              _plateNo = v.plateNo;
                              _brand = v.brand ?? 'Brand';
                              _colorHex = v.color ?? '#A4A4A4';
                            });
                            Navigator.pop(ctx);
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

  bool _formLooksValid() {
    if (_plateNo == null ||
        _selectedService == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      return false;
    }
    final appt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    return appt.isAfter(DateTime.now());
  }

  void _validateOrWarnThenSubmit() async {
    if (_plateNo == null) {
      UiHelper.showSnackBar(context, 'Please pick a vehicle.');
      return;
    }
    if (_selectedService == null) {
      UiHelper.showSnackBar(context, 'Please select a service.');
      return;
    }
    if (_selectedDate == null) {
      UiHelper.showSnackBar(context, 'Please choose a date.');
      return;
    }
    if (_selectedTime == null) {
      UiHelper.showSnackBar(context, 'Please choose a time.');
      return;
    }
    final appt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    if (!appt.isAfter(DateTime.now())) {
      UiHelper.showSnackBar(context, 'Please choose a future date & time.');
      return;
    }

    final user = GlobalUser.user;
    if (user == null) {
      UiHelper.showSnackBar(context, 'You must be logged in to book.');
      return;
    }

    final service = Service(
      serviceId: '',
      userId: user.uid,
      plateNo: _plateNo!, // required
      title: _selectedService!,
      note: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      status: 'inspection',
      fee: null,
      duration: null,
      appointmentDate: appt,
    );

    final ref = await ServiceService().addService(service);
    if (!mounted) return;

    if (ref != null) {
      UiHelper.showSnackBar(context, 'Service booked!', isError: false);
      context.read<NavigationProvider>().goBack();
    } else {
      UiHelper.showSnackBar(
          context, 'Failed to book service. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);
    final nav = context.read<NavigationProvider>();
    final user = GlobalUser.user;

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
            onPressed: () => nav.goBack(),
          ),
          title: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Book Service',
              style: TextStyle(
                color: AppColor.softWhite,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ),
      body: user == null
          ? const Center(child: Text('You must be logged in to book.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // -------- VEHICLE (defaults to first) --------
                  StreamBuilder<List<Vehicle>>(
                    stream: VehicleService().streamUserVehicles(user.uid),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return _VehicleCardSkeleton();
                      }
                      if (snap.hasError) {
                        return Center(
                          child: Text('Error loading vehicles: ${snap.error}'),
                        );
                      }
                      final vehicles = snap.data ?? [];

                      if (vehicles.isEmpty) {
                        // No vehicles -> empty state with link to VehicleView
                        return _NoVehicleMessage(
                          onAddVehicle: () {
                            navigationProvider.showFullPageContent(
                              VehicleView(),
                            );
                          },
                        );
                      }

                      // Default to first vehicle once (when nothing chosen yet)
                      if (!_didSetDefault &&
                          _plateNo == null &&
                          vehicles.isNotEmpty) {
                        _didSetDefault = true;
                        final first = vehicles.first;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          setState(() {
                            _plateNo = first.plateNo;
                            _brand = first.brand ?? 'Brand';
                            _colorHex = first.color ?? '#A4A4A4';
                          });
                        });
                      }

                      final hex = (_colorHex ?? '#A4A4A4').toUpperCase();
                      final white = _isWhite(hex);
                      final borderColor =
                          white ? Colors.black : _fromHex(hex);
                      final tileBg = white ? Colors.black : Colors.white;
                      final iconColor = white ? Colors.white : borderColor;

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.darkCharcoal.withAlpha(40),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
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
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _brand ?? 'Brand',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
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
                                    (_plateNo ?? '').toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColor.softWhite,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primaryGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                              ),
                              onPressed: _openVehiclePicker,
                              child: const Text(
                                'Switch',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // -------- Service --------
                  DropdownButtonFormField<String>(
                    decoration: _flatInput('Select Service'),
                    value: _selectedService,
                    items: const [
                      'Brake Service',
                      'Engine Diagnostics',
                      'Battery Replacement',
                      'Air Conditioning Service',
                      'Tire Replacement',
                      'Suspension Inspection',
                      'Transmission Service',
                      'Radiator & Cooling System',
                      'Power Steering Service',
                      'Wiper Replacement',
                      'Headlight/Taillight Replacement',
                      'Oil Change',
                      'Alignment & Balancing',
                      'Spark Plug Replacement',
                      'Exhaust Inspection',
                    ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setState(() => _selectedService = v),
                  ),
                  const SizedBox(height: 16),

                  // -------- Date & Time --------
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: _flatInput('Preferred Date'),
                            child: Text(
                              _selectedDate == null
                                  ? 'dd - - - - yyyy'
                                  : '${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: _pickTime,
                          child: InputDecorator(
                            decoration: _flatInput('Preferred Time'),
                            child: Text(
                              _selectedTime == null
                                  ? 'Select time'
                                  : _selectedTime!.format(context),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // -------- Notes --------
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: _flatInput(
                      'Describe any specific issues or requirements...',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // -------- Book Button --------
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _validateOrWarnThenSubmit,
                      child: const Text(
                        'Book Service',
                        style: TextStyle(
                          color: AppColor.softWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ---------- Small UI helpers ----------

class _NoVehicleMessage extends StatelessWidget {
  const _NoVehicleMessage({required this.onAddVehicle});
  final VoidCallback onAddVehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Icon(
            Icons.directions_car_filled,
            size: 56,
            color: AppColor.slateGray,
          ),
          const SizedBox(height: 10),
          const Text(
            'No vehicles found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColor.darkCharcoal,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add your vehicle to continue booking a service.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColor.slateGray),
          ),
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

class _VehicleCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 120, color: Colors.black12),
                const SizedBox(height: 8),
                Container(height: 18, width: 90, color: Colors.black12),
              ],
            ),
          ),
          Container(height: 36, width: 80, color: Colors.black12),
        ],
      ),
    );
  }
}
