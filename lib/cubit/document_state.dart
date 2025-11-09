part of "document_cubit.dart";


sealed class DocumentState{
  const DocumentState();
}

class DocumentInitial extends DocumentState{
  const DocumentInitial();
}

class DocumentLoading extends DocumentState{
  const DocumentLoading();
}

class DocumentSuccess extends DocumentState{
  const DocumentSuccess();
}

class DocumentError extends DocumentState{
  const DocumentError({this.error, this.message});

  final Object? error;
  final String? message;
}