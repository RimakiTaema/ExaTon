// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_info.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FileInfo extends FileInfo {
  @override
  final String? path;
  @override
  final String? name;
  @override
  final bool? isTextFile;
  @override
  final bool? isConfigFile;
  @override
  final bool? isDirectory;
  @override
  final bool? isLog;
  @override
  final bool? isReadable;
  @override
  final bool? isWritable;
  @override
  final int? size;
  @override
  final BuiltList<FileInfo>? children;

  factory _$FileInfo([void Function(FileInfoBuilder)? updates]) =>
      (FileInfoBuilder()..update(updates))._build();

  _$FileInfo._(
      {this.path,
      this.name,
      this.isTextFile,
      this.isConfigFile,
      this.isDirectory,
      this.isLog,
      this.isReadable,
      this.isWritable,
      this.size,
      this.children})
      : super._();
  @override
  FileInfo rebuild(void Function(FileInfoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FileInfoBuilder toBuilder() => FileInfoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FileInfo &&
        path == other.path &&
        name == other.name &&
        isTextFile == other.isTextFile &&
        isConfigFile == other.isConfigFile &&
        isDirectory == other.isDirectory &&
        isLog == other.isLog &&
        isReadable == other.isReadable &&
        isWritable == other.isWritable &&
        size == other.size &&
        children == other.children;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, path.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, isTextFile.hashCode);
    _$hash = $jc(_$hash, isConfigFile.hashCode);
    _$hash = $jc(_$hash, isDirectory.hashCode);
    _$hash = $jc(_$hash, isLog.hashCode);
    _$hash = $jc(_$hash, isReadable.hashCode);
    _$hash = $jc(_$hash, isWritable.hashCode);
    _$hash = $jc(_$hash, size.hashCode);
    _$hash = $jc(_$hash, children.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FileInfo')
          ..add('path', path)
          ..add('name', name)
          ..add('isTextFile', isTextFile)
          ..add('isConfigFile', isConfigFile)
          ..add('isDirectory', isDirectory)
          ..add('isLog', isLog)
          ..add('isReadable', isReadable)
          ..add('isWritable', isWritable)
          ..add('size', size)
          ..add('children', children))
        .toString();
  }
}

class FileInfoBuilder implements Builder<FileInfo, FileInfoBuilder> {
  _$FileInfo? _$v;

  String? _path;
  String? get path => _$this._path;
  set path(String? path) => _$this._path = path;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  bool? _isTextFile;
  bool? get isTextFile => _$this._isTextFile;
  set isTextFile(bool? isTextFile) => _$this._isTextFile = isTextFile;

  bool? _isConfigFile;
  bool? get isConfigFile => _$this._isConfigFile;
  set isConfigFile(bool? isConfigFile) => _$this._isConfigFile = isConfigFile;

  bool? _isDirectory;
  bool? get isDirectory => _$this._isDirectory;
  set isDirectory(bool? isDirectory) => _$this._isDirectory = isDirectory;

  bool? _isLog;
  bool? get isLog => _$this._isLog;
  set isLog(bool? isLog) => _$this._isLog = isLog;

  bool? _isReadable;
  bool? get isReadable => _$this._isReadable;
  set isReadable(bool? isReadable) => _$this._isReadable = isReadable;

  bool? _isWritable;
  bool? get isWritable => _$this._isWritable;
  set isWritable(bool? isWritable) => _$this._isWritable = isWritable;

  int? _size;
  int? get size => _$this._size;
  set size(int? size) => _$this._size = size;

  ListBuilder<FileInfo>? _children;
  ListBuilder<FileInfo> get children =>
      _$this._children ??= ListBuilder<FileInfo>();
  set children(ListBuilder<FileInfo>? children) => _$this._children = children;

  FileInfoBuilder() {
    FileInfo._defaults(this);
  }

  FileInfoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _path = $v.path;
      _name = $v.name;
      _isTextFile = $v.isTextFile;
      _isConfigFile = $v.isConfigFile;
      _isDirectory = $v.isDirectory;
      _isLog = $v.isLog;
      _isReadable = $v.isReadable;
      _isWritable = $v.isWritable;
      _size = $v.size;
      _children = $v.children?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FileInfo other) {
    _$v = other as _$FileInfo;
  }

  @override
  void update(void Function(FileInfoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FileInfo build() => _build();

  _$FileInfo _build() {
    _$FileInfo _$result;
    try {
      _$result = _$v ??
          _$FileInfo._(
            path: path,
            name: name,
            isTextFile: isTextFile,
            isConfigFile: isConfigFile,
            isDirectory: isDirectory,
            isLog: isLog,
            isReadable: isReadable,
            isWritable: isWritable,
            size: size,
            children: _children?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'children';
        _children?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'FileInfo', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
