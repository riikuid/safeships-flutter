import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:safeships_flutter/common/token_repository.dart';
import 'package:safeships_flutter/models/safety_induction/certificate_model.dart';
import 'package:safeships_flutter/models/safety_induction/location_model.dart';
import 'package:safeships_flutter/models/safety_induction/question_model.dart';
import 'package:safeships_flutter/models/safety_induction/question_package_model.dart';
import 'package:safeships_flutter/models/safety_induction/safety_induction_attempt_model.dart';
import 'package:safeships_flutter/models/safety_induction/safety_induction_model.dart';
import 'package:safeships_flutter/services/safety_induction_service.dart';

class SafetyInductionProvider with ChangeNotifier {
  final TokenRepository tokenRepository = TokenRepository();
  final SafetyInductionService _service = SafetyInductionService();

  List<LocationModel> _locations = [];
  List<LocationModel> get locations => _locations;

  List<SafetyInductionModel> _mySubmissions = [];
  List<SafetyInductionModel> get mySubmissions => _mySubmissions;

  SafetyInductionModel? _currentInduction;
  SafetyInductionModel? get currentInduction => _currentInduction;

  QuestionPackageModel? _currentPackage;
  QuestionPackageModel? get currentPackage => _currentPackage;

  List<QuestionModel> _currentQuestions = [];
  List<QuestionModel> get currentQuestions => _currentQuestions;

  SafetyInductionAttemptModel? _latestAttempt;
  SafetyInductionAttemptModel? get latestAttempt => _latestAttempt;

  CertificateModel? _certificate;
  CertificateModel? get certificate => _certificate;

  // bool _isLoading = false;
  // bool get isLoading => _isLoading;

  // String? _error;
  // String? get error => _error;

  SafetyInductionModel? _pendingSubmission;
  SafetyInductionModel? get pendingSubmission => _pendingSubmission;

  List<String> _pendingOptions = [];
  List<String> get pendingOptions => _pendingOptions;

  Future<void> getLocations({void Function(dynamic)? errorCallback}) async {
    try {
      // _isLoading = true;
      // _error = null;
      // notifyListeners();

      final token = await tokenRepository.getToken();
      if (token == null) throw 'No token found';

      _locations = await _service.getLocations(token: token);

      // _isLoading = false;
      notifyListeners();
    } catch (e) {
      // _isLoading = false;
      // _error = e.toString();
      if (kDebugMode) log('getLocations error: $e');
      errorCallback?.call(e);
      notifyListeners();
    }
  }

