
import 'package:flutter_mobile/validation/validation_messages.dart';

class BaseValidator {
  BaseValidator();

  String? required(dynamic value) {
    if (value is String?) {
      if (value == null || value.isEmpty) {
        return ValidationMessages.required;
      }
      return null;
    }

    if (value is num?) {
      if (value == null || value == 0) {
        return ValidationMessages.required;
      }
      return null;
    }

    if (value == null) {
      return ValidationMessages.required;
    }

    return null;
  }

  String? numberOnly(dynamic value) {
    if (value == null || value == 0 || value == '') {
      return ValidationMessages.required;
    }

    var parsedValue = num.tryParse(value as String);

    if (parsedValue == null) {
      return ValidationMessages.invalidFormat;
    }

    return null;
  }

  String? email(dynamic value) {
    if (value is String?) {
      if (value == null || value.isEmpty) {
        return ValidationMessages.required;
      }
      return null;
    }

    if (value == null) {
      return ValidationMessages.required;
    }

    var emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+(?:\.[a-zA-Z]{2,}){1,2}$");

    if (!emailRegex.hasMatch(value)) {
      return ValidationMessages.invalidFormat;
    }

    return null;
  }
}



