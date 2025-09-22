import "package:flutter_bloc/flutter_bloc.dart";

part "profile_state.dart";

class ProfileCubit extends Cubit<ProfileState>{
  ProfileCubit() : super(const ProfileInitial());

  Future<void> changePassword(String oldPassword, String newPassword, String confirmNewPassword) async {
    if (newPassword != confirmNewPassword){
      emit(ProfileError(message: "Hasło się nie zgadzają!"));
      return;
    }
    if (newPassword.length < 8){
      emit(ProfileError(message: "Hasło musi mieć co najmniej 8 znaków!"));
      return;
    }
    emit(const ProfileLoading());
    try{
      //await api.changePassword(oldPassword, newPassword);
      emit(const ProfileSuccess());
    }catch (e) {
      emit(ProfileError(message: "Nie udało się zmienić hasła: $e"));
    }
    
    

  }

}