  Future<SafetyInductionModel> createSafetyInduction({
    required String name,
    required String type,
    String? address,
    String? phoneNumber,
    String? email,
    bool forceCreate = false,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      // _isLoading = true;
      // _error = null;
      _pendingSubmission = null;
      _pendingOptions = [];
      notifyListeners();

      final token = await tokenRepository.getToken();
      if (token == null) throw 'No token found';

      SafetyInductionModel induction = await _service.createSafetyInduction(
        token: token,
        name: name,
        type: type,
        address: address,
        phoneNumber: phoneNumber,
        email: email,
        forceCreate: forceCreate,
      );

      _currentInduction = induction;
      await getMySubmissions(errorCallback: errorCallback);

      // _isLoading = false;
      notifyListeners();
      return induction;
    } catch (e) {
      // _isLoading = false;
      if (e is PendingSubmissionException) {
        _pendingSubmission = e.pendingSubmission;
        _pendingOptions = e.options;
        // _error = e.message;
      } else {
        // _error = e.toString();
      }
      if (kDebugMode) log('createSafetyInduction error: $e');
      errorCallback?.call(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> continuePendingSubmission(
      {void Function(dynamic)? errorCallback}) async {
    if (_pendingSubmission == null) return;
    try {
      // _isLoading = true;
      // _error = null;
      // notifyListeners();

      await getQuestions(
        inductionId: _pendingSubmission!.id,
        errorCallback: errorCallback,
      );

      _currentInduction = _pendingSubmission;
      _pendingSubmission = null;
      _pendingOptions = [];

      // _isLoading = false;
      notifyListeners();
    } catch (e) {
      // _isLoading = false;
      // _error = e.toString();
      if (kDebugMode) log('continuePendingSubmission error: $e');
      errorCallback?.call(e);
      notifyListeners();
    }
  }

  Future<void> getQuestions({
    required int inductionId,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      // _isLoading = true;
      // _error = null;
      // notifyListeners();

      final token = await tokenRepository.getToken();
      if (token == null) throw 'No token found';

      final result =
          await _service.getQuestions(token: token, inductionId: inductionId);
      _currentPackage = result['package'] as QuestionPackageModel;
      _currentQuestions = result['questions'] as List<QuestionModel>;

      // _isLoading = false;
      notifyListeners();
    } catch (e) {
      // _isLoading = false;
      // _error = e.toString();
      if (kDebugMode) log('getQuestions error: $e');
      errorCallback?.call(e);
      notifyListeners();
    }
  }

  Future<void> submitAnswers({
    required int inductionId,
    required int questionPackageId,
    required List<Map<String, dynamic>> answers,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      // _isLoading = true;
      // _error = null;
      // notifyListeners();

      final token = await tokenRepository.getToken();
      if (token == null) throw 'No token found';

      final result = await _service.submitAnswers(
        token: token,
        inductionId: inductionId,
        questionPackageId: questionPackageId,
        answers: answers,
      );

      _latestAttempt = result['attempt'] as SafetyInductionAttemptModel;
      _certificate = result['certificate'] as CertificateModel?;
      if (_currentInduction?.id == inductionId) {
        _currentInduction = SafetyInductionModel(
          id: _currentInduction!.id,
          userId: _currentInduction!.userId,
          name: _currentInduction!.name,
          type: _currentInduction!.type,
          address: _currentInduction!.address,
          phoneNumber: _currentInduction!.phoneNumber,
          email: _currentInduction!.email,
          status: _latestAttempt!.passed ? 'completed' : 'pending',
          createdAt: _currentInduction!.createdAt,
          updatedAt: DateTime.now(),
          attempts: [...?_currentInduction!.attempts, _latestAttempt!],
          certificate: _certificate,
        );
      }

      await getMySubmissions(errorCallback: errorCallback);

      // _isLoading = false;
      notifyListeners();
    } catch (e) {
      // _isLoading = false;
      // _error = e.toString();
      if (kDebugMode) log('submitAnswers error: $e');
      errorCallback?.call(e);
      notifyListeners();
    }
  }

  Future<void> getResult({
    required int inductionId,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      // _isLoading = true;
      // _error = null;
      // notifyListeners();

      final token = await tokenRepository.getToken();
      if (token == null) throw 'No token found';

      final result =
          await _service.getResult(token: token, inductionId: inductionId);
      if (_currentInduction?.id == inductionId) {
        _currentInduction = result['induction'] as SafetyInductionModel;
        _latestAttempt =
            (result['attempts'] as List<SafetyInductionAttemptModel>)
                .lastOrNull;
        _certificate = result['certificate'] as CertificateModel?;
      }

      // _isLoading = false;
      notifyListeners();
    } catch (e) {
      // _isLoading = false;
      // _error = e.toString();
      if (kDebugMode) log('getResult error: $e');
      errorCallback?.call(e);
      notifyListeners();
    }
  }

  Future<void> getCertificate({
    required int inductionId,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      // _isLoading = true;
      // _error = null;
      // notifyListeners();

      final token = await tokenRepository.getToken();
      if (token == null) throw 'No token found';

      _certificate =
          await _service.getCertificate(token: token, inductionId: inductionId);
      if (_currentInduction?.id == inductionId) {
        _currentInduction = SafetyInductionModel(
          id: _currentInduction!.id,
          userId: _currentInduction!.userId,
          name: _currentInduction!.name,
          type: _currentInduction!.type,
          address: _currentInduction!.address,
          phoneNumber: _currentInduction!.phoneNumber,
          email: _currentInduction!.email,
          status: _currentInduction!.status,
          createdAt: _currentInduction!.createdAt,
          updatedAt: _currentInduction!.updatedAt,
          attempts: _currentInduction!.attempts,
          certificate: _certificate,
        );
      }

      // _isLoading = false;
      notifyListeners();
    } catch (e) {
      // _isLoading = false;
      // _error = e.toString();
      if (kDebugMode) log('getCertificate error: $e');
      errorCallback?.call(e);
      notifyListeners();
    }
  }

  Future<void> getMySubmissions({void Function(dynamic)? errorCallback}) async {
    try {
      // _isLoading = true;
      // _error = null;
      // notifyListeners();

      final token = await tokenRepository.getToken();
      if (token == null) throw 'No token found';

      _mySubmissions = await _service.getMySubmissions(token: token);

      // _isLoading = false;
      notifyListeners();
    } catch (e) {
      // _isLoading = false;
      // _error = e.toString();
      if (kDebugMode) log('getMySubmissions error: $e');
      errorCallback?.call(e);
      notifyListeners();
    }
  }

  Future<void> markAsFailed({
    required int inductionId,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      // _isLoading = true;
      // _error = null;
      // notifyListeners();

      final token = await tokenRepository.getToken();
      if (token == null) throw 'No token found';

      await _service.markAsFailed(token: token, inductionId: inductionId);

      if (_currentInduction?.id == inductionId) {
        _currentInduction = SafetyInductionModel(
          id: _currentInduction!.id,
          userId: _currentInduction!.userId,
          name: _currentInduction!.name,
          type: _currentInduction!.type,
          address: _currentInduction!.address,
          phoneNumber: _currentInduction!.phoneNumber,
          email: _currentInduction!.email,
          status: 'failed',
          createdAt: _currentInduction!.createdAt,
          updatedAt: DateTime.now(),
          attempts: _currentInduction!.attempts,
          certificate: _currentInduction!.certificate,
        );
      }

      await getMySubmissions(errorCallback: errorCallback);

      // _isLoading = false;
      notifyListeners();
    } catch (e) {
      // _isLoading = false;
      // _error = e.toString();
      if (kDebugMode) log('markAsFailed error: $e');
      errorCallback?.call(e);
      notifyListeners();
      rethrow;
    }
  }

  void resetCurrentInduction() {
    _currentInduction = null;
    _currentPackage = null;
    _currentQuestions = [];
    _latestAttempt = null;
    _certificate = null;
    // _error = null;
    _pendingSubmission = null;
    _pendingOptions = [];
    notifyListeners();
  }
}
