import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appka/config/config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

part 'family_state.dart';

class FamilyCubit extends Cubit<FamilyState> {
  FamilyCubit() : super(const FamilyInitial());

  Future<void> fetchFamilyMembers() async {
    emit(const FamilyLoading());
    try{
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final uri = Uri.parse('http://${ApiConfig.baseUrl}/family/family-members');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        emit(FamilyLoaded(members: data.cast<Map<String, dynamic>>()));
      } else {
        emit(FamilyError(
          error: Exception('HTTP ${response.statusCode}'),
          message: 'Błąd pobierania członków rodziny',
        ));
      }
    } catch (e){
      emit(FamilyError(error: e, message: "Błąd pobierania członków rodziny"));
    }
  }

  Future<void> addMember(String firstName, String lastName) async {
    emit(const FamilyLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final uri = Uri.parse('http://${ApiConfig.baseUrl}/family/add-member');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // po dodaniu od razu pobieramy zaktualizowaną listę
        await fetchFamilyMembers();
        emit(const FamilyAddSuccess());
      } else {
        final body = response.body.isNotEmpty ? response.body : '';
        emit(FamilyError(
          error: Exception('HTTP ${response.statusCode} $body'),
          message: 'Nie udało się dodać podopiecznego',
        ));
      }
    } catch (e) {
      emit(FamilyError(
        error: e,
        message: 'Nie udało się dodać podopiecznego',
      ));
    }
  }

  Future<void> editMember(int id, String firstName, String lastName) async {
    emit(const FamilyLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final uri = Uri.parse('http://${ApiConfig.baseUrl}/family/edit-member/$id');

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
        }),
      );

      if (response.statusCode == 200) {
        await fetchFamilyMembers();
        emit(const FamilyEditSuccess());
      } else {
        emit(FamilyError(
          message: "Nie udało się zaktualizować danych",
          error: Exception(response.body),
        ));
      }
    } catch (e) {
      emit(FamilyError(message: "Błąd podczas edycji", error: e));
    }
  }


  Future<void> deleteMember(int memberId) async {
    emit(const FamilyLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');


      final uri = Uri.parse(
        'http://${ApiConfig.baseUrl}/family/delete-member/$memberId',
      );

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        await fetchFamilyMembers();
        //emit(const FamilyDeleteSuccess());
      } else {
        final body = response.body.isNotEmpty ? response.body : '';
        emit(FamilyError(
          error: Exception('HTTP ${response.statusCode} $body'),
          message: 'Nie udało się usunąć podopiecznego',
        ));
      }
    } catch (e) {
      emit(FamilyError(
        error: e,
        message: 'Nie udało się usunąć podopiecznego',
      ));
    }
  }


}