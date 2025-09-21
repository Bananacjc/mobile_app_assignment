// lib/view/vehicle_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/theme/app_colors.dart';
import '../model/global_user.dart';
import '../model/vehicle.dart';
import '../services/vehicle_service.dart';

class VehicleView extends StatefulWidget {
  const VehicleView({super.key});

  @override
  State<VehicleView> createState() => _VehicleViewState();
}

class _VehicleViewState extends State<VehicleView> {
  final _service = VehicleService();

  // --- Brand list (extend as you like)
  final List<String> _brands = const [
    'Perodua',
    'Proton',
    'Toyota',
    'Honda',
    'Nissan',
    'Mazda',
    'Mitsubishi',
    'BMW',
    'Mercedes-Benz',
    'Audi',
    'Volkswagen',
    'Hyundai',
    'Kia',
    'Tesla',
  ];

  // --- Color palette (label -> Color)
  final Map<String, Color> _colorOptions = const {
    'Black': Color(0xFF000000),
    'White': Color(0xFFFFFFFF),
    'Silver': Color(0xFFC0C0C0),
    'Gray': Color(0xFF6E6E6E),
    'Red': Color(0xFFCF2E2E),
    'Wine': Color(0xFF7B1E1E),
    'Orange': Color(0xFFFF7A00),
    'Yellow': Color(0xFFFFD166),
    'Green': Color(0xFF218662), // match your theme
    'Mint': Color(0xFF29A87A),
    'Teal': Color(0xFF2CB1A5),
    'Blue': Color(0xFF1E90FF),
    'Navy': Color(0xFF1B2A49),
    'Purple': Color(0xFF6A54E4),
    'Magenta': Color(0xFFD81B60),
    'Brown': Color(0xFF6D4C41),
    'Beige': Color(0xFFF5E9D2),
    'Gold': Color(0xFFFFC107),
  };

  // Helpers to convert between Color <-> hex string (#RRGGBB)
  static String _colorToHex(Color c) {
    final rgb = c.value.toRadixString(16).padLeft(8, '0').substring(2); // drop alpha
    return '#${rgb.toUpperCase()}';
  }

