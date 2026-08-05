// NexaBank — Auth BLoC
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/auth/auth_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override List<Object?> get props => [];
}
class AuthCheckRequested extends AuthEvent { const AuthCheckRequested(); }
class AuthLoginRequested extends AuthEvent { const AuthLoginRequested(); }
class AuthCallbackReceived extends AuthEvent {
  final String code;
  final String verifier;
  const AuthCallbackReceived({required this.code, required this.verifier});
  @override List<Object?> get props => [code, verifier];
}
class AuthLogoutRequested extends AuthEvent { const AuthLogoutRequested(); }

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override List<Object?> get props => [];
}
class AuthInitial extends AuthState { const AuthInitial(); }
class AuthCheckInProgress extends AuthState { const AuthCheckInProgress(); }
class AuthAuthenticated extends AuthState {
  final String userId;
  const AuthAuthenticated({required this.userId});
  @override List<Object?> get props => [userId];
}
class AuthUnauthenticated extends AuthState { const AuthUnauthenticated(); }
class AuthLoginInProgress extends AuthState { const AuthLoginInProgress(); }
class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _service;

  AuthBloc(this._service) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthLoginRequested>(_onLogin);
    on<AuthCallbackReceived>(_onCallback);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onCheck(AuthCheckRequested _, Emitter<AuthState> emit) async {
    emit(const AuthCheckInProgress());
    final isAuth = await _service.isAuthenticated();
    emit(isAuth
        ? const AuthAuthenticated(userId: 'user_001')
        : const AuthUnauthenticated());
  }

  Future<void> _onLogin(AuthLoginRequested _, Emitter<AuthState> emit) async {
    emit(const AuthLoginInProgress());
    // In real app: launch browser for PKCE flow
    // Simulating successful login:
    await Future.delayed(const Duration(seconds: 1));
    final verifier = _service.generateCodeVerifier();
    // Exchange mock code
    try {
      await _service.exchangeCode(code: 'mock_code', verifier: verifier);
      emit(const AuthAuthenticated(userId: 'user_001'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onCallback(
    AuthCallbackReceived event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _service.exchangeCode(
          code: event.code, verifier: event.verifier);
      emit(const AuthAuthenticated(userId: 'user_001'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested _, Emitter<AuthState> emit) async {
    await _service.logout();
    emit(const AuthUnauthenticated());
  }
}
