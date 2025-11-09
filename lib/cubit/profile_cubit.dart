import "dart:convert";
import "package:appka/config/config.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

part "profile_state.dart";

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileInitial());

  /// Pobiera zapisany token z pamięci urządzenia
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> changePassword(
      String oldPassword, String newPassword, String confirmNewPassword) async {
    if (newPassword != confirmNewPassword) {
      emit(const ProfileError(message: "Hasła się nie zgadzają!"));
      return;
    }
    if (newPassword.length < 8) {
      emit(const ProfileError(message: "Hasło musi mieć co najmniej 8 znaków!"));
      return;
    }

    emit(const ProfileLoading());

    try {
      final token = await _getToken();
      if (token == null) {
        emit(const ProfileError(message: "Brak tokena – zaloguj się ponownie."));
        return;
      }

      final url = Uri.parse('http://${ApiConfig.baseUrl}/user/changepassword');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        emit(const ProfileSuccess());
      } else {
        final data = jsonDecode(response.body);
        emit(ProfileError(message: data['detail'] ?? "Nie udało się zmienić hasła."));
      }
    } catch (e) {
      emit(ProfileError(message: "Błąd podczas zmiany hasła: $e"));
    }
  }

  Future<void> deleteAccount() async {
    emit(const ProfileLoading());
    try {
      final token = await _getToken();
      if (token == null) {
        emit(const ProfileError(message: "Brak tokena – zaloguj się ponownie."));
        return;
      }

      final url = Uri.parse('http://${ApiConfig.baseUrl}/user/delete-account');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        //delete token from memory
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');

        emit(const ProfileSuccess());
      } else {
        final data = jsonDecode(response.body);
        emit(ProfileError(message: data['detail'] ?? "Nie udało się usunąć konta."));
      }
    } catch (e) {
      emit(ProfileError(message: "Błąd podczas usuwania konta: $e"));
    }
  }

  Future<void> fetchUser() async {
    emit(const ProfileLoading());

    try {
      final token = await _getToken();
      if (token == null) {
        emit(const ProfileError(message: "Brak tokena – zaloguj się ponownie."));
        return;
      }

      final url = Uri.parse('http://${ApiConfig.baseUrl}/user/me');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(ProfileUserLoaded(
          firstName: data['first_name'] ?? "",
          lastName: data['last_name'] ?? "",
          username: data['username'] ?? "",
        ));
      } else {
        final data = jsonDecode(response.body);
        emit(ProfileError(message: data['detail'] ?? "Nie udało się pobrać danych."));
      }
    } catch (e) {
      emit(ProfileError(message: "Błąd podczas pobierania danych: $e"));
    }
  }

}
