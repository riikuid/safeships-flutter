import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:safeships_flutter/models/notification_model.dart';
import 'package:safeships_flutter/presentation/pages/document/detail_document_page.dart';
import 'package:safeships_flutter/presentation/pages/document/pengajuan_document_page.dart';
import 'package:safeships_flutter/presentation/pages/safety_patrol/detail_safety_patrol_page.dart';
import 'package:safeships_flutter/providers/auth_provider.dart';
import 'package:safeships_flutter/providers/document_provider.dart';
import 'package:safeships_flutter/providers/safety_patrol_provider.dart';

class NotificationHandler {
  // Method untuk menangani tap kartu notifikasi (NotificationModel)
  Future<void> handleCardTap(
    BuildContext context,
    NotificationModel notification,
  ) async {
    final docProvider = Provider.of<DocumentProvider>(context, listen: false);
    final patrolProvider =
        Provider.of<SafetyPatrolProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    bool isLoading = false;
    void setLoading(bool value) {
      isLoading = value;
      // Bisa ditambahkan notify ke UI jika diperlukan
    }

    try {
      setLoading(true);
      await _handleNotification(
        context: context,
        referenceId: notification.referenceId,
        referenceType: notification.referenceType,
        docProvider: docProvider,
        patrolProvider: patrolProvider,
        authProvider: authProvider,
      );
    } catch (e) {
      log('Card tap error: $e');
      Fluttertoast.showToast(msg: 'Error processing notification: $e');
    } finally {
      setLoading(false);
    }
  }

  // Method untuk menangani tap notifikasi perangkat (Map<String, dynamic>)
  Future<void> handleDeviceNotification({
    required BuildContext context,
    required Map<String, dynamic> data,
  }) async {
    final docProvider = Provider.of<DocumentProvider>(context, listen: false);
    final patrolProvider =
        Provider.of<SafetyPatrolProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    bool isLoading = false;
    void setLoading(bool value) {
      isLoading = value;
    }

    try {
      setLoading(true);

      // Parse reference_id
      int referenceId;
      try {
        referenceId = int.parse(data['reference_id'].toString());
      } catch (e) {
        log('Invalid reference_id: ${data['reference_id']}');
        Fluttertoast.showToast(msg: 'Invalid notification data');
        return;
      }

      final referenceType = data['reference_type']?.toString();
      if (referenceType == null) {
        log('Missing reference_type in payload: $data');
        Fluttertoast.showToast(msg: 'Invalid notification data');
        return;
      }

      await _handleNotification(
        context: context,
        referenceId: referenceId,
        referenceType: referenceType,
        docProvider: docProvider,
        patrolProvider: patrolProvider,
        authProvider: authProvider,
      );
    } catch (e) {
      log('Device notification error: $e');
      Fluttertoast.showToast(msg: 'Error processing notification: $e');
    } finally {
      setLoading(false);
    }
  }

  // Logika inti untuk menangani notifikasi
  Future<void> _handleNotification({
    required BuildContext context,
    required int referenceId,
    required String referenceType,
    required DocumentProvider docProvider,
    required SafetyPatrolProvider patrolProvider,
    required AuthProvider authProvider,
  }) async {
    try {
      switch (referenceType) {
        case 'document_view':
          final document = await docProvider.showDocument(
            documentId: referenceId,
            errorCallback: (error) {
              Fluttertoast.showToast(msg: error.toString());
            },
          );
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailDocumentPage(
                  userId: authProvider.user.id,
                  doc: document,
                  viewMode: DocumentViewMode.mySubmissions,
                ),
              ),
            );
          }
          break;

        case 'document_approve':
          final document = await docProvider.showDocument(
            documentId: referenceId,
            errorCallback: (error) {
              Fluttertoast.showToast(msg: error.toString());
            },
          );
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailDocumentPage(
                  doc: document,
                  viewMode: DocumentViewMode.approver,
                  userId: authProvider.user.id,
                ),
              ),
            );
          }
          break;

        case 'document_update_request':
          final document = await docProvider.showDocument(
            documentId: referenceId,
            errorCallback: (error) {
              Fluttertoast.showToast(msg: error.toString());
            },
          );
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PengajuanDocumentPage(
                  categoryId: document.category.id,
                  categoryName: document.category.name,
                  categoryCode: document.category.code,
                ),
              ),
            );
          }
          break;

        case 'safety_induction_view':
          // Kosong untuk saat ini
          Fluttertoast.showToast(msg: 'Safety induction view not implemented');
          break;

        case 'safety_patrol_view':
          final patrol = await patrolProvider.showSafetyPatrol(
            patrolId: referenceId,
            errorCallback: (error) {
              Fluttertoast.showToast(msg: error.toString());
            },
          );
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailSafetyPatrolPage(
                  initialPatrol: patrol,
                  userId: authProvider.user.id,
                  viewMode: SafetyPatrolViewMode.submitter,
                ),
              ),
            );
          }
          break;

        case 'safety_patrol_approve':
          final patrol = await patrolProvider.showSafetyPatrol(
            patrolId: referenceId,
            errorCallback: (error) {
              Fluttertoast.showToast(msg: error.toString());
            },
          );
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailSafetyPatrolPage(
                  initialPatrol: patrol,
                  userId: authProvider.user.id,
                  viewMode: SafetyPatrolViewMode.approver,
                ),
              ),
            );
          }
          break;

        case 'safety_patrol_action':
          final patrol = await patrolProvider.showSafetyPatrol(
            patrolId: referenceId,
            errorCallback: (error) {
              Fluttertoast.showToast(msg: error.toString());
            },
          );
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailSafetyPatrolPage(
                  initialPatrol: patrol,
                  userId: authProvider.user.id,
                  viewMode: SafetyPatrolViewMode.actor,
                ),
              ),
            );
          }
          break;

        default:
          log('Unknown reference type: $referenceType');
          Fluttertoast.showToast(
              msg: 'Unknown notification type: $referenceType');
          break;
      }
    } catch (e) {
      log('Handle notification error: $e');
      rethrow; // Biarkan error ditangani oleh caller
    }
  }
}
