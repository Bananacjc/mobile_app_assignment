import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app_assignment/core/theme/app_colors.dart';
import 'package:mobile_app_assignment/core/tool.dart';
import 'package:mobile_app_assignment/model/service.dart';
import 'package:mobile_app_assignment/services/feedback_service.dart';
import 'package:mobile_app_assignment/services/service_service.dart';

class ServiceItem extends StatefulWidget {
  final Service service;
  final bool inProgress;

  const ServiceItem({
    super.key,
    required this.service,
    required this.inProgress
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
    'completed': "Service Completed"
  };
  final String userId = "U001"; // use global key later
  String serviceTitle = "";
  String? topRightCornerDisplay;
  String plateNoDisplay = "N/A";
  String? middleLeftDisplay;
  String? feeDisplay;
  int buttonDisplay = 2;
  String? buttonName;


  @override
void initState() {
  super.initState();
  DateTime now = DateTime.now();

  serviceTitle = widget.service.title ?? "Untitled";
  plateNoDisplay = widget.service.plateNo;
  feeDisplay = widget.service.fee != null
      ? "RM ${widget.service.fee!.toStringAsFixed(2)}"
      : "";
  DateTime? endAppointment = widget.service.appointmentDate != null && widget.service.duration != null
      ? widget.service.appointmentDate!.add(Duration(minutes: widget.service.duration!))
      : null;
  // if(now.isAfter(widget.service.appointmentDate!) && now.isBefore(endAppointment)){ // change to boolean check only
  if(widget.inProgress){
    topRightCornerDisplay = serviceStatus[widget.service.status]; // display status instead of time
    if(widget.inProgress && widget.service.status != "pending"){
      buttonDisplay = 1;
    }
  } else {
    topRightCornerDisplay = DateFormat("dd MMM yyyy, h:mm a").format(widget.service.appointmentDate!);
  }

  if(widget.inProgress){
    middleLeftDisplay = "ETA ${DateFormat.jm().format(endAppointment!)}";
    if(widget.service.status == "pending"){
      buttonName = "Pay";
      middleLeftDisplay = "";
    }else if(widget.service.status == "inspection"){
      feeDisplay = "";
      middleLeftDisplay = "";
    }
  }else {

    if (widget.service.status != "completed"){
      if(widget.service.duration != null && widget.service.duration != 0){
        middleLeftDisplay = "Duration: ${Tool().formatDuration(widget.service.duration!)}";
      }
      buttonName = "Reschedule";
      feeDisplay = "";
    }else {
      isFeedback(widget.service.serviceId).then((hadFeedback) {
        setState(() {
          if (hadFeedback) {
            buttonDisplay = 1;
          } else {
            buttonName = "Feedback";
          }
        });
      });

    }
  }
}

Future<bool> isFeedback(String serviceId) async { // is feedback already done
  final FeedbackService fs = FeedbackService();
  try {
    final feedback = await fs.getFeedback(widget.service.serviceId);
    if (feedback!.star != null && feedback.star != 0) {
      return true;
    }
  }catch (e) {
    print("Error fetching feedback...: $e");
  }
  return false;
}

Widget buttonRow() {
    if(buttonDisplay == 2){ // pay/reschedule/feedback
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: Size(165, 40),
            ),
            onPressed: () {},
            child: Text(
              buttonName!,
              style: TextStyle(color: AppColor.softWhite),
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
              minimumSize: Size(165, 40),
            ),
            onPressed: () {},
            child: Text(
              "View Details",
              style: TextStyle(color: AppColor.darkCharcoal),
            ),
          ),
        ],
      );
    }else {
      return ElevatedButton(
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
      );
    }
}

@override
Widget build(BuildContext context) {
  return Padding(
    padding: EdgeInsets.only(bottom: 20),
    child:
      Container(
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
          height: 170,
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
                          serviceTitle,
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
                          topRightCornerDisplay?.toUpperCase() ?? "-",
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
                            plateNoDisplay,
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
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            middleLeftDisplay ?? "",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            feeDisplay ?? "",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColor.primaryGreen,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: buttonRow(),
                  )
                ],
              ),
            ],
          ),
      ),
  );
}
}