  static Color _hexToColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColor.slateGray;
    var cleaned = hex.replaceAll('#', '').replaceAll('0x', '');
    if (cleaned.length == 6) cleaned = 'FF$cleaned';
    final val = int.tryParse(cleaned, radix: 16) ?? 0xFF6E6E6E;
    return Color(val);
    }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
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
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Vehicle',
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
          ? const Center(
              child: Text(
                'Please log in to manage vehicles.',
                style: TextStyle(color: AppColor.darkCharcoal),
              ),
            )
          : StreamBuilder<List<Vehicle>>(
              stream: _service.streamUserVehicles(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final vehicles = snapshot.data ?? [];
                if (vehicles.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No vehicles yet',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColor.darkCharcoal,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first vehicle to make booking easier.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColor.slateGray.withOpacity(.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: vehicles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final v = vehicles[i];
                    return _vehicleCard(v);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.primaryGreen,
        onPressed: () => _openVehicleForm(),
        child: const Icon(Icons.add, color: AppColor.softWhite),
      ),
    );
  }

  // ---------- Cards ----------
  Widget _vehicleCard(Vehicle v) {
    final color = _hexToColor(v.color);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColor.darkCharcoal.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColor.primaryGreen.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.directions_car, color: AppColor.primaryGreen),
        ),
        title: Text(
          v.brand != null && v.brand!.isNotEmpty
              ? '${v.brand} ${v.model ?? ''}'.trim()
              : (v.model ?? 'Vehicle'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColor.darkCharcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColor.darkCharcoal,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black),
              ),
              child: Text(
                v.plateNo,
                style: const TextStyle(
                  color: AppColor.softWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (v.color != null)
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColor.darkCharcoal.withOpacity(0.2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    v.color!, // shows hex
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.slateGray.withOpacity(.9),
                    ),
                  ),
                ],
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined, color: AppColor.darkCharcoal),
              onPressed: () => _openVehicleForm(existing: v),
            ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline, color: AppColor.wineRed),
              onPressed: () => _deleteVehicle(v),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Form ----------
  Future<void> _openVehicleForm({Vehicle? existing}) async {
    final user = GlobalUser.user;
    if (user == null) return;

    final formKey = GlobalKey<FormState>();

    String? vehicleId = existing?.vehicleId;
    String plate = existing?.plateNo ?? '';
    String brand = existing?.brand ?? _brands.first;
    String model = existing?.model ?? '';
    // store hex, but keep Color for preview
    String? colorHex = existing?.color;
    Color? selectedColor = _hexToColor(colorHex ?? '#6E6E6E');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          minChildSize: 0.35,
          initialChildSize: 0.75,
          maxChildSize: 0.92,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: AppColor.softWhite,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.darkCharcoal.withOpacity(.2),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                    top: 12,
                  ),
                  child: Form(
                    key: formKey,
                    child: ListView(
                      controller: controller,
                      children: [
                        Row(
                          children: [
                            Text(
                              existing == null ? 'Add Vehicle' : 'Edit Vehicle',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColor.darkCharcoal,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: AppColor.darkCharcoal),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Plate No
                        TextFormField(
                          initialValue: plate,
                          decoration: _input('Plate No'),
                          textCapitalization: TextCapitalization.characters,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Plate number required' : null,
                          onChanged: (v) => plate = v.trim().toUpperCase(),
                        ),
                        const SizedBox(height: 12),

                        // Brand (dropdown)
                        DropdownButtonFormField<String>(
                          value: brand,
                          decoration: _input('Brand'),
                          items: _brands
                              .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                              .toList(),
                          onChanged: (v) => brand = v ?? brand,
                        ),
                        const SizedBox(height: 12),

                        // Model (free text so far)
                        TextFormField(
                          initialValue: model,
                          decoration: _input('Model'),
                          onChanged: (v) => model = v.trim(),
                        ),
                        const SizedBox(height: 16),

                        // Color picker row
                        Row(
                          children: [
                            const Text(
                              'Color',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColor.darkCharcoal,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: selectedColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColor.darkCharcoal.withOpacity(0.25),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              colorHex ?? '--',
                              style: const TextStyle(color: AppColor.darkCharcoal),
                            ),
                            const Spacer(),
                            OutlinedButton.icon(
                              onPressed: () async {
                                final chosen = await showModalBottomSheet<Color>(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => _ColorPaletteSheet(
                                    options: _colorOptions,
                                    initial: selectedColor,
                                  ),
                                );
                                if (chosen != null) {
                                  setState(() {
                                    selectedColor = chosen;
                                    colorHex = _colorToHex(chosen);
                                  });
                                }
                              },
                              icon: const Icon(Icons.palette_outlined, size: 18),
                              label: const Text('Pick color'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColor.darkCharcoal,
                                side: const BorderSide(color: AppColor.slateGray),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Save button
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;

                              final v = Vehicle(
                                vehicleId: vehicleId ?? '',
                                userId: user.uid,
                                plateNo: plate,
                                brand: brand,
                                model: model.isEmpty ? null : model,
                                color: colorHex, // store hex string
                              );

                              final ok = await _saveVehicle(v, isEdit: existing != null);
                              if (!mounted) return;

                              if (ok) Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                color: AppColor.softWhite,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------- Actions ----------
  Future<bool> _saveVehicle(Vehicle v, {required bool isEdit}) async {
    try {
      if (isEdit) {
        await _service.updateVehicle(v);
      } else {
        await _service.addVehicle(v); // service should set the new vehicleId
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEdit ? 'Vehicle updated' : 'Vehicle added')),
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
      return false;
    }
  }

  Future<void> _deleteVehicle(Vehicle v) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete vehicle?'),
        content: Text('Remove ${v.plateNo}? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _service.deleteVehicle(v.vehicleId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  // ---------- Styling ----------
  InputDecoration _input(String hint) => InputDecoration(
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

// --------------- Bottom Sheet Palette ----------------
class _ColorPaletteSheet extends StatelessWidget {
  final Map<String, Color> options;
  final Color? initial;
  const _ColorPaletteSheet({required this.options, this.initial});

  @override
  Widget build(BuildContext context) {
    final entries = options.entries.toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColor.softWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: AppColor.darkCharcoal.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    'Choose a color',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColor.darkCharcoal,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColor.darkCharcoal),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: .85,
                ),
                itemCount: entries.length,
                itemBuilder: (_, i) {
                  final label = entries[i].key;
                  final color = entries[i].value;
                  final selected = initial?.value == color.value;

                  return InkWell(
                    onTap: () => Navigator.pop(context, color),
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? AppColor.primaryGreen
                                      : AppColor.darkCharcoal.withOpacity(0.2),
                                  width: selected ? 3 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor.darkCharcoal.withOpacity(.15),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            if (selected)
                              const Icon(Icons.check, size: 18, color: Colors.white),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
