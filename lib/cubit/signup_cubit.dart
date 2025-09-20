import "package:flutter_bloc/flutter_bloc.dart";

part "signup_state.dart";

class SignupCubit extends Cubit<SignupState>{
  SignupCubit() : super(const SignupInitial());

  void registerUser(String email, String password, String confirmPassword){
    if (!_isValidEmail(email)){
      emit(const SignupError(message: "Nieprawidłowy adres e-mail"));
      return;
    }
    if (password.length < 8){
      emit(const SignupError(message: "Hasło musi mieć co najmniej 8 znaków"));
      return;
    }
    if (password != confirmPassword){
      emit(const SignupError(message: "Hasła nie są takie same"));
      return;
    }
    emit(const SignupLoading());

    //wysywanie do db
    try{
      // api.register(email, password)
      //   .then((value) => emit(const SignupSuccess()))
    } catch (e) {
      emit(SignupError(error: e, message: "Błąd rejestracji"));
    }
  }

  bool _isValidEmail(String email){
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
  }

}