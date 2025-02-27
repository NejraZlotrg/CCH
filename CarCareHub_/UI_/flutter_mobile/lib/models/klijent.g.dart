// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'klijent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Klijent _$KlijentFromJson(Map<String, dynamic> json) => Klijent(
      (json['klijentId'] as num).toInt(),
      json['vidljivo'] as bool?,
      json['ime'] as String?,
      json['prezime'] as String?,
      json['username'] as String?,
      json['email'] as String?,
      json['password'] as String?,
      json['lozinkaSalt'] as String?,
      json['lozinkaHash'] as String?,
      json['spol'] as String?,
      json['brojTelefona'] as String?,
      (json['gradId'] as num?)?.toInt(),
      json['passwordAgain'] as String?,
    )..ulogaId = (json['ulogaId'] as num?)?.toInt();

Map<String, dynamic> _$KlijentToJson(Klijent instance) => <String, dynamic>{
      'klijentId': instance.klijentId,
      'ime': instance.ime,
      'prezime': instance.prezime,
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
      'passwordAgain': instance.passwordAgain,
      'lozinkaSalt': instance.lozinkaSalt,
      'lozinkaHash': instance.lozinkaHash,
      'spol': instance.spol,
      'brojTelefona': instance.brojTelefona,
      'gradId': instance.gradId,
      'ulogaId': instance.ulogaId,
      'vidljivo': instance.vidljivo,
    };
