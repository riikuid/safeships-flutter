import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:safeships_flutter/common/token_repository.dart';
import 'package:safeships_flutter/models/category_model.dart';
import 'package:safeships_flutter/models/category_with_doc_model.dart';
import 'package:safeships_flutter/models/document_model.dart';
import 'package:safeships_flutter/services/document_service.dart';

class DocumentProvider with ChangeNotifier {
  final TokenRepository tokenRepository = TokenRepository();

  List<CategoryWithDocModel> _categoryWithDocs = [];
  List<CategoryWithDocModel> get categoryWithDocs => _categoryWithDocs;

  List<DocumentModel> _documentsManagerial = [];
  List<DocumentModel> get documentsManagerial => _documentsManagerial;

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  final int _limit = 10;
  int _page = 1;
  bool hasMore = true;

  bool serviceLoading = false;

  final DocumentService _documentService = DocumentService();

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

  // Future getDocuments({
  //   void Function(dynamic)? errorCallback,
  // }) async {
  //   try {
  //     List<DocumentModel> result = await _documentService.getDocuments(
  //       token: (await tokenRepository.getToken())!,
  //     );

  //     if (result.length < _limit) {
  //       hasMore = false;
  //     }

  //     for (var item in result) {
  //       _histories.add(item);
  //     }

  //     _page++;
  //     notifyListeners();
  //   } catch (error) {
  //     if (kDebugMode) log(error.toString());
  //     errorCallback?.call(error);
  //   }
  // }

  // Future refreshGetHistory({
  //   required String typeTrx,
  //   required String statusTrx,
  //   required String startDate,
  //   required String endDate,
  // }) async {
  //   _page = 1;
  //   _histories = [];
  //   hasMore = true;
  //   // notifyListeners();

  //   await getHistory(
  //     startDate: startDate,
  //     endDate: endDate,
  //     typeTrx: typeTrx,
  //     statusTrx: statusTrx,
  //   );
  //   serviceLoading = false;
  //   notifyListeners();
  // }
}
