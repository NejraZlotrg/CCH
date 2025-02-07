// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firmaautodijelova.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FirmaAutodijelova _$FirmaAutodijelovaFromJson(Map<String, dynamic> json) =>
    FirmaAutodijelova(
      (json['firmaAutodijelovaID'] as num).toInt(),
      json['Vidljivo'] as bool?,
      json['nazivFirme'] as String?,
      json['adresa'] as String?,
      json['email'] as String?,
      (json['gradId'] as num?)?.toInt(),
      json['jib'] as String?,
      json['mbs'] as String?,
      json['password'] as String?,
      json['slikaProfila'] as String?,
      json['telefon'] as String?,
      (json['ulogaId'] as num?)?.toInt(),
      json['grad'] == null
          ? null
          : Grad.fromJson(json['grad'] as Map<String, dynamic>),
      json['passwordAgain'] as String?,
      json['username'] as String?,
    );

Map<String, dynamic> _$FirmaAutodijelovaToJson(FirmaAutodijelova instance) =>
    <String, dynamic>{
      'firmaAutodijelovaID': instance.firmaAutodijelovaID,
      'nazivFirme': instance.nazivFirme,
      'adresa': instance.adresa,
      'gradId': instance.gradId,
      'grad': instance.grad,
      'jib': instance.jib,
      'mbs': instance.mbs,
      'telefon': instance.telefon,
      'email': instance.email,
      'password': instance.password,
      'slikaProfila': instance.slikaProfila,
      'username': instance.username,
      'ulogaId': instance.ulogaId,
      'passwordAgain': instance.passwordAgain,
      'Vidljivo': instance.Vidljivo,
    };
