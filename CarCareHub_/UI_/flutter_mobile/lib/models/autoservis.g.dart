// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autoservis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Autoservis _$AutoservisFromJson(Map<String, dynamic> json) => Autoservis(
      (json['autoservisId'] as num?)?.toInt(),
      json['naziv'] as String?,
      json['adresa'] as String?,
      json['vlasnikFirme'] as String?,
      json['korisnickoIme'] as String?,
      (json['gradId'] as num?)?.toInt(),
      json['telefon'] as String?,
      json['password'] as String?,
      json['email'] as String?,
      json['jib'] as String?,
      json['mbs'] as String?,
      json['slikaProfila'] as String?,
      (json['ulogaId'] as num?)?.toInt(),
      (json['voziloId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AutoservisToJson(Autoservis instance) =>
    <String, dynamic>{
      'autoservisId': instance.autoservisId,
      'naziv': instance.naziv,
      'adresa': instance.adresa,
      'vlasnikFirme': instance.vlasnikFirme,
      'korisnickoIme': instance.korisnickoIme,
      'gradId': instance.gradId,
      'telefon': instance.telefon,
      'email': instance.email,
      'password': instance.password,
      'jib': instance.jib,
      'mbs': instance.mbs,
      'slikaProfila': instance.slikaProfila,
      'ulogaId': instance.ulogaId,
      'voziloId': instance.voziloId,
    };
