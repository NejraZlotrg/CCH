
part of 'drzave.dart';


Drzave _$DrzaveFromJson(Map<String, dynamic> json) => Drzave(
      (json['drzavaId'] as num?)?.toInt(),
      json['vidljivo'] as bool?,
      json['nazivDrzave'] as String?,
    );

Map<String, dynamic> _$DrzaveToJson(Drzave instance) => <String, dynamic>{
      'drzavaId': instance.drzavaId,
      'nazivDrzave': instance.nazivDrzave,
      'vidljivo': instance.vidljivo,
    };
