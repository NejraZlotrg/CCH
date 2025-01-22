// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grad.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Grad _$GradFromJson(Map<String, dynamic> json) => Grad(
      (json['gradId'] as num?)?.toInt(),
      json['nazivGrada'] as String?,
      (json['drzavaId'] as num?)?.toInt(),
      json['drzava'] == null
          ? null
          : Drzave.fromJson(json['drzava'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GradToJson(Grad instance) => <String, dynamic>{
      'gradId': instance.gradId,
      'nazivGrada': instance.nazivGrada,
      'drzavaId': instance.drzavaId,
      'drzava': instance.drzava,
    };
