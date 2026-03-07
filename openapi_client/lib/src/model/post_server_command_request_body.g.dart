// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_server_command_request_body.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostServerCommandRequestBody extends PostServerCommandRequestBody {
  @override
  final String? command;

  factory _$PostServerCommandRequestBody(
          [void Function(PostServerCommandRequestBodyBuilder)? updates]) =>
      (PostServerCommandRequestBodyBuilder()..update(updates))._build();

  _$PostServerCommandRequestBody._({this.command}) : super._();
  @override
  PostServerCommandRequestBody rebuild(
          void Function(PostServerCommandRequestBodyBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostServerCommandRequestBodyBuilder toBuilder() =>
      PostServerCommandRequestBodyBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostServerCommandRequestBody && command == other.command;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, command.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostServerCommandRequestBody')
          ..add('command', command))
        .toString();
  }
}

class PostServerCommandRequestBodyBuilder
    implements
        Builder<PostServerCommandRequestBody,
            PostServerCommandRequestBodyBuilder> {
  _$PostServerCommandRequestBody? _$v;

  String? _command;
  String? get command => _$this._command;
  set command(String? command) => _$this._command = command;

  PostServerCommandRequestBodyBuilder() {
    PostServerCommandRequestBody._defaults(this);
  }

  PostServerCommandRequestBodyBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _command = $v.command;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostServerCommandRequestBody other) {
    _$v = other as _$PostServerCommandRequestBody;
  }

  @override
  void update(void Function(PostServerCommandRequestBodyBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostServerCommandRequestBody build() => _build();

  _$PostServerCommandRequestBody _build() {
    final _$result = _$v ??
        _$PostServerCommandRequestBody._(
          command: command,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
