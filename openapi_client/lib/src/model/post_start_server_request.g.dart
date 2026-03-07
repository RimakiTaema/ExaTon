// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_start_server_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostStartServerRequest extends PostStartServerRequest {
  @override
  final bool? useOwnCredits;

  factory _$PostStartServerRequest(
          [void Function(PostStartServerRequestBuilder)? updates]) =>
      (PostStartServerRequestBuilder()..update(updates))._build();

  _$PostStartServerRequest._({this.useOwnCredits}) : super._();
  @override
  PostStartServerRequest rebuild(
          void Function(PostStartServerRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostStartServerRequestBuilder toBuilder() =>
      PostStartServerRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostStartServerRequest &&
        useOwnCredits == other.useOwnCredits;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, useOwnCredits.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostStartServerRequest')
          ..add('useOwnCredits', useOwnCredits))
        .toString();
  }
}

class PostStartServerRequestBuilder
    implements Builder<PostStartServerRequest, PostStartServerRequestBuilder> {
  _$PostStartServerRequest? _$v;

  bool? _useOwnCredits;
  bool? get useOwnCredits => _$this._useOwnCredits;
  set useOwnCredits(bool? useOwnCredits) =>
      _$this._useOwnCredits = useOwnCredits;

  PostStartServerRequestBuilder() {
    PostStartServerRequest._defaults(this);
  }

  PostStartServerRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _useOwnCredits = $v.useOwnCredits;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostStartServerRequest other) {
    _$v = other as _$PostStartServerRequest;
  }

  @override
  void update(void Function(PostStartServerRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostStartServerRequest build() => _build();

  _$PostStartServerRequest _build() {
    final _$result = _$v ??
        _$PostStartServerRequest._(
          useOwnCredits: useOwnCredits,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
