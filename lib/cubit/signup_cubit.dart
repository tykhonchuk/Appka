import "dart:convert";

import "package:flutter_bloc/flutter_bloc.dart";
import "package:http/http.dart" as http;

part "signup_state.dart";

class SignupCubit extends Cubit<SignupState>{
  SignupCubit() : super(const SignupInitial());

  void registerUser(String email, String password, String confirmPassword, String firstName, String lastName) async{
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
    //tester123
    try{
      final url = Uri.parse('http://10.0.2.2:8000/user/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName
        }),
      );
      if (response.statusCode == 200) {
        emit(const SignupSuccess());
      } else {
        final error = jsonDecode(response.body)["detail"] ?? "Nieznany błąd";
        emit(SignupError(message: error));
      }
    } catch (e) {
      emit(SignupError(error: e, message: "Błąd rejestracji"));
    }
  }

  bool _isValidEmail(String email){
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
  }

}