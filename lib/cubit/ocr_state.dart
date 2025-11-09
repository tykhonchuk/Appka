part of "ocr_cubit.dart";

sealed class OcrState {
  const OcrState();
}

class OcrInitial extends OcrState {
  const OcrInitial();
}

class OcrLoading extends OcrState {
  const OcrLoading();
}

class OcrSuccess extends OcrState {
  const OcrSuccess({
    required this.text,
    required this.extractedData,
  });

  final String text;
  final Map<String, dynamic> extractedData;
}

class OcrError extends OcrState {
  const OcrError({
    this.error,
    required this.message,
  });

  final Object? error;
  final String message;
}
