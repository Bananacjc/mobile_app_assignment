import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class BookServiceView extends StatefulWidget {
  const BookServiceView({super.key});

  @override
  State<BookServiceView> createState() => _BookServiceViewState();
}

class _BookServiceViewState extends State<BookServiceView> {
  String? _selectedService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _notesController = TextEditingController();

  InputDecoration _flatInput(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColor.slateGray, fontSize: 14),
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColor.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColor.darkCharcoal,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

Future<void> _pickTime() async {
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: const TimePickerThemeData(
            dayPeriodColor: AppColor.accentMint,   // AM/PM background
            dayPeriodTextColor: AppColor.darkCharcoal,  // AM/PM text
            dayPeriodShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              side: BorderSide(color: AppColor.primaryGreen),
            ),
          ),
          colorScheme: const ColorScheme.light(
            primary: AppColor.primaryGreen,       // active numbers, buttons
            onPrimary: Colors.white,              // text on active bg
            onSurface: AppColor.darkCharcoal,     // inactive text
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    setState(() => _selectedTime = picked);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.softWhite,
      appBar: AppBar(
        backgroundColor: AppColor.primaryGreen,
        elevation: 0,
        title: const Text(
          "Book Service",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColor.softWhite,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🚗 Vehicle Card
            Container(
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
                  // car icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColor.wineRed, width: 2),
                    ),
                    child: const Icon(Icons.directions_car,
                        color: AppColor.wineRed, size: 28),
                  ),
                  const SizedBox(width: 12),

                  // text part
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Benz C63",
                        style: TextStyle(
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
                        child: const Text(
                          "BFP 1975",
                          style: TextStyle(
                            color: AppColor.softWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Switch button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Switch",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🔧 Service Type Dropdown
            DropdownButtonFormField<String>(
              decoration: _flatInput("Select Service Type"),
              value: _selectedService,
              items: ["Oil Change", "Brake Service", "Tire Rotation"]
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                setState(() => _selectedService = val);
              },
            ),
            const SizedBox(height: 16),

            // 📅 Date and Time Row
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: _flatInput("Preferred Date"),
                      child: Text(
                        _selectedDate == null
                            ? "dd - - - - yyyy"
                            : "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}",
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
                      decoration: _flatInput("Preferred Time"),
                      child: Text(
                        _selectedTime == null
                            ? "Select time"
                            : _selectedTime!.format(context),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 📝 Notes
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: _flatInput(
                "Describe any specific issues or requirements...",
              ),
            ),
            const SizedBox(height: 20),

            // 📌 Book Button
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Service booked!")),
                  );
                },
                child: const Text(
                  "Book Service",
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
