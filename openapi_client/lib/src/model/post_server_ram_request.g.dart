// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_server_ram_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostServerRamRequest extends PostServerRamRequest {
  @override
  final int ram;

  factory _$PostServerRamRequest(
          [void Function(PostServerRamRequestBuilder)? updates]) =>
      (PostServerRamRequestBuilder()..update(updates))._build();

  _$PostServerRamRequest._({required this.ram}) : super._();
  @override
  PostServerRamRequest rebuild(
          void Function(PostServerRamRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostServerRamRequestBuilder toBuilder() =>
      PostServerRamRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostServerRamRequest && ram == other.ram;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ram.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostServerRamRequest')
          ..add('ram', ram))
        .toString();
  }
}

class PostServerRamRequestBuilder
    implements Builder<PostServerRamRequest, PostServerRamRequestBuilder> {
  _$PostServerRamRequest? _$v;

  int? _ram;
  int? get ram => _$this._ram;
  set ram(int? ram) => _$this._ram = ram;

  PostServerRamRequestBuilder() {
    PostServerRamRequest._defaults(this);
  }

  PostServerRamRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ram = $v.ram;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostServerRamRequest other) {
    _$v = other as _$PostServerRamRequest;
  }

  @override
  void update(void Function(PostServerRamRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostServerRamRequest build() => _build();

  _$PostServerRamRequest _build() {
    final _$result = _$v ??
        _$PostServerRamRequest._(
          ram: BuiltValueNullFieldError.checkNotNull(
              ram, r'PostServerRamRequest', 'ram'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
