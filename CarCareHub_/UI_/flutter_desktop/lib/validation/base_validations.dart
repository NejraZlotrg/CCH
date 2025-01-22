
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

  
  String? jib(dynamic value) {
    if (value == null || value == 0 || value == '') {
      return ValidationMessages.required;
    }

   // Regex za validaciju emaila
var jibRegex = RegExp(r"^\d{13}$");

  if (value is String && !jibRegex.hasMatch(value)) {
    return ValidationMessages.jib; // Neispravan format
  }

  return null; // Sve je validno
  }  

  String? mbs(dynamic value) {
    if (value == null || value == 0 || value == '') {
      return ValidationMessages.required;
    }

   // Regex za validaciju emaila
var mbsRegex = RegExp(r"^\d{8}$");

  if (value is String && !mbsRegex.hasMatch(value)) {
    return ValidationMessages.mbs; // Neispravan format
  }

  return null; // Sve je validno
  }



String? email(dynamic value) {
  if (value == null || (value is String && value.isEmpty)) {
    return ValidationMessages.required; // Provjerava required
  }

  // Regex za validaciju emaila
  var emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

  if (value is String && !emailRegex.hasMatch(value)) {
    return ValidationMessages.invalidFormat; // Neispravan format
  }

  return null; // Sve je validno
}

String? phoneNumber(dynamic value) {
  if (value == null || (value is String && value.isEmpty)) {
    return ValidationMessages.required; // Provjerava required
  }

  // Regex za validaciju brojeva telefona
  var phoneRegex = RegExp(r"^(\+?\d{1,3})(6\d{7,8})$");

  if (value is String && !phoneRegex.hasMatch(value)) {
    return ValidationMessages.phoneNumberFormat; // Neispravan format
  }

  return null; // Sve je validno
}


  String? godiste(dynamic value) {
    if (value == null || value == 0 || value == '') {
      return ValidationMessages.required;
    }

   // Regex za validaciju emaila
var mbsRegex = RegExp(r"^\d{4}$");

  if (value is String && !mbsRegex.hasMatch(value)) {
    return ValidationMessages.godiste; // Neispravan format
  }

  return null; // Sve je validno
  }




  
  String? lozinkaAgain(dynamic value) {
    if (value is String?) {
      if (value == null || value.isEmpty) {
        return ValidationMessages.required;
      }
      return null;
    }

    if (value is num?) {
      if (value == null || value == 0) {
        return ValidationMessages.lozinkaPonovo;
      }
      return null;
    }

    if (value == null) {
      return ValidationMessages.lozinkaPonovo;
    }

    return null;
  }

}



