import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:safeships_flutter/models/notification_model.dart';
import 'package:safeships_flutter/providers/document_provider.dart';
import 'package:safeships_flutter/providers/safety_patrol_provider.dart';
import 'package:safeships_flutter/providers/auth_provider.dart';
import 'package:safeships_flutter/presentation/pages/document/detail_document_page.dart';
import 'package:safeships_flutter/presentation/pages/document/pengajuan_document_page.dart';
import 'package:safeships_flutter/presentation/pages/safety_patrol/detail_safety_patrol_page.dart';

class NotificationHandler {
  static Future<void> handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) async {
    final docProvider = Provider.of<DocumentProvider>(context, listen: false);
    final patrolProvider =
        Provider.of<SafetyPatrolProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Loading state (opsional, jika ingin indikator loading)
    bool isLoading = false;
    void setLoading(bool value) {
      isLoading = value;
      // Notify UI if needed (misalnya, via setState di caller)
    }

    try {
      setLoading(true);

      switch (notification.referenceType) {
        case 'document_view':
          final document = await docProvider.showDocument(
            documentId: notification.referenceId,
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
            documentId: notification.referenceId,
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
            documentId: notification.referenceId,
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
          break;

        case 'safety_patrol_view':
          final patrol = await patrolProvider.showSafetyPatrol(
            patrolId: notification.referenceId,
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
            patrolId: notification.referenceId,
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
            patrolId: notification.referenceId,
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
          Fluttertoast.showToast(
              msg: 'Unknown notification type: ${notification.referenceType}');
          break;
      }
    } catch (e) {
      // Error sudah ditangani oleh errorCallback, tapi log untuk debugging
      if (kDebugMode) {
        debugPrint('Notification tap error: $e');
      }
    } finally {
      setLoading(false);
    }
  }
}
