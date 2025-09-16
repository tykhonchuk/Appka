import "package:flutter/material.dart";

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

}
