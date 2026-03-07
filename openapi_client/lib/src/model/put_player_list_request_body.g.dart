// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_player_list_request_body.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PutPlayerListRequestBody extends PutPlayerListRequestBody {
  @override
  final BuiltList<String>? entries;

  factory _$PutPlayerListRequestBody(
          [void Function(PutPlayerListRequestBodyBuilder)? updates]) =>
      (PutPlayerListRequestBodyBuilder()..update(updates))._build();

  _$PutPlayerListRequestBody._({this.entries}) : super._();
  @override
  PutPlayerListRequestBody rebuild(
          void Function(PutPlayerListRequestBodyBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PutPlayerListRequestBodyBuilder toBuilder() =>
      PutPlayerListRequestBodyBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PutPlayerListRequestBody && entries == other.entries;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, entries.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PutPlayerListRequestBody')
          ..add('entries', entries))
        .toString();
  }
}

class PutPlayerListRequestBodyBuilder
    implements
        Builder<PutPlayerListRequestBody, PutPlayerListRequestBodyBuilder> {
  _$PutPlayerListRequestBody? _$v;

  ListBuilder<String>? _entries;
  ListBuilder<String> get entries => _$this._entries ??= ListBuilder<String>();
  set entries(ListBuilder<String>? entries) => _$this._entries = entries;

  PutPlayerListRequestBodyBuilder() {
    PutPlayerListRequestBody._defaults(this);
  }

  PutPlayerListRequestBodyBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _entries = $v.entries?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PutPlayerListRequestBody other) {
    _$v = other as _$PutPlayerListRequestBody;
  }

  @override
  void update(void Function(PutPlayerListRequestBodyBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PutPlayerListRequestBody build() => _build();

  _$PutPlayerListRequestBody _build() {
    _$PutPlayerListRequestBody _$result;
    try {
      _$result = _$v ??
          _$PutPlayerListRequestBody._(
            entries: _entries?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'entries';
        _entries?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PutPlayerListRequestBody', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
