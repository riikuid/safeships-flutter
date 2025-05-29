import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/common/token_repository.dart';
import 'package:safeships_flutter/presentation/widgets/gauge_progress_chart.dart';
import 'package:safeships_flutter/presentation/widgets/safety_patrol_bar_chart.dart';
import 'package:safeships_flutter/providers/auth_provider.dart';
import 'package:safeships_flutter/providers/document_provider.dart';
import 'package:safeships_flutter/providers/safety_patrol_provider.dart';
import 'package:safeships_flutter/services/document_service.dart';
import 'package:safeships_flutter/theme.dart';
import 'package:shimmer/shimmer.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? _selectedYear = 'All'; // Default ke 'All'

  bool _isLoading = false;
  String? _error = 'Terjadi Kesalahan, Ulangi Lagi Setelah Beberapa Waktu';

  Future<bool> _isAndroid9OrBelow() async {
    if (!Platform.isAndroid) return false;
    // Use device_info_plus to get Android version
    // Note: Add device_info_plus to pubspec.yaml
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt <= 28;
    } catch (e) {
      log('Error checking Android version: $e');
      return false; // Assume newer Android if check fails
    }
  }

  Future<bool> downloadAllDocuments() async {
    try {
      _isLoading = true;
      _error = null;
      setState(() {});
      ();

      final token = await TokenRepository().getToken();
      if (token == null) throw 'No token found';

      // Request storage permission (for Android < 13, iOS doesn't need it for downloads)
      if (Platform.isAndroid && await _isAndroid9OrBelow()) {
        if (await Permission.storage.isDenied) {
          final status = await Permission.storage.request();
          if (status.isDenied) {
            if (await Permission.storage.isPermanentlyDenied) {
              // Prompt user to enable permission in settings
              await openAppSettings();
              throw 'Storage permission permanently denied. Please enable it in settings.';
            }
            throw 'Storage permission denied';
          }
        }
      }
      // Call service to download ZIP
      final bytes = await DocumentService().downloadAllDocuments(token: token);

      // Get directory to save the file
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
      }

      if (directory == null) throw 'Unable to access download directory';

      // Create file path with timestamp
      final timestamp =
          DateTime.now().toIso8601String().replaceAll(':', '').split('.').first;
      final filePath = '${directory.path}/documentation-$timestamp.zip';

      // Save file
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      _isLoading = false;
      setState(() {});

      Fluttertoast.showToast(
          msg: 'Documents downloaded successfully to $filePath');
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      setState(() {});
      log('Error downloading all documents: $e');
      Fluttertoast.showToast(msg: 'Error downloading documents: $e');
      return false;
    }
  }

  Future<bool> deleteAllDocuments({
    required BuildContext context,
    required DocumentProvider provider,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      setState(() {});

      final token = await TokenRepository().getToken();
      if (token == null) throw 'No token found';

      // Call service to delete all documents
      await DocumentService().deleteAllDocuments(token: token);
      // Refresh progress data
      await provider.fetchProgress(
        errorCallback: (error) {
          log('Error refreshing progress after delete: $error');
          Fluttertoast.showToast(msg: 'Error refreshing progress: $error');
        },
      );

      _isLoading = false;
      setState(() {});

      Fluttertoast.showToast(msg: 'Semua Dokumentasi Berhasil Dihapus');
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      setState(() {});
      log('Error deleting all documents: $e');
      Fluttertoast.showToast(msg: 'Error menghapus dokumentasi: $e');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    // Tunda pemanggilan fetchProgress hingga setelah build selesai
    Future.microtask(() => _fetchData());
  }

  Future<void> _fetchData() async {
    final authModel = context.read<AuthProvider>().user;
    if (authModel == null) {
      return;
    }

    await context.read<DocumentProvider>().fetchProgress(
      errorCallback: (error) {
        Fluttertoast.showToast(msg: 'Error fetching progress: $error');
      },
    );

    // Ambil data laporan safety patrol dengan tahun dari dropdown
    await _fetchReportData();
  }

  Future<void> _fetchReportData() async {
    int? year;
    if (_selectedYear != 'All') {
      year = int.tryParse(_selectedYear!);
    }

    await context.read<SafetyPatrolProvider>().fetchReportData(
          year: year,
          errorCallback: (error) {
            Fluttertoast.showToast(msg: 'Error fetching report: $error');
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final documentProvider = context.watch<DocumentProvider>();
    final safetyPatrolProvider = context.watch<SafetyPatrolProvider>();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Color(0xffF8F8F8),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(
                    0,
                    20,
                    20,
                    0,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        // margin:
                        //     const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progress Dokumentasi K3',
                              style: primaryTextStyle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 30),
                            if (documentProvider.isProgressLoading)
                              const Center(child: CircularProgressIndicator())
                            else if (documentProvider.progressError != null)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'Error: ${documentProvider.progressError}',
                                  style: primaryTextStyle.copyWith(
                                    color: Colors.red,
                                    fontSize: 10,
                                  ),
                                ),
                              )
                            else if (documentProvider.progressData.isNotEmpty)
                              GaugeProgressChart(
                                progressData: documentProvider.progressData,
                              )
                            else
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'Tidak ada data progres penilaian',
                                  style: primaryTextStyle.copyWith(
                                    color: subtitleTextColor,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        splashRadius: 1,
                        elevation: 2,
                        padding: EdgeInsets.zero,
                        color: whiteColor,
                        icon: Icon(
                          Icons.more_vert,
                          color: subtitleTextColor,
                          size: 18,
                        ),
                        onSelected: (value) {
                          if (value == 'download') {
                            downloadAllDocuments();
                          } else if (value == 'hapus') {
                            deleteAllDocuments(
                              context: context,
                              provider: documentProvider,
                            );
                            // onDeleteCategory(category.id);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'download',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.download,
                                  color: subtitleTextColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Unduh Semua',
                                  style: primaryTextStyle.copyWith(
                                    fontSize: 12,
                                    color: subtitleTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'hapus',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete,
                                  color: Color(0xfff94449),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Hapus Semua',
                                  style: primaryTextStyle.copyWith(
                                    fontSize: 12,
                                    color: Color(0xfff94449),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Bar Chart untuk Laporan Safety Patrol
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Rekap Safety Patrol',
                              style: primaryTextStyle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            height: 40,
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: whiteColor,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 12),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: disabledColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: primaryColor500, width: 2),
                                ),
                              ),
                              value: _selectedYear,
                              items: [
                                'All',
                                ...List.generate(2040 - 2020 + 1,
                                    (index) => (2020 + index).toString())
                              ].map((year) {
                                return DropdownMenuItem<String>(
                                  value: year,
                                  child: Text(
                                    year,
                                    style:
                                        primaryTextStyle.copyWith(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedYear = value;
                                  // Panggil fetchReportData dengan tahun yang dipilih
                                  _fetchReportData();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (safetyPatrolProvider.isReportLoading)
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                            ),
                            height: 200,
                            margin: const EdgeInsets.only(bottom: 10),
                          ),
                        )
                      else if (safetyPatrolProvider.reportError != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Error: ${safetyPatrolProvider.reportError}',
                            style: primaryTextStyle.copyWith(color: Colors.red),
                          ),
                        )
                      else if (safetyPatrolProvider
                          .reportData['labels'].isNotEmpty)
                        SafetyPatrolBarChart(
                          reportData: safetyPatrolProvider.reportData,
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: Text(
                            '-',
                            style: primaryTextStyle,
                          ),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegend(
                              'Unsafe Condition', const Color(0xffFF6384)),
                          const SizedBox(width: 20),
                          _buildLegend(
                              'Unsafe Action', const Color(0xff36A2EB)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
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
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: primaryTextStyle.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}
