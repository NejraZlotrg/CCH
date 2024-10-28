// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zaposlenik.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Zaposlenik _$ZaposlenikFromJson(Map<String, dynamic> json) => Zaposlenik(
      zaposlenikId: (json['zaposlenikId'] as num?)?.toInt(),
      ime: json['ime'] as String?,
      prezime: json['prezime'] as String?,
     
    );

Map<String, dynamic> _$ZaposlenikToJson(Zaposlenik instance) =>
    <String, dynamic>{
      'zaposlenikId': instance.zaposlenikId,
      'ime': instance.ime,
      'prezime': instance.prezime,
     
    };
