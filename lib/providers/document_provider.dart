import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:safeships_flutter/common/token_repository.dart';
import 'package:safeships_flutter/models/category_model.dart';
import 'package:safeships_flutter/models/category_with_doc_model.dart';
import 'package:safeships_flutter/models/document_model.dart';
import 'package:safeships_flutter/models/manager_model.dart';
import 'package:safeships_flutter/services/document_service.dart';

class DocumentProvider with ChangeNotifier {
  final TokenRepository tokenRepository = TokenRepository();

  List<CategoryWithDocModel> _categoryWithDocs = [];
  List<CategoryWithDocModel> get categoryWithDocs => _categoryWithDocs;

  List<DocumentModel> _documentsManagerial = [];
  List<DocumentModel> get documentsManagerial => _documentsManagerial;

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  List<ManagerModel> _managers = [];
  List<ManagerModel> get managers => _managers;

  List<DocumentModel> _mySubmissions = [];
  List<DocumentModel> get mySubmissions => _mySubmissions;

  final DocumentService _documentService = DocumentService();

  List<Map<String, dynamic>> _progressData = [];
  List<Map<String, dynamic>> get progressData => _progressData;

  bool _isProgressLoading = false;
  bool get isProgressLoading => _isProgressLoading;

  String? _progressError;
  String? get progressError => _progressError;

  Future getCategories({
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      List<CategoryModel> result = await _documentService.getCategories(
        token: (await tokenRepository.getToken())!,
      );

      _categories = result;

      notifyListeners();
    } catch (error) {
      if (kDebugMode) log(error.toString());
      errorCallback?.call(error);
      log('error get categories: $error');
    }
  }

  Future getCategoriesWithDocs({
    required int categoryId,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      List<CategoryWithDocModel> result =
          await _documentService.getCategoriesWithDocs(
        categoryId: categoryId,
        token: (await tokenRepository.getToken())!,
      );

      _categoryWithDocs = result;

      notifyListeners();
    } catch (error) {
      if (kDebugMode) log(error.toString());
      errorCallback?.call(error);
    }
  }

  void resetCategoryWithDocs() {
    _categoryWithDocs = [];
    notifyListeners();
  }

  Future getDocumentManagerial({
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      List<DocumentModel> result =
          await _documentService.getDocumentsManagerial(
        token: (await tokenRepository.getToken())!,
      );

      _documentsManagerial = result;

      notifyListeners();
    } catch (error) {
      if (kDebugMode) log(error.toString());
      errorCallback?.call(error);
    }
  }

  Future<DocumentModel> showDocument({
    required int documentId,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      DocumentModel result = await _documentService.showDocument(
        documentId: documentId,
        token: (await tokenRepository.getToken())!,
      );

      // Tambahkan atau perbarui dokumen di _documentsManagerial
      final existingIndex =
          _documentsManagerial.indexWhere((doc) => doc.id == result.id);
      if (existingIndex != -1) {
        _documentsManagerial[existingIndex] = result;
      } else {
        _documentsManagerial.add(result);
      }

      // Tambahkan atau perbarui dokumen di _mySubmissions jika milik pengguna
      final existingSubmissionIndex =
          _mySubmissions.indexWhere((doc) => doc.id == result.id);
      if (existingSubmissionIndex != -1) {
        _mySubmissions[existingSubmissionIndex] = result;
      }

      if (kDebugMode) {
        log('showDocument: ID=${result.id}, Status=${result.status}');
      }

      notifyListeners();
      return result;
    } catch (error) {
      if (kDebugMode) log('showDocument error: $error');
      errorCallback?.call(error);
      rethrow;
    }
  }

  Future<bool> ajukanDokumentasiBaru({
    required String categoryId,
    required String managerId,
    required String title,
    required String description,
    required String pathFile,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      log('masuk');
      bool result = await _documentService.ajukanDokumentasiBaru(
        token: (await tokenRepository.getToken())!,
        categoryId: categoryId,
        managerId: managerId,
        title: title,
        description: description,
        pathFile: pathFile,
      );

      // Refresh mySubmissions setelah pengajuan baru
      await getMySubmissions(errorCallback: (e) => errorCallback?.call(e));

      notifyListeners();

      return result;
    } on SocketException {
      errorCallback?.call("Terjadi Kesalahan Koneksi");
      return false;
    } catch (e) {
      errorCallback?.call(e);
      return false;
    }
  }

  Future<bool> approveDocument({
    required int documentId,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      DocumentModel result = await _documentService.approveDocument(
        token: (await tokenRepository.getToken())!,
        documentId: documentId,
      );

      // Perbarui _documentsManagerial
      final index =
          _documentsManagerial.indexWhere((doc) => doc.id == result.id);
      if (index != -1) {
        _documentsManagerial[index] = result;
      } else {
        _documentsManagerial.add(result);
      }

      // Perbarui _mySubmissions jika dokumen ada di sana
      final submissionIndex =
          _mySubmissions.indexWhere((doc) => doc.id == result.id);
      if (submissionIndex != -1) {
        _mySubmissions[submissionIndex] = result;
      }

      if (kDebugMode) {
        log('approveDocument: ID=$documentId, Status=${result.status}');
      }

      notifyListeners();
      return true;
    } catch (error) {
      if (kDebugMode) log('approveDocument error: $error');
      errorCallback?.call(error);
      return false;
    }
  }

