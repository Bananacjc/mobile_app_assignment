import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../model/vehicle.dart';
import '../model/global_user.dart';
import '../services/vehicle_service.dart';
import '../provider/navigation_provider.dart';

// 👇 add this import
import 'custom_widgets/ui_helper.dart';

class VehicleView extends StatelessWidget {
  VehicleView({super.key});

  final _service = VehicleService();

  @override
  Widget build(BuildContext context) {
    final uid = GlobalUser.user?.uid ?? '';
    final nav = Provider.of<NavigationProvider>(context, listen: false);

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
              "My Vehicles",
              style: TextStyle(
                color: AppColor.softWhite,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: FloatingActionButton(
          backgroundColor: AppColor.primaryGreen,
          onPressed: () => _openVehicleForm(context),
          child: const Icon(Icons.add, size: 28, color: AppColor.softWhite),
        ),
      ),
      body: uid.isEmpty
          ? const Center(child: Text('No logged-in user'))
          : StreamBuilder<List<Vehicle>>(
              stream: _service.streamUserVehicles(uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final vehicles = snap.data ?? [];
                if (vehicles.isEmpty) {
                  return _EmptyVehicleState(onAdd: () => _openVehicleForm(context));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: vehicles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final v = vehicles[i];
                    return _VehicleCard(
                      v: v,
                      onEdit: () => _openVehicleForm(context, vehicle: v),
                      onDelete: () async {
                        final ok = await _confirm(context, 'Delete this vehicle?');
                        if (ok != true) return;
                        await _service.deleteVehicle(v.plateNo); // using plateNo as key
                        if (context.mounted) {
                          UiHelper.showSnackBar(context, 'Vehicle deleted', isError: false);
                        }
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  // ---------- MODAL FORM ----------
  void _openVehicleForm(BuildContext context, {Vehicle? vehicle}) {
    final uid = GlobalUser.user?.uid;
    if (uid == null || uid.isEmpty) {
      UiHelper.showSnackBar(context, 'No logged-in user');
      return;
    }

    final formKey = GlobalKey<FormState>();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        String plateNo = vehicle?.plateNo ?? '';
        String? brand = vehicle?.brand;
        String? model = vehicle?.model;
        String? selectedColorHex = vehicle?.color; // hex

        final plateCtrl = TextEditingController(text: plateNo);
        final modelCtrl = TextEditingController(text: model ?? '');

        // simple plate format: 3–10 chars, A–Z 0–9 space hyphen
        final plateRegex = RegExp(r'^[A-Z0-9 -]{3,10}$');

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Future<void> save() async {
              if (!(formKey.currentState?.validate() ?? false)) return;

              final newPlate = plateCtrl.text.trim().toUpperCase();
              final modelText = modelCtrl.text.trim().isEmpty ? null : modelCtrl.text.trim();

              final payload = Vehicle(
                plateNo: newPlate,
                userId: uid,
                brand: (brand != null && brand!.trim().isNotEmpty) ? brand : null,
                model: modelText,
                color: (selectedColorHex != null && selectedColorHex!.trim().isNotEmpty)
                    ? selectedColorHex
                    : null,
              );

              try {
                setModalState(() => saving = true);

                if (vehicle == null) {
                  await VehicleService().addOrUpdateVehicle(payload);
                  if (context.mounted) {
                    UiHelper.showSnackBar(context, 'Vehicle saved', isError: false);
                  }
                } else {
                  final oldPlate = vehicle.plateNo.toUpperCase();
                  if (oldPlate != newPlate) {
                    await VehicleService().renamePlate(oldPlateNo: oldPlate, newVehicle: payload);
                  } else {
                    await VehicleService().addOrUpdateVehicle(payload);
                  }
                  if (context.mounted) {
                    UiHelper.showSnackBar(context, 'Vehicle updated', isError: false);
                  }
                }

                if (Navigator.canPop(ctx)) Navigator.pop(ctx);
              } catch (e) {
                if (context.mounted) {
                  UiHelper.showSnackBar(context, 'Save failed: $e');
                }
              } finally {
                if (ctx.mounted) setModalState(() => saving = false);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Text(
                            vehicle == null ? 'Add Vehicle' : 'Edit Vehicle',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColor.darkCharcoal,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              if (!saving && Navigator.canPop(ctx)) Navigator.pop(ctx);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Live Preview
                      _VehiclePreview(
                        brand: brand,
                        plate: plateCtrl.text,
                        colorHex: selectedColorHex,
                      ),

                      const SizedBox(height: 16),

                      // Plate No (required + format)
                      TextFormField(
                        controller: plateCtrl,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 -]')),
                        ],
                        decoration: _flatInput('Plate No'),
                        onChanged: (_) => setModalState(() {}), // update preview
                        validator: (val) {
                          final v = (val ?? '').trim().toUpperCase();
                          if (v.isEmpty) return 'Plate number is required';
                          if (v.length < 3) return 'Too short';
                          if (v.length > 10) return 'Too long';
                          if (!plateRegex.hasMatch(v)) {
                            return 'Only A–Z, 0–9, space, -';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Brand dropdown (optional)
                      DropdownButtonFormField<String>(
                        value: _brandItems.any((i) => i.value == brand) ? brand : null,
                        items: _brandItems,
                        hint: const Text('Brand', style: TextStyle(color: AppColor.slateGray)),
                        decoration: _flatInput(null),
                        onChanged: (v) => setModalState(() => brand = v),
                      ),
                      const SizedBox(height: 12),

                      // Model (optional)
                      TextFormField(
                        controller: modelCtrl,
                        decoration: _flatInput('Model'),
                      ),
                      const SizedBox(height: 16),

                      // Color palette (optional)
                      const Text(
                        'Color',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColor.darkCharcoal,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: kColorHexes.map((hex) {
                          final isSel = hex == selectedColorHex;
                          return GestureDetector(
                            onTap: () => setModalState(() => selectedColorHex = hex),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: _fromHex(hex),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSel ? AppColor.darkCharcoal : Colors.transparent,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSel)
                                  const Icon(Icons.check, size: 18, color: Colors.white),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // Save
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: saving ? null : save,
                          child: saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text(
                                  'Save Vehicle',
                                  style: TextStyle(
                                    color: AppColor.softWhite,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------- helpers ----------
  static InputDecoration _flatInput([String? hint]) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColor.slateGray),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColor.slateGray, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColor.primaryGreen, width: 2),
      ),
    );
  }

  static Future<bool?> _confirm(BuildContext context, String msg) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('OK')),
        ],
      ),
    );
  }
  // ❌ removed _toast
}

// ---------- EMPTY STATE WIDGET ----------
class _EmptyVehicleState extends StatelessWidget {
  const _EmptyVehicleState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.directions_car_filled, size: 72, color: AppColor.slateGray),
            const SizedBox(height: 12),
            const Text(
              'No vehicles yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColor.darkCharcoal),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first vehicle to make booking and switching easier.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColor.slateGray),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Vehicle'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- VEHICLE LIST CARD ----------
class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.v,
    required this.onEdit,
    required this.onDelete,
  });

  final Vehicle v;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isWhite   = _isWhite(v.color);
    final borderCol = _fromHex(v.color);
    final tileBg    = isWhite ? Colors.black : Colors.white;
    final iconColor = isWhite ? Colors.white : borderCol;

    final brandText = (v.brand == null || v.brand!.isEmpty) ? 'Brand' : v.brand!;
    final modelText = (v.model == null || v.model!.isEmpty) ? '' : ' • ${v.model}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: AppColor.darkCharcoal.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: tileBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isWhite ? Colors.black : borderCol, width: 2),
            ),
            child: Icon(Icons.directions_car, color: iconColor, size: 28),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$brandText$modelText', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColor.darkCharcoal,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Text(
                    v.plateNo.toUpperCase(),
                    style: const TextStyle(color: AppColor.softWhite, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),
          IconButton(tooltip: 'Edit',   onPressed: onEdit,   icon: const Icon(Icons.edit, color: AppColor.darkCharcoal)),
          IconButton(tooltip: 'Delete', onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: AppColor.wineRed)),
        ],
      ),
    );
  }
}

