
part of 'vozilo.dart';


Vozilo _$VoziloFromJson(Map<String, dynamic> json) => Vozilo(
      (json['voziloId'] as num?)?.toInt(),
      json['vidljivo'] as bool?,
      json['markaVozila'] as String?,
    );

Map<String, dynamic> _$VoziloToJson(Vozilo instance) => <String, dynamic>{
      'voziloId': instance.voziloId,
      'markaVozila': instance.markaVozila,
      'vidljivo': instance.vidljivo,
    };
