// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proizvodjac.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Proizvodjac _$ProizvodjacFromJson(Map<String, dynamic> json) => Proizvodjac(
      (json['proizvodjacId'] as num?)?.toInt(),
      json['Vidljivo'] as bool?,
      json['nazivProizvodjaca'] as String?,
    );

Map<String, dynamic> _$ProizvodjacToJson(Proizvodjac instance) =>
    <String, dynamic>{
      'proizvodjacId': instance.proizvodjacId,
      'nazivProizvodjaca': instance.nazivProizvodjaca,
      'Vidljivo': instance.Vidljivo,
    };