// ---------- LIVE PREVIEW ----------
class _VehiclePreview extends StatelessWidget {
  const _VehiclePreview({
    required this.brand,
    required this.plate,
    required this.colorHex,
  });

  final String? brand;
  final String plate;
  final String? colorHex;

  @override
  Widget build(BuildContext context) {
    final isWhite   = _isWhite(colorHex);
    final borderCol = _fromHex(colorHex);
    final tileBg    = isWhite ? Colors.black : Colors.white;
    final iconColor = isWhite ? Colors.white : borderCol;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColor.darkCharcoal.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: tileBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isWhite ? Colors.black : borderCol, width: 2),
            ),
            child: Icon(Icons.directions_car, size: 28, color: iconColor),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text((brand == null || brand!.isEmpty) ? 'Brand' : brand!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColor.darkCharcoal,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.black),
                ),
                child: Text(
                  (plate.isEmpty ? 'ABC 1234' : plate).toUpperCase(),
                  style: const TextStyle(color: AppColor.softWhite, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------- constants & utils ----------
const List<DropdownMenuItem<String>> _brandItems = [
  DropdownMenuItem(value: 'Mercedes-Benz', child: Text('Mercedes-Benz')),
  DropdownMenuItem(value: 'Toyota',        child: Text('Toyota')),
  DropdownMenuItem(value: 'Honda',         child: Text('Honda')),
  DropdownMenuItem(value: 'Proton',        child: Text('Proton')),
  DropdownMenuItem(value: 'Perodua',       child: Text('Perodua')),
  DropdownMenuItem(value: 'BMW',           child: Text('BMW')),
  DropdownMenuItem(value: 'Audi',          child: Text('Audi')),
  DropdownMenuItem(value: 'Mazda',         child: Text('Mazda')),
  DropdownMenuItem(value: 'Nissan',        child: Text('Nissan')),
  DropdownMenuItem(value: 'Hyundai',       child: Text('Hyundai')),
];

/// Swatches (hex)
const List<String> kColorHexes = [
  '#000000', // black
  '#FFFFFF', // white
  '#1E90FF', // dodger blue
  '#1976D2', // blue 700
  '#3F51B5', // indigo
  '#00BCD4', // cyan
  '#4CAF50', // green
  '#8BC34A', // light green
  '#FFC107', // amber
  '#FF9800', // orange
  '#FF7043', // deep orange 300
  '#FF4D4D', // soft red
  '#9C27B0', // purple
  '#795548', // brown
  '#607D8B', // blue grey
  '#A4A4A4', // silver
];

bool _isWhite(String? hex) => (hex ?? '').toUpperCase() == '#FFFFFF';

Color _fromHex(String? hex) {
  if (hex == null || hex.isEmpty) return const Color(0xFFCCCCCC);
  final clean = hex.replaceAll('#', '');
  final withAlpha = clean.length == 6 ? 'FF$clean' : clean;
  try {
    return Color(int.parse(withAlpha, radix: 16));
  } catch (_) {
    return const Color(0xFFCCCCCC);
  }
}
