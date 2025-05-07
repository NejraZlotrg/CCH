
part of 'godiste.dart';

Godiste _$GodisteFromJson(Map<String, dynamic> json) => Godiste(
      (json['godisteId'] as num?)?.toInt(),
      json['vidljivo'] as bool?,
      (json['godiste_'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GodisteToJson(Godiste instance) => <String, dynamic>{
      'godisteId': instance.godisteId,
      'godiste_': instance.godiste_,
      'vidljivo': instance.vidljivo,
    };
