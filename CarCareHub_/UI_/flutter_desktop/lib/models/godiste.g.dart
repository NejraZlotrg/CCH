// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'godiste.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Godiste _$GodisteFromJson(Map<String, dynamic> json) => Godiste(
      (json['godisteId'] as num?)?.toInt(),
      json['Vidljivo'] as bool?,
      (json['godiste_'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GodisteToJson(Godiste instance) => <String, dynamic>{
      'godisteId': instance.godisteId,
      'godiste_': instance.godiste_,
      'Vidljivo': instance.Vidljivo,
    };
