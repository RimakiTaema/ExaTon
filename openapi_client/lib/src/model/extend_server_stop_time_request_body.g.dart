// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extend_server_stop_time_request_body.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ExtendServerStopTimeRequestBody
    extends ExtendServerStopTimeRequestBody {
  @override
  final int? time;

  factory _$ExtendServerStopTimeRequestBody(
          [void Function(ExtendServerStopTimeRequestBodyBuilder)? updates]) =>
      (ExtendServerStopTimeRequestBodyBuilder()..update(updates))._build();

  _$ExtendServerStopTimeRequestBody._({this.time}) : super._();
  @override
  ExtendServerStopTimeRequestBody rebuild(
          void Function(ExtendServerStopTimeRequestBodyBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExtendServerStopTimeRequestBodyBuilder toBuilder() =>
      ExtendServerStopTimeRequestBodyBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExtendServerStopTimeRequestBody && time == other.time;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, time.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ExtendServerStopTimeRequestBody')
          ..add('time', time))
        .toString();
  }
}

class ExtendServerStopTimeRequestBodyBuilder
    implements
        Builder<ExtendServerStopTimeRequestBody,
            ExtendServerStopTimeRequestBodyBuilder> {
  _$ExtendServerStopTimeRequestBody? _$v;

  int? _time;
  int? get time => _$this._time;
  set time(int? time) => _$this._time = time;

  ExtendServerStopTimeRequestBodyBuilder() {
    ExtendServerStopTimeRequestBody._defaults(this);
  }

  ExtendServerStopTimeRequestBodyBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _time = $v.time;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ExtendServerStopTimeRequestBody other) {
    _$v = other as _$ExtendServerStopTimeRequestBody;
  }

  @override
  void update(void Function(ExtendServerStopTimeRequestBodyBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ExtendServerStopTimeRequestBody build() => _build();

  _$ExtendServerStopTimeRequestBody _build() {
    final _$result = _$v ??
        _$ExtendServerStopTimeRequestBody._(
          time: time,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
