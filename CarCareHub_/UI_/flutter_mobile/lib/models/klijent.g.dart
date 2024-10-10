// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'klijent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Klijent _$KlijentFromJson(Map<String, dynamic> json) => Klijent(
      (json['KlijentId'] as num?)?.toInt(),
      json['Ime'] as String?,
      json['Prezime'] as String?,
      json['Username'] as String?,
      json['Email'] as String?,
      json['Password'] as String?,
      json['LozinkaSalt'] as String?,
      json['LozinkaHash'] as String?,
      json['Spol'] as String?,
      json['BrojTelefona'] as String?,
      (json['GradId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$KlijentToJson(Klijent instance) => <String, dynamic>{
      'KlijentId': instance.KlijentId,
      'Ime': instance.Ime,
      'Prezime': instance.Prezime,
      'Username': instance.Username,
      'Email': instance.Email,
      'Password': instance.Password,
      'LozinkaSalt': instance.LozinkaSalt,
      'LozinkaHash': instance.LozinkaHash,
      'Spol': instance.Spol,
      'BrojTelefona': instance.BrojTelefona,
      'GradId': instance.GradId,
    };
