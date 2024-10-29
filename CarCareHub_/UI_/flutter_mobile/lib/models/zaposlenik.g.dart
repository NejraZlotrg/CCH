// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zaposlenik.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Zaposlenik _$ZaposlenikFromJson(Map<String, dynamic> json) => Zaposlenik(
      zaposlenikId: (json['zaposlenikId'] as num?)?.toInt(),
      ime: json['ime'] as String?,
      prezime: json['prezime'] as String?,
      maticniBroj: (json['maticniBroj'] as num?)?.toInt(),
      brojTelefona: (json['brojTelefona'] as num?)?.toInt(),
      gradId: (json['gradId'] as num?)?.toInt(),
      datumRodjenja: json['datumRodjenja'] == null
          ? null
          : DateTime.parse(json['datumRodjenja'] as String),
      email: json['email'] as String?,
      username: json['username'] as String?,
      lozinkaSalt: json['lozinkaSalt'] as String?,
      lozinkaHash: json['lozinkaHash'] as String?,
      password: json['password'] as String?,
      ulogaId: (json['ulogaId'] as num?)?.toInt(),
      autoservisId: (json['autoservisId'] as num?)?.toInt(),
      firmaAutodijelovaId: (json['firmaAutodijelovaId'] as num?)?.toInt(),
      grad: json['grad'] == null
          ? null
          : Grad.fromJson(json['grad'] as Map<String, dynamic>),
      autoservis: json['autoservis'] == null
          ? null
          : Autoservis.fromJson(json['autoservis'] as Map<String, dynamic>),
      firmaAutodijelova: json['firmaAutodijelova'] == null
          ? null
          : FirmaAutodijelova.fromJson(
              json['firmaAutodijelova'] as Map<String, dynamic>),
      uloga: json['uloga'] == null
          ? null
          : Uloge.fromJson(json['uloga'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ZaposlenikToJson(Zaposlenik instance) =>
    <String, dynamic>{
      'zaposlenikId': instance.zaposlenikId,
      'ime': instance.ime,
      'prezime': instance.prezime,
      'maticniBroj': instance.maticniBroj,
      'brojTelefona': instance.brojTelefona,
      'grad': instance.grad,
      'gradId': instance.gradId,
      'datumRodjenja': instance.datumRodjenja?.toIso8601String(),
      'email': instance.email,
      'username': instance.username,
      'lozinkaSalt': instance.lozinkaSalt,
      'lozinkaHash': instance.lozinkaHash,
      'password': instance.password,
      'ulogaId': instance.ulogaId,
      'uloga': instance.uloga,
      'autoservisId': instance.autoservisId,
      'autoservis': instance.autoservis,
      'firmaAutodijelovaId': instance.firmaAutodijelovaId,
      'firmaAutodijelova': instance.firmaAutodijelova,
    };
