import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/common/app_helper.dart';
import 'package:safeships_flutter/models/safety_induction/location_model.dart';
import 'package:safeships_flutter/presentation/pages/safety_induction/safety_induction_form_page.dart';
import 'package:safeships_flutter/presentation/widgets/primary_button.dart';
import 'package:safeships_flutter/providers/safety_induction_provider.dart';
import 'package:safeships_flutter/theme.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class SafetyInductionLocationsPage extends StatefulWidget {
  const SafetyInductionLocationsPage({super.key});

  @override
  State<SafetyInductionLocationsPage> createState() =>
      _SafetyInductionLocationsPageState();
}

class _SafetyInductionLocationsPageState
    extends State<SafetyInductionLocationsPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLocations();
    });
  }

  Future<void> _fetchLocations() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await context.read<SafetyInductionProvider>().getLocations(
        errorCallback: (error) {
          Fluttertoast.showToast(msg: 'Gagal memuat lokasi: $error');
        },
      );
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _launchYouTube(String url) async {
    setState(() {
      _isLoading = true;
    });
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      setState(() {
        _isLoading = false;
      });
    } else {
      Fluttertoast.showToast(msg: 'Gagal membuka link YouTube');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xffF8F8F8),
          appBar: AppBar(
            iconTheme: IconThemeData(color: whiteColor),
            surfaceTintColor: transparentColor,
            backgroundColor: primaryColor500,
            title: Text(
              'Video Safety Induction',
              style: primaryTextStyle.copyWith(
                fontSize: 18,
                fontWeight: semibold,
                color: whiteColor,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: whiteColor),
                onPressed: _fetchLocations,
              ),
            ],
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
              color: primaryColor500,
              borderColor: primaryColor500,
              elevation: 0,
              child: Text(
                'Lanjutkan ke Formulir',
                style: primaryTextStyle.copyWith(
                  color: whiteColor,
                  fontWeight: semibold,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SafetyInductionFormPage(),
                  ),
                );
              },
            ),
          ),
          body: Consumer<SafetyInductionProvider>(
            builder: (context, provider, child) {
              if (_isLoading) {
                return GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 16 / 9,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                );
              } else if (provider.locations.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Tidak ada video induksi tersedia saat ini',
                      style: primaryTextStyle.copyWith(
                        color: subtitleTextColor,
                        fontSize: 14,
                        fontWeight: regular,
                      ),
                    ),
                  ),
                );
              } else {
                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  //   crossAxisCount: 1,
                  //   crossAxisSpacing: 15,
                  //   mainAxisSpacing: 15,
                  //   childAspectRatio: 16 / 9,
                  // ),
                  itemCount: provider.locations.length,
                  itemBuilder: (context, index) {
                    final location = provider.locations[index];
                    return GestureDetector(
                      onTap: () {
                        _launchYouTube(location.youtubeUrl);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x19000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                children: [
                                  Image.network(
                                    location.thumbnailUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                  Center(
                                    child: Icon(
                                      Icons.play_circle_fill,
                                      color: whiteColor.withOpacity(0.8),
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            location.name,
                            style: primaryTextStyle.copyWith(
                              color: blackColor,
                              fontSize: 14,
                              fontWeight: semibold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
        if (_isLoading)
          ColoredBox(
            color: blackColor.withOpacity(0.4),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
