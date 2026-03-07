// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_server_motd_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostServerMotdRequest extends PostServerMotdRequest {
  @override
  final String motd;

  factory _$PostServerMotdRequest(
          [void Function(PostServerMotdRequestBuilder)? updates]) =>
      (PostServerMotdRequestBuilder()..update(updates))._build();

  _$PostServerMotdRequest._({required this.motd}) : super._();
  @override
  PostServerMotdRequest rebuild(
          void Function(PostServerMotdRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostServerMotdRequestBuilder toBuilder() =>
      PostServerMotdRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostServerMotdRequest && motd == other.motd;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, motd.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostServerMotdRequest')
          ..add('motd', motd))
        .toString();
  }
}

class PostServerMotdRequestBuilder
    implements Builder<PostServerMotdRequest, PostServerMotdRequestBuilder> {
  _$PostServerMotdRequest? _$v;

  String? _motd;
  String? get motd => _$this._motd;
  set motd(String? motd) => _$this._motd = motd;

  PostServerMotdRequestBuilder() {
    PostServerMotdRequest._defaults(this);
  }

  PostServerMotdRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _motd = $v.motd;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostServerMotdRequest other) {
    _$v = other as _$PostServerMotdRequest;
  }

  @override
  void update(void Function(PostServerMotdRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostServerMotdRequest build() => _build();

  _$PostServerMotdRequest _build() {
    final _$result = _$v ??
        _$PostServerMotdRequest._(
          motd: BuiltValueNullFieldError.checkNotNull(
              motd, r'PostServerMotdRequest', 'motd'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
