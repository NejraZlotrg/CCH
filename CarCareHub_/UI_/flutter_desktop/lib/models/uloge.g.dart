
part of 'uloge.dart';


Uloge _$UlogeFromJson(Map<String, dynamic> json) => Uloge(
      (json['ulogaId'] as num?)?.toInt(),
      json['vidljivo'] as bool?,
      json['nazivUloge'] as String?,
    );

Map<String, dynamic> _$UlogeToJson(Uloge instance) => <String, dynamic>{
      'ulogaId': instance.ulogaId,
      'nazivUloge': instance.nazivUloge,
      'vidljivo': instance.vidljivo,
    };
