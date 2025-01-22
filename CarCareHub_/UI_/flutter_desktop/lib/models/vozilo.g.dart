// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vozilo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vozilo _$VoziloFromJson(Map<String, dynamic> json) => Vozilo(
      (json['voziloId'] as num?)?.toInt(),
      json['markaVozila'] as String?,
    );

Map<String, dynamic> _$VoziloToJson(Vozilo instance) => <String, dynamic>{
      'voziloId': instance.voziloId,
      'markaVozila': instance.markaVozila,
    };
