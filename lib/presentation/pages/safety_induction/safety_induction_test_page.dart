import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/presentation/pages/safety_induction/safety_induction_result_page.dart';
import 'package:safeships_flutter/presentation/widgets/primary_button.dart';
import 'package:safeships_flutter/providers/safety_induction_provider.dart';
import 'package:safeships_flutter/theme.dart';

class SafetyInductionTestPage extends StatefulWidget {
  final int inductionId;

  const SafetyInductionTestPage({super.key, required this.inductionId});

  @override
  State<SafetyInductionTestPage> createState() =>
      _SafetyInductionTestPageState();
}

class _SafetyInductionTestPageState extends State<SafetyInductionTestPage> {
  Map<int, String> _selectedAnswers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoading = true;
    });
    final provider = context.read<SafetyInductionProvider>();
    await provider.getQuestions(
      inductionId: widget.inductionId,
      errorCallback: (error) {
        Fluttertoast.showToast(msg: error.toString());
        Navigator.pop(context);
      },
    );
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isLoading = true;
    });

    final provider = context.read<SafetyInductionProvider>();
    if (_selectedAnswers.length != provider.currentQuestions.length) {
      Fluttertoast.showToast(msg: 'Harap jawab semua soal!');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      await provider.submitAnswers(
        inductionId: widget.inductionId,
        questionPackageId: provider.currentPackage!.id,
        answers: _selectedAnswers.entries
            .map((e) => {'question_id': e.key, 'selected_answer': e.value})
            .toList(),
        errorCallback: (error) {
          Fluttertoast.showToast(msg: error.toString());
        },
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SafetyInductionResultPage(
              inductionId: widget.inductionId,
              isAfterTest: true,
            ),
          ),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SafetyInductionProvider>(
      builder: (context, provider, child) {
        if (provider.currentQuestions.isEmpty) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Stack(
          children: [
            Scaffold(
              backgroundColor: greyBackgroundColor,
              appBar: AppBar(
                iconTheme: IconThemeData(color: whiteColor),
                surfaceTintColor: transparentColor,
                backgroundColor: primaryColor500,
                title: Text(
                  'Tes Safety Induction',
                  style: primaryTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: semibold,
                    color: whiteColor,
                  ),
                ),
              ),
              bottomNavigationBar: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: whiteColor,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 24,
                      offset: Offset(0, 11),
                    ),
                  ],
                ),
                child: PrimaryButton(
                  isLoading: _isLoading,
                  color: primaryColor500,
                  borderColor: primaryColor500,
                  elevation: 0,
                  child: Text(
                    'Submit',
                    style: primaryTextStyle.copyWith(
                      color: whiteColor,
                      fontWeight: semibold,
                    ),
                  ),
                  onPressed: _handleSubmit,
                ),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        provider.currentQuestions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final question = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Soal ${index + 1}',
                              style: primaryTextStyle.copyWith(
                                fontSize: 16,
                                fontWeight: semibold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              question.text,
                              style: primaryTextStyle.copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 10),
                            ...question.options.entries.map((option) {
                              return RadioListTile<String>(
                                title: Text(
                                  option.value,
                                  style:
                                      primaryTextStyle.copyWith(fontSize: 14),
                                ),
                                value: option.key,
                                groupValue: _selectedAnswers[question.id],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedAnswers[question.id] = value!;
                                  });
                                },
                              );
                            }),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              ColoredBox(
                color: blackColor.withOpacity(0.4),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }
}
