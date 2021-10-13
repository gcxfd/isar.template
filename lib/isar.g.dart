// ignore_for_file: unused_import, implementation_imports

import 'dart:ffi';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:io';
import 'package:isar/isar.dart';
import 'package:isar/src/isar_native.dart';
import 'package:isar/src/query_builder.dart';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;
import 'db.dart';

const _utf8Encoder = Utf8Encoder();

final _schema =
    '[{"name":"Contact","idProperty":"id","properties":[{"name":"id","type":3},{"name":"name","type":5}],"indexes":[],"links":[]}]';

Future<Isar> openIsar(
    {String name = 'isar',
    String? directory,
    int maxSize = 1000000000,
    Uint8List? encryptionKey}) async {
  final path = await _preparePath(directory);
  return openIsarInternal(
      name: name,
      directory: path,
      maxSize: maxSize,
      encryptionKey: encryptionKey,
      schema: _schema,
      getCollections: (isar) {
        final collectionPtrPtr = malloc<Pointer>();
        final propertyOffsetsPtr = malloc<Uint32>(2);
        final propertyOffsets = propertyOffsetsPtr.asTypedList(2);
        final collections = <String, IsarCollection>{};
        nCall(IC.isar_get_collection(isar.ptr, collectionPtrPtr, 0));
        IC.isar_get_property_offsets(
            collectionPtrPtr.value, propertyOffsetsPtr);
        collections['Contact'] = IsarCollectionImpl<Contact>(
          isar: isar,
          adapter: _ContactAdapter(),
          ptr: collectionPtrPtr.value,
          propertyOffsets: propertyOffsets.sublist(0, 2),
          propertyIds: {'id': 0, 'name': 1},
          indexIds: {},
          linkIds: {},
          backlinkIds: {},
          getId: (obj) => obj.id,
          setId: (obj, id) => obj.id = id,
        );
        malloc.free(propertyOffsetsPtr);
        malloc.free(collectionPtrPtr);

        return collections;
      });
}

Future<String> _preparePath(String? path) async {
  if (path == null || p.isRelative(path)) {
    return p.absolute(path ?? '');
  } else {
    return path;
  }
}

class _ContactAdapter extends TypeAdapter<Contact> {
  @override
  int serialize(IsarCollectionImpl<Contact> collection, RawObject rawObj,
      Contact object, List<int> offsets,
      [int? existingBufferSize]) {
    var dynamicSize = 0;
    final value0 = object.id;
    final _id = value0;
    final value1 = object.name;
    final _name = _utf8Encoder.convert(value1);
    dynamicSize += _name.length;
    final size = dynamicSize + 18;

    late int bufferSize;
    if (existingBufferSize != null) {
      if (existingBufferSize < size) {
        malloc.free(rawObj.buffer);
        rawObj.buffer = malloc(size);
        bufferSize = size;
      } else {
        bufferSize = existingBufferSize;
      }
    } else {
      rawObj.buffer = malloc(size);
      bufferSize = size;
    }
    rawObj.buffer_length = size;
    final buffer = rawObj.buffer.asTypedList(size);
    final writer = BinaryWriter(buffer, 18);
    writer.writeLong(offsets[0], _id);
    writer.writeBytes(offsets[1], _name);
    return bufferSize;
  }

  @override
  Contact deserialize(IsarCollectionImpl<Contact> collection,
      BinaryReader reader, List<int> offsets) {
    final object = Contact();
    object.id = reader.readLongOrNull(offsets[0]);
    object.name = reader.readString(offsets[1]);
    return object;
  }

  @override
  P deserializeProperty<P>(BinaryReader reader, int propertyIndex, int offset) {
    switch (propertyIndex) {
      case 0:
        return (reader.readLongOrNull(offset)) as P;
      case 1:
        return (reader.readString(offset)) as P;
      default:
        throw 'Illegal propertyIndex';
    }
  }
}

extension GetCollection on Isar {
  IsarCollection<Contact> get contacts {
    return getCollection('Contact');
  }
}

extension ContactQueryWhereSort on QueryBuilder<Contact, QWhere> {
  QueryBuilder<Contact, QAfterWhere> anyId() {
    return addWhereClause(WhereClause(indexName: 'id'));
  }
}

extension ContactQueryWhere on QueryBuilder<Contact, QWhereClause> {}

extension ContactQueryFilter on QueryBuilder<Contact, QFilterCondition> {
  QueryBuilder<Contact, QAfterFilterCondition> idIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<Contact, QAfterFilterCondition> idEqualTo(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<Contact, QAfterFilterCondition> idGreaterThan(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<Contact, QAfterFilterCondition> idLessThan(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<Contact, QAfterFilterCondition> idBetween(
      int? lower, int? upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'id',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<Contact, QAfterFilterCondition> nameEqualTo(String value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'name',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Contact, QAfterFilterCondition> nameStartsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'name',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Contact, QAfterFilterCondition> nameEndsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'name',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Contact, QAfterFilterCondition> nameContains(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'name',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Contact, QAfterFilterCondition> nameMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'name',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }
}

extension ContactQueryLinks on QueryBuilder<Contact, QFilterCondition> {}

extension ContactQueryWhereSortBy on QueryBuilder<Contact, QSortBy> {
  QueryBuilder<Contact, QAfterSortBy> sortById() {
    return addSortByInternal('id', Sort.Asc);
  }

  QueryBuilder<Contact, QAfterSortBy> sortByIdDesc() {
    return addSortByInternal('id', Sort.Desc);
  }

  QueryBuilder<Contact, QAfterSortBy> sortByName() {
    return addSortByInternal('name', Sort.Asc);
  }

  QueryBuilder<Contact, QAfterSortBy> sortByNameDesc() {
    return addSortByInternal('name', Sort.Desc);
  }
}

extension ContactQueryWhereSortThenBy on QueryBuilder<Contact, QSortThenBy> {
  QueryBuilder<Contact, QAfterSortBy> thenById() {
    return addSortByInternal('id', Sort.Asc);
  }

  QueryBuilder<Contact, QAfterSortBy> thenByIdDesc() {
    return addSortByInternal('id', Sort.Desc);
  }

  QueryBuilder<Contact, QAfterSortBy> thenByName() {
    return addSortByInternal('name', Sort.Asc);
  }

  QueryBuilder<Contact, QAfterSortBy> thenByNameDesc() {
    return addSortByInternal('name', Sort.Desc);
  }
}

extension ContactQueryWhereDistinct on QueryBuilder<Contact, QDistinct> {
  QueryBuilder<Contact, QDistinct> distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<Contact, QDistinct> distinctByName({bool caseSensitive = true}) {
    return addDistinctByInternal('name', caseSensitive: caseSensitive);
  }
}

extension ContactQueryProperty on QueryBuilder<Contact, QQueryProperty> {
  QueryBuilder<int?, QQueryOperations> idProperty() {
    return addPropertyName('id');
  }

  QueryBuilder<String, QQueryOperations> nameProperty() {
    return addPropertyName('name');
  }
}
