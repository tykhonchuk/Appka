part of "ocr_cubit.dart";

sealed class OcrState{
  const OcrState();
}

class OcrInitial extends OcrState{
  const OcrInitial();
}

class OcrLoading extends OcrState{
  const OcrLoading();
}

class OcrSuccess extends OcrState{
  const OcrSuccess();
}

class OcrError extends OcrState{
  const OcrError({this.error, this.message});

  final Object? error;
  final String? message;
}