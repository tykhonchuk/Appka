import "dart:convert";

import "package:flutter_bloc/flutter_bloc.dart";
import "package:http/http.dart" as http;

part "login_state.dart";

class LoginCubit extends Cubit<LoginState>{
  LoginCubit() : super(const LoginInitial());

  Future<void> loginUser(String login, String password) async{
    emit(const LoginLoading());

    await Future.delayed(const Duration(seconds: 1)); // symulacja ładowania

    if (login == "user" && password == "1234") {
      emit(const LoginSuccess(username: "user", token: "fake_token"));
    } else {
      emit(const LoginError(message: "Nieprawidłowy login lub hasło"));
    }

    // try{
    //   //body żądania
    //   final body = {
    //     "username": login,
    //     "password": password
    //   };
    //   //wyślij żądanie
    //   final response = await http.post(
    //     Uri.parse('https://twojeapi.com/login'),
    //     headers: {'Content-Type': 'application/json'},
    //     body: jsonEncode(body)
    //   );
    //   //sprawdzamy status odpowiedzi
    //   if (response.statusCode == 200){
    //     final data = jsonDecode(response.body);
    //     final token = data['token'];
    //     final username = data['username'];
    //   } else {
    //     emit(LoginError(message: "Nieprawidłowy login lub hasło"));
    //   }
    //
    //
    //
    //
    //
    // } catch (e){
    //   emit(LoginError(error: e, message: "Błąd połaczenia z serwerem"));
    // }
  }

  void emitError(String message){
    emit(LoginError(message: message));
  }
}