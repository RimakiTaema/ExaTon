// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_server_log200_response_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShareServerLog200ResponseData extends ShareServerLog200ResponseData {
  @override
  final String? id;
  @override
  final String? url;
  @override
  final String? raw;

  factory _$ShareServerLog200ResponseData(
          [void Function(ShareServerLog200ResponseDataBuilder)? updates]) =>
      (ShareServerLog200ResponseDataBuilder()..update(updates))._build();

  _$ShareServerLog200ResponseData._({this.id, this.url, this.raw}) : super._();
  @override
  ShareServerLog200ResponseData rebuild(
          void Function(ShareServerLog200ResponseDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShareServerLog200ResponseDataBuilder toBuilder() =>
      ShareServerLog200ResponseDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShareServerLog200ResponseData &&
        id == other.id &&
        url == other.url &&
        raw == other.raw;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, raw.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShareServerLog200ResponseData')
          ..add('id', id)
          ..add('url', url)
          ..add('raw', raw))
        .toString();
  }
}

class ShareServerLog200ResponseDataBuilder
    implements
        Builder<ShareServerLog200ResponseData,
            ShareServerLog200ResponseDataBuilder> {
  _$ShareServerLog200ResponseData? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  String? _raw;
  String? get raw => _$this._raw;
  set raw(String? raw) => _$this._raw = raw;

  ShareServerLog200ResponseDataBuilder() {
    ShareServerLog200ResponseData._defaults(this);
  }

  ShareServerLog200ResponseDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _url = $v.url;
      _raw = $v.raw;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShareServerLog200ResponseData other) {
    _$v = other as _$ShareServerLog200ResponseData;
  }

  @override
  void update(void Function(ShareServerLog200ResponseDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShareServerLog200ResponseData build() => _build();

  _$ShareServerLog200ResponseData _build() {
    final _$result = _$v ??
        _$ShareServerLog200ResponseData._(
          id: id,
          url: url,
          raw: raw,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
