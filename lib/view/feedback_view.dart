import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app_assignment/model/service.dart';
import 'package:mobile_app_assignment/services/feedback_service.dart';
import 'package:mobile_app_assignment/widgets/appbar_widget.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_decoration.dart';
import '../provider/navigation_provider.dart';
import '../widgets/app_button_widget.dart';
import 'custom_widgets/ui_helper.dart';
import '../model/feedback.dart' as fb;
import '../widgets/service_item.dart';

// class ServiceItem extends StatelessWidget {
//   const ServiceItem({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(top: 20),
//       child: Container(
//         decoration: AppDecoration.boxDecoration,
//         width: 350,
//         height: 104,
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.only(left: 10, top: 10),
//                       child: Align(
//                         alignment: Alignment.centerLeft,
//                         child: Container(
//                           width: 50,
//                           height: 50,
//                           decoration: BoxDecoration(
//                             color: AppColor.primaryGreen,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Icon(
//                             Icons.add,
//                             color: AppColor.softWhite,
//                             size: 36,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       padding: EdgeInsets.only(left: 10),
//                       width: 100,
//                       child: Text(
//                         "Brake Oil Service",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.only(top: 10, right: 10),
//                       child: Text(
//                         "IN INSPECTION",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.only(top: 5, right: 10),
//                       child: Container(
//                         //color: AppColor.darkCharcoal,
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 5,
//                         ),
//                         decoration: BoxDecoration(
//                           color: AppColor.darkCharcoal,
//                           borderRadius: BorderRadius.circular(4),
//                           border: Border.all(color: Colors.black),
//                         ),
//                         child: Text(
//                           "BFP 1975",
//                           style: TextStyle(
//                             color: AppColor.softWhite,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//
//             Divider(
//               indent: 10, // adjust later
//               endIndent: 10,
//               color: AppColor.slateGray.withAlpha(63),
//               thickness: 1,
//             ),
//
//             Align(
//               alignment: Alignment.centerRight,
//               child: Padding(
//                 padding: const EdgeInsets.only(right: 10),
//                 child: const Text(
//                   "RM 200.00",
//                   textAlign: TextAlign.right,
//                   style: TextStyle(
//                     color: AppColor.accentMint,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class FeedbackForm extends StatefulWidget {
  final int rating;
  final Function(int) onRatingChanged;
  final TextEditingController commentController;

  const FeedbackForm({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    required this.commentController,
  });

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final int _maxRating = 5;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
      decoration: AppDecoration.boxDecoration,
      width: size.width * AppDecoration.maxWidthFactor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "How was your service experience?",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColor.darkCharcoal,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Please rate our service",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: AppColor.slateGray,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_maxRating, (index) {
                return GestureDetector(
                  onTap: () => widget.onRatingChanged(index + 1),
                  child: Icon(
                    index < widget.rating ? Icons.star : Icons.star_border,
                    color: AppColor.accentMint,
                    size: 44,
                  ),
                );
              }),
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Comments (Optional)",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColor.darkCharcoal,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.left,
                  controller:
                      widget.commentController, // Use the passed controller
                  maxLines: 8,
                  minLines: 5,
                  maxLength: 500,
                  buildCounter:
                      (
                        BuildContext context, {
                        required int currentLength,
                        required int? maxLength,
                        required bool isFocused,
                      }) {
                        final bool isAtLimit = currentLength >= maxLength!;
                        final int remainingLength = maxLength - currentLength;
                        return Text(
                          '$remainingLength',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isAtLimit ? Colors.red : AppColor.slateGray,
                            fontWeight: isAtLimit
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        );
                      },
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: AppColor.slateGray,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(
                        color: AppColor.slateGray,
                        width: 1,
                      ),
                    ),
                    hintText: "Tell us more about your experience...",
                    hintStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: AppColor.slateGray,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackView extends StatefulWidget {
  final Service service;
  const FeedbackView({super.key, required this.service});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  final String _title = "Feedback";
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  void _setRating(int newRating) {
    setState(() {
      _rating = newRating;
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      backgroundColor: AppColor.softWhite,
      appBar: AppBarWidget(title: _title, showBackButton: true),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsets.only(top: 4)),
              ServiceItem(service: widget.service, inProgress: null),
              Padding(padding: EdgeInsets.only(top: 20)),
              FeedbackForm(
                rating: _rating,
                onRatingChanged: _setRating,
                commentController: _commentController,
              ),
              Padding(padding: EdgeInsets.only(top: 20)),
              AppButtonWidget(
                text: "Submit",
                onPressed: () async {
                  final currentContext = context;

                  final FeedbackService feedbackService = FeedbackService();
                  final fb.Feedback feedback = fb.Feedback(
                    serviceId: widget.service.serviceId,
                    star: max(_rating, 1),
                    comment: _commentController.text,
                  );

                  await feedbackService.addFeedback(feedback);
                  if (currentContext.mounted) {
                    UiHelper.showSnackBar(
                      currentContext,
                      "Thank you for your feedback!",
                      isError: false,
                    );

                    Navigator.pop(currentContext, true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
