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

  String? nazivFirme(dynamic value) {
    if (value is String?) {
      if (value == null || value.isEmpty) {
        return ValidationMessages.required;
      }
      if (value.length < 2 || value.length > 100) {
        return 'Polje mora sadržavati između 2 i 100 karaktera.';
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

  String? adresa(dynamic value) {
    if (value == null || value.isEmpty) {
      return "Adresa je obavezna.";
    }

    if (value is String && (value.length < 5 || value.length > 100)) {
      return "Adresa mora imati između 5 i 100 karaktera.";
    }

    return null;
  }

  String? password(dynamic value) {
    if (value == null || value.isEmpty) {
      return "Lozinka je obavezna.";
    }

    if (value is String && (value.length < 6 || value.length > 100)) {
      return "Lozinka mora imati između 6 i 100 karaktera.";
    }

    return null;
  }

  String? prezime(dynamic value) {
    if (value == null || value.isEmpty) {
      return "Prezime je obavezno.";
    }

    if (value is String && (value.length < 2 || value.length > 50)) {
      return "Prezime mora imati između 2 i 50 karaktera.";
    }

    return null;
  }

  String? username3char(dynamic value) {
    if (value == null || value.isEmpty) {
      return "Korsinicko ime je obavezno.";
    }

    if (value is String && (value.length < 3 || value.length > 50)) {
      return "Korisnicko ime mora imati između 3 i 50 karaktera.";
    }

    return null;
  }

  String? numberOnly(dynamic value) {
    if (value == null || value == 0 || value == '') {
      return ValidationMessages.required;
    }

    if (value == null) {
      return ValidationMessages.invalidFormat;
    }

    return null;
  }

  String? numberWith12DigitsOnly(dynamic value) {
    if (value == null || value == 0) {
      return ValidationMessages.required;
    }

    String valueStr = value.toString();

    if (valueStr.length != 13) {
      return 'Broj mora imati tačno 13 cifara.';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(valueStr)) {
      return 'Broj mora sadržavati samo cifre.';
    }

    return null;
  }

  String? jib(dynamic value) {
    if (value == null || value == 0 || value == '') {
      return ValidationMessages.required;
    }

    var jibRegex = RegExp(r"^\d{13}$");

    if (value is String && !jibRegex.hasMatch(value)) {
      return ValidationMessages.jib;
    }

    return null;
  }

  String? requiredMin5Chars(dynamic value) {
    if (value == null || (value is String && value.trim().isEmpty)) {
      return ValidationMessages.required;
    }

    if (value is String && value.trim().length < 5) {
      return ValidationMessages.length5;
    }

    return null;
  }

  String? mbs(dynamic value) {
    if (value == null || value == 0 || value == '') {
      return ValidationMessages.required;
    }

    var mbsRegex = RegExp(r"^\d{9}$");

    if (value is String && !mbsRegex.hasMatch(value)) {
      return ValidationMessages.mbs;
    }

    return null;
  }

  String? email(dynamic value) {
    if (value == null || (value is String && value.isEmpty)) {
      return ValidationMessages.required;
    }

    var emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

    if (value is String && !emailRegex.hasMatch(value)) {
      return ValidationMessages.invalidFormat;
    }

    return null;
  }

  String? phoneNumber(dynamic value) {
    if (value == null || (value is String && value.isEmpty)) {
      return ValidationMessages.required;
    }

    var phoneRegex = RegExp(r"^(\+?\d{1,3})(6\d{7,8})$");

    if (value is String && !phoneRegex.hasMatch(value)) {
      return ValidationMessages.phoneNumberFormat;
    }

    return null;
  }

  String? godiste(dynamic value) {
    if (value == null || value == 0 || value == '') {
      return ValidationMessages.required;
    }

    var mbsRegex = RegExp(r"^\d{4}$");

    if (value is String && !mbsRegex.hasMatch(value)) {
      return ValidationMessages.godiste;
    }

    return null;
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
