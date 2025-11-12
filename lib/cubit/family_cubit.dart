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

}