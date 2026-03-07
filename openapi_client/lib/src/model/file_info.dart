//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'file_info.g.dart';

/// FileInfo
///
/// Properties:
/// * [path] 
/// * [name] 
/// * [isTextFile] 
/// * [isConfigFile] 
/// * [isDirectory] 
/// * [isLog] 
/// * [isReadable] 
/// * [isWritable] 
/// * [size] 
/// * [children] 
@BuiltValue()
abstract class FileInfo implements Built<FileInfo, FileInfoBuilder> {
  @BuiltValueField(wireName: r'path')
  String? get path;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'isTextFile')
  bool? get isTextFile;

  @BuiltValueField(wireName: r'isConfigFile')
  bool? get isConfigFile;

  @BuiltValueField(wireName: r'isDirectory')
  bool? get isDirectory;

  @BuiltValueField(wireName: r'isLog')
  bool? get isLog;

  @BuiltValueField(wireName: r'isReadable')
  bool? get isReadable;

  @BuiltValueField(wireName: r'isWritable')
  bool? get isWritable;

  @BuiltValueField(wireName: r'size')
  int? get size;

  @BuiltValueField(wireName: r'children')
  BuiltList<FileInfo>? get children;

  FileInfo._();

  factory FileInfo([void updates(FileInfoBuilder b)]) = _$FileInfo;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FileInfoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FileInfo> get serializer => _$FileInfoSerializer();
}

class _$FileInfoSerializer implements PrimitiveSerializer<FileInfo> {
  @override
  final Iterable<Type> types = const [FileInfo, _$FileInfo];

  @override
  final String wireName = r'FileInfo';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FileInfo object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.path != null) {
      yield r'path';
      yield serializers.serialize(
        object.path,
        specifiedType: const FullType(String),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.isTextFile != null) {
      yield r'isTextFile';
      yield serializers.serialize(
        object.isTextFile,
        specifiedType: const FullType(bool),
      );
    }
    if (object.isConfigFile != null) {
      yield r'isConfigFile';
      yield serializers.serialize(
        object.isConfigFile,
        specifiedType: const FullType(bool),
      );
    }
    if (object.isDirectory != null) {
      yield r'isDirectory';
      yield serializers.serialize(
        object.isDirectory,
        specifiedType: const FullType(bool),
      );
    }
    if (object.isLog != null) {
      yield r'isLog';
      yield serializers.serialize(
        object.isLog,
        specifiedType: const FullType(bool),
      );
    }
    if (object.isReadable != null) {
      yield r'isReadable';
      yield serializers.serialize(
        object.isReadable,
        specifiedType: const FullType(bool),
      );
    }
    if (object.isWritable != null) {
      yield r'isWritable';
      yield serializers.serialize(
        object.isWritable,
        specifiedType: const FullType(bool),
      );
    }
    if (object.size != null) {
      yield r'size';
      yield serializers.serialize(
        object.size,
        specifiedType: const FullType(int),
      );
    }
    if (object.children != null) {
      yield r'children';
      yield serializers.serialize(
        object.children,
        specifiedType: const FullType.nullable(BuiltList, [FullType(FileInfo)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    FileInfo object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FileInfoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'path':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.path = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'isTextFile':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isTextFile = valueDes;
          break;
        case r'isConfigFile':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isConfigFile = valueDes;
          break;
        case r'isDirectory':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isDirectory = valueDes;
          break;
        case r'isLog':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isLog = valueDes;
          break;
        case r'isReadable':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isReadable = valueDes;
          break;
        case r'isWritable':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isWritable = valueDes;
          break;
        case r'size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.size = valueDes;
          break;
        case r'children':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(FileInfo)]),
          ) as BuiltList<FileInfo>?;
          if (valueDes == null) continue;
          result.children.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FileInfo deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FileInfoBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