  Future<bool> rejectDocument({
    required int documentId,
    required String comments,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      DocumentModel result = await _documentService.rejectDocument(
        comments: comments,
        token: (await tokenRepository.getToken())!,
        documentId: documentId,
      );

      // Perbarui _documentsManagerial
      final index =
          _documentsManagerial.indexWhere((doc) => doc.id == result.id);
      if (index != -1) {
        _documentsManagerial[index] = result;
      } else {
        _documentsManagerial.add(result);
      }

      // Perbarui _mySubmissions jika dokumen ada di sana
      final submissionIndex =
          _mySubmissions.indexWhere((doc) => doc.id == result.id);
      if (submissionIndex != -1) {
        _mySubmissions[submissionIndex] = result;
      }

      if (kDebugMode) {
        log('rejectDocument: ID=$documentId, Status=${result.status}');
      }

      notifyListeners();
      return true;
    } catch (error) {
      if (kDebugMode) log('rejectDocument error: $error');
      errorCallback?.call(error);
      return false;
    }
  }

  Future<void> getManagers({
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      List<ManagerModel> result = await _documentService.getManagers(
        token: (await tokenRepository.getToken())!,
      );

      _managers = result;
      notifyListeners();
    } catch (error) {
      if (kDebugMode) log('Error fetching users: $error');
      errorCallback?.call(error);
    }
  }

  Future<void> getMySubmissions({
    required Function(String) errorCallback,
  }) async {
    try {
      final token = await tokenRepository.getToken();
      if (token == null) throw 'No token found';
      _mySubmissions = await _documentService.getMySubmissions(
        token: token,
      );
      if (kDebugMode) {
        log('getMySubmissions: ${_mySubmissions.map((doc) => 'ID=${doc.id}, Status=${doc.status}').toList()}');
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) log('getMySubmissions error: $e');
      errorCallback(e.toString());
    }
  }

  void resetManager() {
    _managers = [];
    notifyListeners();
  }

  Future<bool> deleteDocument({
    required int documentId,
    required int categoryId,
    VoidCallback? onSuccess,
    void Function(dynamic)? onError,
  }) async {
    try {
      await _documentService.deleteDocument(
        documentId: documentId,
        token: (await tokenRepository.getToken())!,
      );

      // Update state: hapus dokumen dari kategori
      _categoryWithDocs = _categoryWithDocs.map((category) {
        if (category.id == categoryId) {
          return CategoryWithDocModel(
            id: category.id,
            name: category.name,
            code: category.code,
            items: category.items.where((doc) => doc.id != documentId).toList(),
          );
        }
        return category;
      }).toList();

      // Update mySubmissions
      _mySubmissions =
          _mySubmissions.where((doc) => doc.id != documentId).toList();

      // Update documentsManagerial
      _documentsManagerial =
          _documentsManagerial.where((doc) => doc.id != documentId).toList();

      onSuccess?.call();
      notifyListeners();
      return true;
    } on SocketException {
      onError?.call('Terjadi Kesalahan Koneksi');
      return false;
    } catch (e) {
      onError?.call(e);
      return false;
    }
  }

  Future<bool> deleteDocumentsByCategory({
    required int categoryId,
    VoidCallback? onSuccess,
    void Function(dynamic)? onError,
  }) async {
    try {
      await _documentService.deleteDocumentsByCategory(
        categoryId: categoryId,
        token: (await tokenRepository.getToken())!,
      );

      // Update state: hapus kategori dari daftar
      _categoryWithDocs = _categoryWithDocs
          .where((category) => category.id != categoryId)
          .toList();

      // Update mySubmissions
      _mySubmissions =
          _mySubmissions.where((doc) => doc.categoryId != categoryId).toList();

      // Update documentsManagerial
      _documentsManagerial = _documentsManagerial
          .where((doc) => doc.categoryId != categoryId)
          .toList();

      onSuccess?.call();
      notifyListeners();
      return true;
    } on SocketException {
      onError?.call('Terjadi Kesalahan Koneksi');
      return false;
    } catch (e) {
      onError?.call(e);
      return false;
    }
  }

  Future<void> fetchProgress({
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      _isProgressLoading = true;
      _progressError = null;
      notifyListeners();

      _progressData = await _documentService.fetchAssessmentProgress(
        token: (await tokenRepository.getToken())!,
      );

      _isProgressLoading = false;
      notifyListeners();
    } catch (e) {
      _isProgressLoading = false;
      _progressError = e.toString();
      notifyListeners();
      if (kDebugMode) log('Error fetching progress: $e');
      errorCallback?.call(e.toString());
    }
  }
}
