import 'package:flutter_bloc/flutter_bloc.dart';

part "document_state.dart";

class DocumentCubit extends Cubit<DocumentState>{
  DocumentCubit() : super(const DocumentInitial());

}