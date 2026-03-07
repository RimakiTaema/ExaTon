// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_player_list_request_body.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeletePlayerListRequestBody extends DeletePlayerListRequestBody {
  @override
  final BuiltList<String>? entries;

  factory _$DeletePlayerListRequestBody(
          [void Function(DeletePlayerListRequestBodyBuilder)? updates]) =>
      (DeletePlayerListRequestBodyBuilder()..update(updates))._build();

  _$DeletePlayerListRequestBody._({this.entries}) : super._();
  @override
  DeletePlayerListRequestBody rebuild(
          void Function(DeletePlayerListRequestBodyBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeletePlayerListRequestBodyBuilder toBuilder() =>
      DeletePlayerListRequestBodyBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeletePlayerListRequestBody && entries == other.entries;
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
    return (newBuiltValueToStringHelper(r'DeletePlayerListRequestBody')
          ..add('entries', entries))
        .toString();
  }
}

class DeletePlayerListRequestBodyBuilder
    implements
        Builder<DeletePlayerListRequestBody,
            DeletePlayerListRequestBodyBuilder> {
  _$DeletePlayerListRequestBody? _$v;

  ListBuilder<String>? _entries;
  ListBuilder<String> get entries => _$this._entries ??= ListBuilder<String>();
  set entries(ListBuilder<String>? entries) => _$this._entries = entries;

  DeletePlayerListRequestBodyBuilder() {
    DeletePlayerListRequestBody._defaults(this);
  }

  DeletePlayerListRequestBodyBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _entries = $v.entries?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeletePlayerListRequestBody other) {
    _$v = other as _$DeletePlayerListRequestBody;
  }

  @override
  void update(void Function(DeletePlayerListRequestBodyBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeletePlayerListRequestBody build() => _build();

  _$DeletePlayerListRequestBody _build() {
    _$DeletePlayerListRequestBody _$result;
    try {
      _$result = _$v ??
          _$DeletePlayerListRequestBody._(
            entries: _entries?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'entries';
        _entries?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'DeletePlayerListRequestBody', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
