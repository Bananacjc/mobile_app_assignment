import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ServiceScheduleItem extends StatefulWidget {
  final String cust_id;
  final String service_id;
  final String title;
  final String fee;
  final String status;
  final String duration;
  final DateTime appointment_date;

  const ServiceScheduleItem({
    super.key,
    required this.cust_id,
    required this.service_id,
    required this.title,
    required this.fee,
    required this.status,
    required this.duration,
    required this.appointment_date,
  });

  @override
  State<ServiceScheduleItem> createState() => _ServiceScheduleItemState();
}

class _ServiceScheduleItemState extends State<ServiceScheduleItem> {
  String _cust_id = "";
  String _service_id = "";
  String _title = "";
  String _fee = "";
  String _status = "";
  String _duration = "";
  DateTime _appointment_date = new DateTime.now();


  @override
  void initState() {
    super.initState();
    _cust_id = widget.cust_id;
    _service_id = widget.service_id;
    _title = widget.title;
    _fee = widget.fee;
    _status = widget.status;
    _duration = widget.duration;
    _appointment_date = widget.appointment_date;

  }

  Future<void> _loadData() async {
    // Retrieve

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 20),
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
          width: 360,
          height: 160,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10, top: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColor.primaryGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.add,
                              color: AppColor.softWhite,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        width: 100,
                        child: Text(
                          "Brake Oil Service",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10, right: 10),
                        child: Text(
                          "IN INSPECTION",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5, right: 10),
                        child: Container(
                          //color: AppColor.darkCharcoal,
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.darkCharcoal,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.black),
                          ),
                          child: Text(
                            "BFP 1975",
                            style: TextStyle(
                              color: AppColor.softWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Divider(
                indent: 10, // adjust later
                endIndent: 10,
                color: AppColor.slateGray.withAlpha(63),
                thickness: 1,
              ),

              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "ETA : 3:00 PM",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.softWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: AppColor.darkCharcoal,
                          width: 1,
                        ),
                      ),
                      minimumSize: Size(340, 40),
                    ),
                    onPressed: () {},
                    child: Text(
                      "View Details",
                      style: TextStyle(color: AppColor.darkCharcoal),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    // ----------------- IN PROGRESS END ----------------- //;
  }
}
