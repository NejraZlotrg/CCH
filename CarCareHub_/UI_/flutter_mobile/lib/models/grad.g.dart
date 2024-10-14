// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grad.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Grad _$GradFromJson(Map<String, dynamic> json) => Grad(
      (json['gradId'] as num?)?.toInt(),
      json['nazivGrada'] as String?,
      (json['drzavaId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GradToJson(Grad instance) => <String, dynamic>{
      'gradId': instance.gradId,
      'nazivGrada': instance.nazivGrada,
      'drzavaId': instance.drzavaId,
    };
