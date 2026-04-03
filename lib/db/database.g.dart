// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $StoriesTable extends Stories with TableInfo<$StoriesTable, Story> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _childIdMeta =
      const VerificationMeta('childId');
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
      'child_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _storyDateMeta =
      const VerificationMeta('storyDate');
  @override
  late final GeneratedColumn<DateTime> storyDate = GeneratedColumn<DateTime>(
      'story_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bodyTextMeta =
      const VerificationMeta('bodyText');
  @override
  late final GeneratedColumn<String> bodyText = GeneratedColumn<String>(
      'body_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _audioUrlMeta =
      const VerificationMeta('audioUrl');
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
      'audio_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _themeTagsMeta =
      const VerificationMeta('themeTags');
  @override
  late final GeneratedColumn<String> themeTags = GeneratedColumn<String>(
      'theme_tags', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _generationStatusMeta =
      const VerificationMeta('generationStatus');
  @override
  late final GeneratedColumn<String> generationStatus = GeneratedColumn<String>(
      'generation_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _deliveryStatusMeta =
      const VerificationMeta('deliveryStatus');
  @override
  late final GeneratedColumn<String> deliveryStatus = GeneratedColumn<String>(
      'delivery_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _deliveredAtMeta =
      const VerificationMeta('deliveredAt');
  @override
  late final GeneratedColumn<DateTime> deliveredAt = GeneratedColumn<DateTime>(
      'delivered_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _audioDownloadedMeta =
      const VerificationMeta('audioDownloaded');
  @override
  late final GeneratedColumn<bool> audioDownloaded = GeneratedColumn<bool>(
      'audio_downloaded', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("audio_downloaded" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        childId,
        storyDate,
        title,
        bodyText,
        audioUrl,
        themeTags,
        generationStatus,
        deliveryStatus,
        deliveredAt,
        createdAt,
        isFavorite,
        audioDownloaded
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stories';
  @override
  VerificationContext validateIntegrity(Insertable<Story> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(_childIdMeta,
          childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta));
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('story_date')) {
      context.handle(_storyDateMeta,
          storyDate.isAcceptableOrUnknown(data['story_date']!, _storyDateMeta));
    } else if (isInserting) {
      context.missing(_storyDateMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('body_text')) {
      context.handle(_bodyTextMeta,
          bodyText.isAcceptableOrUnknown(data['body_text']!, _bodyTextMeta));
    }
    if (data.containsKey('audio_url')) {
      context.handle(_audioUrlMeta,
          audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta));
    }
    if (data.containsKey('theme_tags')) {
      context.handle(_themeTagsMeta,
          themeTags.isAcceptableOrUnknown(data['theme_tags']!, _themeTagsMeta));
    }
    if (data.containsKey('generation_status')) {
      context.handle(
          _generationStatusMeta,
          generationStatus.isAcceptableOrUnknown(
              data['generation_status']!, _generationStatusMeta));
    }
    if (data.containsKey('delivery_status')) {
      context.handle(
          _deliveryStatusMeta,
          deliveryStatus.isAcceptableOrUnknown(
              data['delivery_status']!, _deliveryStatusMeta));
    }
    if (data.containsKey('delivered_at')) {
      context.handle(
          _deliveredAtMeta,
          deliveredAt.isAcceptableOrUnknown(
              data['delivered_at']!, _deliveredAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('audio_downloaded')) {
      context.handle(
          _audioDownloadedMeta,
          audioDownloaded.isAcceptableOrUnknown(
              data['audio_downloaded']!, _audioDownloadedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Story map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Story(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      childId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}child_id'])!,
      storyDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}story_date'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      bodyText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body_text']),
      audioUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audio_url']),
      themeTags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme_tags']),
      generationStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}generation_status'])!,
      deliveryStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}delivery_status'])!,
      deliveredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}delivered_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      audioDownloaded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}audio_downloaded'])!,
    );
  }

  @override
  $StoriesTable createAlias(String alias) {
    return $StoriesTable(attachedDatabase, alias);
  }
}

class Story extends DataClass implements Insertable<Story> {
  final String id;
  final String childId;
  final DateTime storyDate;
  final String? title;
  final String? bodyText;
  final String? audioUrl;
  final String? themeTags;
  final String generationStatus;
  final String deliveryStatus;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  final bool isFavorite;
  final bool audioDownloaded;
  const Story(
      {required this.id,
      required this.childId,
      required this.storyDate,
      this.title,
      this.bodyText,
      this.audioUrl,
      this.themeTags,
      required this.generationStatus,
      required this.deliveryStatus,
      this.deliveredAt,
      required this.createdAt,
      required this.isFavorite,
      required this.audioDownloaded});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['story_date'] = Variable<DateTime>(storyDate);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || bodyText != null) {
      map['body_text'] = Variable<String>(bodyText);
    }
    if (!nullToAbsent || audioUrl != null) {
      map['audio_url'] = Variable<String>(audioUrl);
    }
    if (!nullToAbsent || themeTags != null) {
      map['theme_tags'] = Variable<String>(themeTags);
    }
    map['generation_status'] = Variable<String>(generationStatus);
    map['delivery_status'] = Variable<String>(deliveryStatus);
    if (!nullToAbsent || deliveredAt != null) {
      map['delivered_at'] = Variable<DateTime>(deliveredAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['audio_downloaded'] = Variable<bool>(audioDownloaded);
    return map;
  }

  StoriesCompanion toCompanion(bool nullToAbsent) {
    return StoriesCompanion(
      id: Value(id),
      childId: Value(childId),
      storyDate: Value(storyDate),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      bodyText: bodyText == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyText),
      audioUrl: audioUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(audioUrl),
      themeTags: themeTags == null && nullToAbsent
          ? const Value.absent()
          : Value(themeTags),
      generationStatus: Value(generationStatus),
      deliveryStatus: Value(deliveryStatus),
      deliveredAt: deliveredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredAt),
      createdAt: Value(createdAt),
      isFavorite: Value(isFavorite),
      audioDownloaded: Value(audioDownloaded),
    );
  }

  factory Story.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Story(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      storyDate: serializer.fromJson<DateTime>(json['storyDate']),
      title: serializer.fromJson<String?>(json['title']),
      bodyText: serializer.fromJson<String?>(json['bodyText']),
      audioUrl: serializer.fromJson<String?>(json['audioUrl']),
      themeTags: serializer.fromJson<String?>(json['themeTags']),
      generationStatus: serializer.fromJson<String>(json['generationStatus']),
      deliveryStatus: serializer.fromJson<String>(json['deliveryStatus']),
      deliveredAt: serializer.fromJson<DateTime?>(json['deliveredAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      audioDownloaded: serializer.fromJson<bool>(json['audioDownloaded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childId': serializer.toJson<String>(childId),
      'storyDate': serializer.toJson<DateTime>(storyDate),
      'title': serializer.toJson<String?>(title),
      'bodyText': serializer.toJson<String?>(bodyText),
      'audioUrl': serializer.toJson<String?>(audioUrl),
      'themeTags': serializer.toJson<String?>(themeTags),
      'generationStatus': serializer.toJson<String>(generationStatus),
      'deliveryStatus': serializer.toJson<String>(deliveryStatus),
      'deliveredAt': serializer.toJson<DateTime?>(deliveredAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'audioDownloaded': serializer.toJson<bool>(audioDownloaded),
    };
  }

  Story copyWith(
          {String? id,
          String? childId,
          DateTime? storyDate,
          Value<String?> title = const Value.absent(),
          Value<String?> bodyText = const Value.absent(),
          Value<String?> audioUrl = const Value.absent(),
          Value<String?> themeTags = const Value.absent(),
          String? generationStatus,
          String? deliveryStatus,
          Value<DateTime?> deliveredAt = const Value.absent(),
          DateTime? createdAt,
          bool? isFavorite,
          bool? audioDownloaded}) =>
      Story(
        id: id ?? this.id,
        childId: childId ?? this.childId,
        storyDate: storyDate ?? this.storyDate,
        title: title.present ? title.value : this.title,
        bodyText: bodyText.present ? bodyText.value : this.bodyText,
        audioUrl: audioUrl.present ? audioUrl.value : this.audioUrl,
        themeTags: themeTags.present ? themeTags.value : this.themeTags,
        generationStatus: generationStatus ?? this.generationStatus,
        deliveryStatus: deliveryStatus ?? this.deliveryStatus,
        deliveredAt: deliveredAt.present ? deliveredAt.value : this.deliveredAt,
        createdAt: createdAt ?? this.createdAt,
        isFavorite: isFavorite ?? this.isFavorite,
        audioDownloaded: audioDownloaded ?? this.audioDownloaded,
      );
  Story copyWithCompanion(StoriesCompanion data) {
    return Story(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      storyDate: data.storyDate.present ? data.storyDate.value : this.storyDate,
      title: data.title.present ? data.title.value : this.title,
      bodyText: data.bodyText.present ? data.bodyText.value : this.bodyText,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      themeTags: data.themeTags.present ? data.themeTags.value : this.themeTags,
      generationStatus: data.generationStatus.present
          ? data.generationStatus.value
          : this.generationStatus,
      deliveryStatus: data.deliveryStatus.present
          ? data.deliveryStatus.value
          : this.deliveryStatus,
      deliveredAt:
          data.deliveredAt.present ? data.deliveredAt.value : this.deliveredAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      audioDownloaded: data.audioDownloaded.present
          ? data.audioDownloaded.value
          : this.audioDownloaded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Story(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('storyDate: $storyDate, ')
          ..write('title: $title, ')
          ..write('bodyText: $bodyText, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('themeTags: $themeTags, ')
          ..write('generationStatus: $generationStatus, ')
          ..write('deliveryStatus: $deliveryStatus, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('audioDownloaded: $audioDownloaded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      childId,
      storyDate,
      title,
      bodyText,
      audioUrl,
      themeTags,
      generationStatus,
      deliveryStatus,
      deliveredAt,
      createdAt,
      isFavorite,
      audioDownloaded);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Story &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.storyDate == this.storyDate &&
          other.title == this.title &&
          other.bodyText == this.bodyText &&
          other.audioUrl == this.audioUrl &&
          other.themeTags == this.themeTags &&
          other.generationStatus == this.generationStatus &&
          other.deliveryStatus == this.deliveryStatus &&
          other.deliveredAt == this.deliveredAt &&
          other.createdAt == this.createdAt &&
          other.isFavorite == this.isFavorite &&
          other.audioDownloaded == this.audioDownloaded);
}

class StoriesCompanion extends UpdateCompanion<Story> {
  final Value<String> id;
  final Value<String> childId;
  final Value<DateTime> storyDate;
  final Value<String?> title;
  final Value<String?> bodyText;
  final Value<String?> audioUrl;
  final Value<String?> themeTags;
  final Value<String> generationStatus;
  final Value<String> deliveryStatus;
  final Value<DateTime?> deliveredAt;
  final Value<DateTime> createdAt;
  final Value<bool> isFavorite;
  final Value<bool> audioDownloaded;
  final Value<int> rowid;
  const StoriesCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.storyDate = const Value.absent(),
    this.title = const Value.absent(),
    this.bodyText = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.themeTags = const Value.absent(),
    this.generationStatus = const Value.absent(),
    this.deliveryStatus = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.audioDownloaded = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoriesCompanion.insert({
    required String id,
    required String childId,
    required DateTime storyDate,
    this.title = const Value.absent(),
    this.bodyText = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.themeTags = const Value.absent(),
    this.generationStatus = const Value.absent(),
    this.deliveryStatus = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    required DateTime createdAt,
    this.isFavorite = const Value.absent(),
    this.audioDownloaded = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        childId = Value(childId),
        storyDate = Value(storyDate),
        createdAt = Value(createdAt);
  static Insertable<Story> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<DateTime>? storyDate,
    Expression<String>? title,
    Expression<String>? bodyText,
    Expression<String>? audioUrl,
    Expression<String>? themeTags,
    Expression<String>? generationStatus,
    Expression<String>? deliveryStatus,
    Expression<DateTime>? deliveredAt,
    Expression<DateTime>? createdAt,
    Expression<bool>? isFavorite,
    Expression<bool>? audioDownloaded,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (storyDate != null) 'story_date': storyDate,
      if (title != null) 'title': title,
      if (bodyText != null) 'body_text': bodyText,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (themeTags != null) 'theme_tags': themeTags,
      if (generationStatus != null) 'generation_status': generationStatus,
      if (deliveryStatus != null) 'delivery_status': deliveryStatus,
      if (deliveredAt != null) 'delivered_at': deliveredAt,
      if (createdAt != null) 'created_at': createdAt,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (audioDownloaded != null) 'audio_downloaded': audioDownloaded,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? childId,
      Value<DateTime>? storyDate,
      Value<String?>? title,
      Value<String?>? bodyText,
      Value<String?>? audioUrl,
      Value<String?>? themeTags,
      Value<String>? generationStatus,
      Value<String>? deliveryStatus,
      Value<DateTime?>? deliveredAt,
      Value<DateTime>? createdAt,
      Value<bool>? isFavorite,
      Value<bool>? audioDownloaded,
      Value<int>? rowid}) {
    return StoriesCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      storyDate: storyDate ?? this.storyDate,
      title: title ?? this.title,
      bodyText: bodyText ?? this.bodyText,
      audioUrl: audioUrl ?? this.audioUrl,
      themeTags: themeTags ?? this.themeTags,
      generationStatus: generationStatus ?? this.generationStatus,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      audioDownloaded: audioDownloaded ?? this.audioDownloaded,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (storyDate.present) {
      map['story_date'] = Variable<DateTime>(storyDate.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (bodyText.present) {
      map['body_text'] = Variable<String>(bodyText.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (themeTags.present) {
      map['theme_tags'] = Variable<String>(themeTags.value);
    }
    if (generationStatus.present) {
      map['generation_status'] = Variable<String>(generationStatus.value);
    }
    if (deliveryStatus.present) {
      map['delivery_status'] = Variable<String>(deliveryStatus.value);
    }
    if (deliveredAt.present) {
      map['delivered_at'] = Variable<DateTime>(deliveredAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (audioDownloaded.present) {
      map['audio_downloaded'] = Variable<bool>(audioDownloaded.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoriesCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('storyDate: $storyDate, ')
          ..write('title: $title, ')
          ..write('bodyText: $bodyText, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('themeTags: $themeTags, ')
          ..write('generationStatus: $generationStatus, ')
          ..write('deliveryStatus: $deliveryStatus, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('audioDownloaded: $audioDownloaded, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChildProfilesTable extends ChildProfiles
    with TableInfo<$ChildProfilesTable, ChildProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChildProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _birthdateMeta =
      const VerificationMeta('birthdate');
  @override
  late final GeneratedColumn<String> birthdate = GeneratedColumn<String>(
      'birthdate', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _favoriteAnimalMeta =
      const VerificationMeta('favoriteAnimal');
  @override
  late final GeneratedColumn<String> favoriteAnimal = GeneratedColumn<String>(
      'favorite_animal', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _favoriteColorMeta =
      const VerificationMeta('favoriteColor');
  @override
  late final GeneratedColumn<String> favoriteColor = GeneratedColumn<String>(
      'favorite_color', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _otherInterestsMeta =
      const VerificationMeta('otherInterests');
  @override
  late final GeneratedColumn<String> otherInterests = GeneratedColumn<String>(
      'other_interests', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        birthdate,
        gender,
        favoriteAnimal,
        favoriteColor,
        otherInterests
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'child_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<ChildProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('birthdate')) {
      context.handle(_birthdateMeta,
          birthdate.isAcceptableOrUnknown(data['birthdate']!, _birthdateMeta));
    } else if (isInserting) {
      context.missing(_birthdateMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('favorite_animal')) {
      context.handle(
          _favoriteAnimalMeta,
          favoriteAnimal.isAcceptableOrUnknown(
              data['favorite_animal']!, _favoriteAnimalMeta));
    } else if (isInserting) {
      context.missing(_favoriteAnimalMeta);
    }
    if (data.containsKey('favorite_color')) {
      context.handle(
          _favoriteColorMeta,
          favoriteColor.isAcceptableOrUnknown(
              data['favorite_color']!, _favoriteColorMeta));
    } else if (isInserting) {
      context.missing(_favoriteColorMeta);
    }
    if (data.containsKey('other_interests')) {
      context.handle(
          _otherInterestsMeta,
          otherInterests.isAcceptableOrUnknown(
              data['other_interests']!, _otherInterestsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChildProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChildProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      birthdate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}birthdate'])!,
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender'])!,
      favoriteAnimal: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}favorite_animal'])!,
      favoriteColor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}favorite_color'])!,
      otherInterests: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}other_interests']),
    );
  }

  @override
  $ChildProfilesTable createAlias(String alias) {
    return $ChildProfilesTable(attachedDatabase, alias);
  }
}

class ChildProfile extends DataClass implements Insertable<ChildProfile> {
  final String id;
  final String name;
  final String birthdate;
  final String gender;
  final String favoriteAnimal;
  final String favoriteColor;
  final String? otherInterests;
  const ChildProfile(
      {required this.id,
      required this.name,
      required this.birthdate,
      required this.gender,
      required this.favoriteAnimal,
      required this.favoriteColor,
      this.otherInterests});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['birthdate'] = Variable<String>(birthdate);
    map['gender'] = Variable<String>(gender);
    map['favorite_animal'] = Variable<String>(favoriteAnimal);
    map['favorite_color'] = Variable<String>(favoriteColor);
    if (!nullToAbsent || otherInterests != null) {
      map['other_interests'] = Variable<String>(otherInterests);
    }
    return map;
  }

  ChildProfilesCompanion toCompanion(bool nullToAbsent) {
    return ChildProfilesCompanion(
      id: Value(id),
      name: Value(name),
      birthdate: Value(birthdate),
      gender: Value(gender),
      favoriteAnimal: Value(favoriteAnimal),
      favoriteColor: Value(favoriteColor),
      otherInterests: otherInterests == null && nullToAbsent
          ? const Value.absent()
          : Value(otherInterests),
    );
  }

  factory ChildProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChildProfile(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      birthdate: serializer.fromJson<String>(json['birthdate']),
      gender: serializer.fromJson<String>(json['gender']),
      favoriteAnimal: serializer.fromJson<String>(json['favoriteAnimal']),
      favoriteColor: serializer.fromJson<String>(json['favoriteColor']),
      otherInterests: serializer.fromJson<String?>(json['otherInterests']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'birthdate': serializer.toJson<String>(birthdate),
      'gender': serializer.toJson<String>(gender),
      'favoriteAnimal': serializer.toJson<String>(favoriteAnimal),
      'favoriteColor': serializer.toJson<String>(favoriteColor),
      'otherInterests': serializer.toJson<String?>(otherInterests),
    };
  }

  ChildProfile copyWith(
          {String? id,
          String? name,
          String? birthdate,
          String? gender,
          String? favoriteAnimal,
          String? favoriteColor,
          Value<String?> otherInterests = const Value.absent()}) =>
      ChildProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        birthdate: birthdate ?? this.birthdate,
        gender: gender ?? this.gender,
        favoriteAnimal: favoriteAnimal ?? this.favoriteAnimal,
        favoriteColor: favoriteColor ?? this.favoriteColor,
        otherInterests:
            otherInterests.present ? otherInterests.value : this.otherInterests,
      );
  ChildProfile copyWithCompanion(ChildProfilesCompanion data) {
    return ChildProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      birthdate: data.birthdate.present ? data.birthdate.value : this.birthdate,
      gender: data.gender.present ? data.gender.value : this.gender,
      favoriteAnimal: data.favoriteAnimal.present
          ? data.favoriteAnimal.value
          : this.favoriteAnimal,
      favoriteColor: data.favoriteColor.present
          ? data.favoriteColor.value
          : this.favoriteColor,
      otherInterests: data.otherInterests.present
          ? data.otherInterests.value
          : this.otherInterests,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChildProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthdate: $birthdate, ')
          ..write('gender: $gender, ')
          ..write('favoriteAnimal: $favoriteAnimal, ')
          ..write('favoriteColor: $favoriteColor, ')
          ..write('otherInterests: $otherInterests')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, birthdate, gender, favoriteAnimal,
      favoriteColor, otherInterests);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChildProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.birthdate == this.birthdate &&
          other.gender == this.gender &&
          other.favoriteAnimal == this.favoriteAnimal &&
          other.favoriteColor == this.favoriteColor &&
          other.otherInterests == this.otherInterests);
}

class ChildProfilesCompanion extends UpdateCompanion<ChildProfile> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> birthdate;
  final Value<String> gender;
  final Value<String> favoriteAnimal;
  final Value<String> favoriteColor;
  final Value<String?> otherInterests;
  final Value<int> rowid;
  const ChildProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthdate = const Value.absent(),
    this.gender = const Value.absent(),
    this.favoriteAnimal = const Value.absent(),
    this.favoriteColor = const Value.absent(),
    this.otherInterests = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChildProfilesCompanion.insert({
    required String id,
    required String name,
    required String birthdate,
    required String gender,
    required String favoriteAnimal,
    required String favoriteColor,
    this.otherInterests = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        birthdate = Value(birthdate),
        gender = Value(gender),
        favoriteAnimal = Value(favoriteAnimal),
        favoriteColor = Value(favoriteColor);
  static Insertable<ChildProfile> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? birthdate,
    Expression<String>? gender,
    Expression<String>? favoriteAnimal,
    Expression<String>? favoriteColor,
    Expression<String>? otherInterests,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (birthdate != null) 'birthdate': birthdate,
      if (gender != null) 'gender': gender,
      if (favoriteAnimal != null) 'favorite_animal': favoriteAnimal,
      if (favoriteColor != null) 'favorite_color': favoriteColor,
      if (otherInterests != null) 'other_interests': otherInterests,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChildProfilesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? birthdate,
      Value<String>? gender,
      Value<String>? favoriteAnimal,
      Value<String>? favoriteColor,
      Value<String?>? otherInterests,
      Value<int>? rowid}) {
    return ChildProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      birthdate: birthdate ?? this.birthdate,
      gender: gender ?? this.gender,
      favoriteAnimal: favoriteAnimal ?? this.favoriteAnimal,
      favoriteColor: favoriteColor ?? this.favoriteColor,
      otherInterests: otherInterests ?? this.otherInterests,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (birthdate.present) {
      map['birthdate'] = Variable<String>(birthdate.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (favoriteAnimal.present) {
      map['favorite_animal'] = Variable<String>(favoriteAnimal.value);
    }
    if (favoriteColor.present) {
      map['favorite_color'] = Variable<String>(favoriteColor.value);
    }
    if (otherInterests.present) {
      map['other_interests'] = Variable<String>(otherInterests.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChildProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthdate: $birthdate, ')
          ..write('gender: $gender, ')
          ..write('favoriteAnimal: $favoriteAnimal, ')
          ..write('favoriteColor: $favoriteColor, ')
          ..write('otherInterests: $otherInterests, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTable extends Playlists
    with TableInfo<$PlaylistsTable, Playlist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isAutoMeta = const VerificationMeta('isAuto');
  @override
  late final GeneratedColumn<bool> isAuto = GeneratedColumn<bool>(
      'is_auto', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_auto" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, isAuto];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(Insertable<Playlist> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_auto')) {
      context.handle(_isAutoMeta,
          isAuto.isAcceptableOrUnknown(data['is_auto']!, _isAutoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Playlist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Playlist(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isAuto: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_auto'])!,
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }
}

class Playlist extends DataClass implements Insertable<Playlist> {
  final String id;
  final String name;
  final DateTime createdAt;
  final bool isAuto;
  const Playlist(
      {required this.id,
      required this.name,
      required this.createdAt,
      required this.isAuto});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_auto'] = Variable<bool>(isAuto);
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      isAuto: Value(isAuto),
    );
  }

  factory Playlist.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Playlist(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isAuto: serializer.fromJson<bool>(json['isAuto']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isAuto': serializer.toJson<bool>(isAuto),
    };
  }

  Playlist copyWith(
          {String? id, String? name, DateTime? createdAt, bool? isAuto}) =>
      Playlist(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        isAuto: isAuto ?? this.isAuto,
      );
  Playlist copyWithCompanion(PlaylistsCompanion data) {
    return Playlist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isAuto: data.isAuto.present ? data.isAuto.value : this.isAuto,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Playlist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('isAuto: $isAuto')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, isAuto);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Playlist &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.isAuto == this.isAuto);
}

class PlaylistsCompanion extends UpdateCompanion<Playlist> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<bool> isAuto;
  final Value<int> rowid;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isAuto = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    this.isAuto = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<Playlist> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<bool>? isAuto,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (isAuto != null) 'is_auto': isAuto,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<DateTime>? createdAt,
      Value<bool>? isAuto,
      Value<int>? rowid}) {
    return PlaylistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      isAuto: isAuto ?? this.isAuto,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isAuto.present) {
      map['is_auto'] = Variable<bool>(isAuto.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('isAuto: $isAuto, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistStoryEntriesTable extends PlaylistStoryEntries
    with TableInfo<$PlaylistStoryEntriesTable, PlaylistStoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistStoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta =
      const VerificationMeta('playlistId');
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
      'playlist_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _storyIdMeta =
      const VerificationMeta('storyId');
  @override
  late final GeneratedColumn<String> storyId = GeneratedColumn<String>(
      'story_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [playlistId, storyId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_story_entries';
  @override
  VerificationContext validateIntegrity(Insertable<PlaylistStoryEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
          _playlistIdMeta,
          playlistId.isAcceptableOrUnknown(
              data['playlist_id']!, _playlistIdMeta));
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('story_id')) {
      context.handle(_storyIdMeta,
          storyId.isAcceptableOrUnknown(data['story_id']!, _storyIdMeta));
    } else if (isInserting) {
      context.missing(_storyIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, storyId};
  @override
  PlaylistStoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistStoryEntry(
      playlistId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}playlist_id'])!,
      storyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}story_id'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
    );
  }

  @override
  $PlaylistStoryEntriesTable createAlias(String alias) {
    return $PlaylistStoryEntriesTable(attachedDatabase, alias);
  }
}

class PlaylistStoryEntry extends DataClass
    implements Insertable<PlaylistStoryEntry> {
  final String playlistId;
  final String storyId;
  final int position;
  const PlaylistStoryEntry(
      {required this.playlistId,
      required this.storyId,
      required this.position});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['story_id'] = Variable<String>(storyId);
    map['position'] = Variable<int>(position);
    return map;
  }

  PlaylistStoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return PlaylistStoryEntriesCompanion(
      playlistId: Value(playlistId),
      storyId: Value(storyId),
      position: Value(position),
    );
  }

  factory PlaylistStoryEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistStoryEntry(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      storyId: serializer.fromJson<String>(json['storyId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'storyId': serializer.toJson<String>(storyId),
      'position': serializer.toJson<int>(position),
    };
  }

  PlaylistStoryEntry copyWith(
          {String? playlistId, String? storyId, int? position}) =>
      PlaylistStoryEntry(
        playlistId: playlistId ?? this.playlistId,
        storyId: storyId ?? this.storyId,
        position: position ?? this.position,
      );
  PlaylistStoryEntry copyWithCompanion(PlaylistStoryEntriesCompanion data) {
    return PlaylistStoryEntry(
      playlistId:
          data.playlistId.present ? data.playlistId.value : this.playlistId,
      storyId: data.storyId.present ? data.storyId.value : this.storyId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistStoryEntry(')
          ..write('playlistId: $playlistId, ')
          ..write('storyId: $storyId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, storyId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistStoryEntry &&
          other.playlistId == this.playlistId &&
          other.storyId == this.storyId &&
          other.position == this.position);
}

class PlaylistStoryEntriesCompanion
    extends UpdateCompanion<PlaylistStoryEntry> {
  final Value<String> playlistId;
  final Value<String> storyId;
  final Value<int> position;
  final Value<int> rowid;
  const PlaylistStoryEntriesCompanion({
    this.playlistId = const Value.absent(),
    this.storyId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistStoryEntriesCompanion.insert({
    required String playlistId,
    required String storyId,
    required int position,
    this.rowid = const Value.absent(),
  })  : playlistId = Value(playlistId),
        storyId = Value(storyId),
        position = Value(position);
  static Insertable<PlaylistStoryEntry> custom({
    Expression<String>? playlistId,
    Expression<String>? storyId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (storyId != null) 'story_id': storyId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistStoryEntriesCompanion copyWith(
      {Value<String>? playlistId,
      Value<String>? storyId,
      Value<int>? position,
      Value<int>? rowid}) {
    return PlaylistStoryEntriesCompanion(
      playlistId: playlistId ?? this.playlistId,
      storyId: storyId ?? this.storyId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (storyId.present) {
      map['story_id'] = Variable<String>(storyId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistStoryEntriesCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('storyId: $storyId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingActionsTable extends PendingActions
    with TableInfo<$PendingActionsTable, PendingAction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _actionTypeMeta =
      const VerificationMeta('actionType');
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
      'action_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, actionType, payload, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_actions';
  @override
  VerificationContext validateIntegrity(Insertable<PendingAction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('action_type')) {
      context.handle(
          _actionTypeMeta,
          actionType.isAcceptableOrUnknown(
              data['action_type']!, _actionTypeMeta));
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingAction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingAction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      actionType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_type'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PendingActionsTable createAlias(String alias) {
    return $PendingActionsTable(attachedDatabase, alias);
  }
}

class PendingAction extends DataClass implements Insertable<PendingAction> {
  final int id;
  final String actionType;
  final String payload;
  final DateTime createdAt;
  const PendingAction(
      {required this.id,
      required this.actionType,
      required this.payload,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['action_type'] = Variable<String>(actionType);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingActionsCompanion toCompanion(bool nullToAbsent) {
    return PendingActionsCompanion(
      id: Value(id),
      actionType: Value(actionType),
      payload: Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory PendingAction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingAction(
      id: serializer.fromJson<int>(json['id']),
      actionType: serializer.fromJson<String>(json['actionType']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'actionType': serializer.toJson<String>(actionType),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingAction copyWith(
          {int? id,
          String? actionType,
          String? payload,
          DateTime? createdAt}) =>
      PendingAction(
        id: id ?? this.id,
        actionType: actionType ?? this.actionType,
        payload: payload ?? this.payload,
        createdAt: createdAt ?? this.createdAt,
      );
  PendingAction copyWithCompanion(PendingActionsCompanion data) {
    return PendingAction(
      id: data.id.present ? data.id.value : this.id,
      actionType:
          data.actionType.present ? data.actionType.value : this.actionType,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingAction(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, actionType, payload, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingAction &&
          other.id == this.id &&
          other.actionType == this.actionType &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class PendingActionsCompanion extends UpdateCompanion<PendingAction> {
  final Value<int> id;
  final Value<String> actionType;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  const PendingActionsCompanion({
    this.id = const Value.absent(),
    this.actionType = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PendingActionsCompanion.insert({
    this.id = const Value.absent(),
    required String actionType,
    required String payload,
    required DateTime createdAt,
  })  : actionType = Value(actionType),
        payload = Value(payload),
        createdAt = Value(createdAt);
  static Insertable<PendingAction> custom({
    Expression<int>? id,
    Expression<String>? actionType,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actionType != null) 'action_type': actionType,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PendingActionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? actionType,
      Value<String>? payload,
      Value<DateTime>? createdAt}) {
    return PendingActionsCompanion(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingActionsCompanion(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StoriesTable stories = $StoriesTable(this);
  late final $ChildProfilesTable childProfiles = $ChildProfilesTable(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $PlaylistStoryEntriesTable playlistStoryEntries =
      $PlaylistStoryEntriesTable(this);
  late final $PendingActionsTable pendingActions = $PendingActionsTable(this);
  late final StoryDao storyDao = StoryDao(this as AppDatabase);
  late final PlaylistDao playlistDao = PlaylistDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [stories, childProfiles, playlists, playlistStoryEntries, pendingActions];
}

typedef $$StoriesTableCreateCompanionBuilder = StoriesCompanion Function({
  required String id,
  required String childId,
  required DateTime storyDate,
  Value<String?> title,
  Value<String?> bodyText,
  Value<String?> audioUrl,
  Value<String?> themeTags,
  Value<String> generationStatus,
  Value<String> deliveryStatus,
  Value<DateTime?> deliveredAt,
  required DateTime createdAt,
  Value<bool> isFavorite,
  Value<bool> audioDownloaded,
  Value<int> rowid,
});
typedef $$StoriesTableUpdateCompanionBuilder = StoriesCompanion Function({
  Value<String> id,
  Value<String> childId,
  Value<DateTime> storyDate,
  Value<String?> title,
  Value<String?> bodyText,
  Value<String?> audioUrl,
  Value<String?> themeTags,
  Value<String> generationStatus,
  Value<String> deliveryStatus,
  Value<DateTime?> deliveredAt,
  Value<DateTime> createdAt,
  Value<bool> isFavorite,
  Value<bool> audioDownloaded,
  Value<int> rowid,
});

class $$StoriesTableFilterComposer
    extends Composer<_$AppDatabase, $StoriesTable> {
  $$StoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get childId => $composableBuilder(
      column: $table.childId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get storyDate => $composableBuilder(
      column: $table.storyDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bodyText => $composableBuilder(
      column: $table.bodyText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioUrl => $composableBuilder(
      column: $table.audioUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get themeTags => $composableBuilder(
      column: $table.themeTags, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get generationStatus => $composableBuilder(
      column: $table.generationStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deliveryStatus => $composableBuilder(
      column: $table.deliveryStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deliveredAt => $composableBuilder(
      column: $table.deliveredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get audioDownloaded => $composableBuilder(
      column: $table.audioDownloaded,
      builder: (column) => ColumnFilters(column));
}

class $$StoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $StoriesTable> {
  $$StoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get childId => $composableBuilder(
      column: $table.childId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get storyDate => $composableBuilder(
      column: $table.storyDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bodyText => $composableBuilder(
      column: $table.bodyText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioUrl => $composableBuilder(
      column: $table.audioUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get themeTags => $composableBuilder(
      column: $table.themeTags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get generationStatus => $composableBuilder(
      column: $table.generationStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deliveryStatus => $composableBuilder(
      column: $table.deliveryStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deliveredAt => $composableBuilder(
      column: $table.deliveredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get audioDownloaded => $composableBuilder(
      column: $table.audioDownloaded,
      builder: (column) => ColumnOrderings(column));
}

class $$StoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoriesTable> {
  $$StoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<DateTime> get storyDate =>
      $composableBuilder(column: $table.storyDate, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get bodyText =>
      $composableBuilder(column: $table.bodyText, builder: (column) => column);

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<String> get themeTags =>
      $composableBuilder(column: $table.themeTags, builder: (column) => column);

  GeneratedColumn<String> get generationStatus => $composableBuilder(
      column: $table.generationStatus, builder: (column) => column);

  GeneratedColumn<String> get deliveryStatus => $composableBuilder(
      column: $table.deliveryStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get deliveredAt => $composableBuilder(
      column: $table.deliveredAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<bool> get audioDownloaded => $composableBuilder(
      column: $table.audioDownloaded, builder: (column) => column);
}

class $$StoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StoriesTable,
    Story,
    $$StoriesTableFilterComposer,
    $$StoriesTableOrderingComposer,
    $$StoriesTableAnnotationComposer,
    $$StoriesTableCreateCompanionBuilder,
    $$StoriesTableUpdateCompanionBuilder,
    (Story, BaseReferences<_$AppDatabase, $StoriesTable, Story>),
    Story,
    PrefetchHooks Function()> {
  $$StoriesTableTableManager(_$AppDatabase db, $StoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> childId = const Value.absent(),
            Value<DateTime> storyDate = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> bodyText = const Value.absent(),
            Value<String?> audioUrl = const Value.absent(),
            Value<String?> themeTags = const Value.absent(),
            Value<String> generationStatus = const Value.absent(),
            Value<String> deliveryStatus = const Value.absent(),
            Value<DateTime?> deliveredAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> audioDownloaded = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StoriesCompanion(
            id: id,
            childId: childId,
            storyDate: storyDate,
            title: title,
            bodyText: bodyText,
            audioUrl: audioUrl,
            themeTags: themeTags,
            generationStatus: generationStatus,
            deliveryStatus: deliveryStatus,
            deliveredAt: deliveredAt,
            createdAt: createdAt,
            isFavorite: isFavorite,
            audioDownloaded: audioDownloaded,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String childId,
            required DateTime storyDate,
            Value<String?> title = const Value.absent(),
            Value<String?> bodyText = const Value.absent(),
            Value<String?> audioUrl = const Value.absent(),
            Value<String?> themeTags = const Value.absent(),
            Value<String> generationStatus = const Value.absent(),
            Value<String> deliveryStatus = const Value.absent(),
            Value<DateTime?> deliveredAt = const Value.absent(),
            required DateTime createdAt,
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> audioDownloaded = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StoriesCompanion.insert(
            id: id,
            childId: childId,
            storyDate: storyDate,
            title: title,
            bodyText: bodyText,
            audioUrl: audioUrl,
            themeTags: themeTags,
            generationStatus: generationStatus,
            deliveryStatus: deliveryStatus,
            deliveredAt: deliveredAt,
            createdAt: createdAt,
            isFavorite: isFavorite,
            audioDownloaded: audioDownloaded,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StoriesTable,
    Story,
    $$StoriesTableFilterComposer,
    $$StoriesTableOrderingComposer,
    $$StoriesTableAnnotationComposer,
    $$StoriesTableCreateCompanionBuilder,
    $$StoriesTableUpdateCompanionBuilder,
    (Story, BaseReferences<_$AppDatabase, $StoriesTable, Story>),
    Story,
    PrefetchHooks Function()>;
typedef $$ChildProfilesTableCreateCompanionBuilder = ChildProfilesCompanion
    Function({
  required String id,
  required String name,
  required String birthdate,
  required String gender,
  required String favoriteAnimal,
  required String favoriteColor,
  Value<String?> otherInterests,
  Value<int> rowid,
});
typedef $$ChildProfilesTableUpdateCompanionBuilder = ChildProfilesCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> birthdate,
  Value<String> gender,
  Value<String> favoriteAnimal,
  Value<String> favoriteColor,
  Value<String?> otherInterests,
  Value<int> rowid,
});

class $$ChildProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ChildProfilesTable> {
  $$ChildProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get birthdate => $composableBuilder(
      column: $table.birthdate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get favoriteAnimal => $composableBuilder(
      column: $table.favoriteAnimal,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get favoriteColor => $composableBuilder(
      column: $table.favoriteColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get otherInterests => $composableBuilder(
      column: $table.otherInterests,
      builder: (column) => ColumnFilters(column));
}

class $$ChildProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChildProfilesTable> {
  $$ChildProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get birthdate => $composableBuilder(
      column: $table.birthdate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get favoriteAnimal => $composableBuilder(
      column: $table.favoriteAnimal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get favoriteColor => $composableBuilder(
      column: $table.favoriteColor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get otherInterests => $composableBuilder(
      column: $table.otherInterests,
      builder: (column) => ColumnOrderings(column));
}

class $$ChildProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChildProfilesTable> {
  $$ChildProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get birthdate =>
      $composableBuilder(column: $table.birthdate, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get favoriteAnimal => $composableBuilder(
      column: $table.favoriteAnimal, builder: (column) => column);

  GeneratedColumn<String> get favoriteColor => $composableBuilder(
      column: $table.favoriteColor, builder: (column) => column);

  GeneratedColumn<String> get otherInterests => $composableBuilder(
      column: $table.otherInterests, builder: (column) => column);
}

class $$ChildProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChildProfilesTable,
    ChildProfile,
    $$ChildProfilesTableFilterComposer,
    $$ChildProfilesTableOrderingComposer,
    $$ChildProfilesTableAnnotationComposer,
    $$ChildProfilesTableCreateCompanionBuilder,
    $$ChildProfilesTableUpdateCompanionBuilder,
    (
      ChildProfile,
      BaseReferences<_$AppDatabase, $ChildProfilesTable, ChildProfile>
    ),
    ChildProfile,
    PrefetchHooks Function()> {
  $$ChildProfilesTableTableManager(_$AppDatabase db, $ChildProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChildProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChildProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChildProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> birthdate = const Value.absent(),
            Value<String> gender = const Value.absent(),
            Value<String> favoriteAnimal = const Value.absent(),
            Value<String> favoriteColor = const Value.absent(),
            Value<String?> otherInterests = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChildProfilesCompanion(
            id: id,
            name: name,
            birthdate: birthdate,
            gender: gender,
            favoriteAnimal: favoriteAnimal,
            favoriteColor: favoriteColor,
            otherInterests: otherInterests,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String birthdate,
            required String gender,
            required String favoriteAnimal,
            required String favoriteColor,
            Value<String?> otherInterests = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChildProfilesCompanion.insert(
            id: id,
            name: name,
            birthdate: birthdate,
            gender: gender,
            favoriteAnimal: favoriteAnimal,
            favoriteColor: favoriteColor,
            otherInterests: otherInterests,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChildProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChildProfilesTable,
    ChildProfile,
    $$ChildProfilesTableFilterComposer,
    $$ChildProfilesTableOrderingComposer,
    $$ChildProfilesTableAnnotationComposer,
    $$ChildProfilesTableCreateCompanionBuilder,
    $$ChildProfilesTableUpdateCompanionBuilder,
    (
      ChildProfile,
      BaseReferences<_$AppDatabase, $ChildProfilesTable, ChildProfile>
    ),
    ChildProfile,
    PrefetchHooks Function()>;
typedef $$PlaylistsTableCreateCompanionBuilder = PlaylistsCompanion Function({
  required String id,
  required String name,
  required DateTime createdAt,
  Value<bool> isAuto,
  Value<int> rowid,
});
typedef $$PlaylistsTableUpdateCompanionBuilder = PlaylistsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<DateTime> createdAt,
  Value<bool> isAuto,
  Value<int> rowid,
});

class $$PlaylistsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAuto => $composableBuilder(
      column: $table.isAuto, builder: (column) => ColumnFilters(column));
}

class $$PlaylistsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAuto => $composableBuilder(
      column: $table.isAuto, builder: (column) => ColumnOrderings(column));
}

class $$PlaylistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isAuto =>
      $composableBuilder(column: $table.isAuto, builder: (column) => column);
}

class $$PlaylistsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlaylistsTable,
    Playlist,
    $$PlaylistsTableFilterComposer,
    $$PlaylistsTableOrderingComposer,
    $$PlaylistsTableAnnotationComposer,
    $$PlaylistsTableCreateCompanionBuilder,
    $$PlaylistsTableUpdateCompanionBuilder,
    (Playlist, BaseReferences<_$AppDatabase, $PlaylistsTable, Playlist>),
    Playlist,
    PrefetchHooks Function()> {
  $$PlaylistsTableTableManager(_$AppDatabase db, $PlaylistsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isAuto = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistsCompanion(
            id: id,
            name: name,
            createdAt: createdAt,
            isAuto: isAuto,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required DateTime createdAt,
            Value<bool> isAuto = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistsCompanion.insert(
            id: id,
            name: name,
            createdAt: createdAt,
            isAuto: isAuto,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlaylistsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlaylistsTable,
    Playlist,
    $$PlaylistsTableFilterComposer,
    $$PlaylistsTableOrderingComposer,
    $$PlaylistsTableAnnotationComposer,
    $$PlaylistsTableCreateCompanionBuilder,
    $$PlaylistsTableUpdateCompanionBuilder,
    (Playlist, BaseReferences<_$AppDatabase, $PlaylistsTable, Playlist>),
    Playlist,
    PrefetchHooks Function()>;
typedef $$PlaylistStoryEntriesTableCreateCompanionBuilder
    = PlaylistStoryEntriesCompanion Function({
  required String playlistId,
  required String storyId,
  required int position,
  Value<int> rowid,
});
typedef $$PlaylistStoryEntriesTableUpdateCompanionBuilder
    = PlaylistStoryEntriesCompanion Function({
  Value<String> playlistId,
  Value<String> storyId,
  Value<int> position,
  Value<int> rowid,
});

class $$PlaylistStoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistStoryEntriesTable> {
  $$PlaylistStoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get playlistId => $composableBuilder(
      column: $table.playlistId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storyId => $composableBuilder(
      column: $table.storyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));
}

class $$PlaylistStoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistStoryEntriesTable> {
  $$PlaylistStoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get playlistId => $composableBuilder(
      column: $table.playlistId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storyId => $composableBuilder(
      column: $table.storyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));
}

class $$PlaylistStoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistStoryEntriesTable> {
  $$PlaylistStoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get playlistId => $composableBuilder(
      column: $table.playlistId, builder: (column) => column);

  GeneratedColumn<String> get storyId =>
      $composableBuilder(column: $table.storyId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$PlaylistStoryEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlaylistStoryEntriesTable,
    PlaylistStoryEntry,
    $$PlaylistStoryEntriesTableFilterComposer,
    $$PlaylistStoryEntriesTableOrderingComposer,
    $$PlaylistStoryEntriesTableAnnotationComposer,
    $$PlaylistStoryEntriesTableCreateCompanionBuilder,
    $$PlaylistStoryEntriesTableUpdateCompanionBuilder,
    (
      PlaylistStoryEntry,
      BaseReferences<_$AppDatabase, $PlaylistStoryEntriesTable,
          PlaylistStoryEntry>
    ),
    PlaylistStoryEntry,
    PrefetchHooks Function()> {
  $$PlaylistStoryEntriesTableTableManager(
      _$AppDatabase db, $PlaylistStoryEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistStoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistStoryEntriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistStoryEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> playlistId = const Value.absent(),
            Value<String> storyId = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistStoryEntriesCompanion(
            playlistId: playlistId,
            storyId: storyId,
            position: position,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String playlistId,
            required String storyId,
            required int position,
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistStoryEntriesCompanion.insert(
            playlistId: playlistId,
            storyId: storyId,
            position: position,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlaylistStoryEntriesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $PlaylistStoryEntriesTable,
        PlaylistStoryEntry,
        $$PlaylistStoryEntriesTableFilterComposer,
        $$PlaylistStoryEntriesTableOrderingComposer,
        $$PlaylistStoryEntriesTableAnnotationComposer,
        $$PlaylistStoryEntriesTableCreateCompanionBuilder,
        $$PlaylistStoryEntriesTableUpdateCompanionBuilder,
        (
          PlaylistStoryEntry,
          BaseReferences<_$AppDatabase, $PlaylistStoryEntriesTable,
              PlaylistStoryEntry>
        ),
        PlaylistStoryEntry,
        PrefetchHooks Function()>;
typedef $$PendingActionsTableCreateCompanionBuilder = PendingActionsCompanion
    Function({
  Value<int> id,
  required String actionType,
  required String payload,
  required DateTime createdAt,
});
typedef $$PendingActionsTableUpdateCompanionBuilder = PendingActionsCompanion
    Function({
  Value<int> id,
  Value<String> actionType,
  Value<String> payload,
  Value<DateTime> createdAt,
});

class $$PendingActionsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingActionsTable> {
  $$PendingActionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PendingActionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingActionsTable> {
  $$PendingActionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PendingActionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingActionsTable> {
  $$PendingActionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PendingActionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PendingActionsTable,
    PendingAction,
    $$PendingActionsTableFilterComposer,
    $$PendingActionsTableOrderingComposer,
    $$PendingActionsTableAnnotationComposer,
    $$PendingActionsTableCreateCompanionBuilder,
    $$PendingActionsTableUpdateCompanionBuilder,
    (
      PendingAction,
      BaseReferences<_$AppDatabase, $PendingActionsTable, PendingAction>
    ),
    PendingAction,
    PrefetchHooks Function()> {
  $$PendingActionsTableTableManager(
      _$AppDatabase db, $PendingActionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingActionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingActionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingActionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> actionType = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PendingActionsCompanion(
            id: id,
            actionType: actionType,
            payload: payload,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String actionType,
            required String payload,
            required DateTime createdAt,
          }) =>
              PendingActionsCompanion.insert(
            id: id,
            actionType: actionType,
            payload: payload,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PendingActionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PendingActionsTable,
    PendingAction,
    $$PendingActionsTableFilterComposer,
    $$PendingActionsTableOrderingComposer,
    $$PendingActionsTableAnnotationComposer,
    $$PendingActionsTableCreateCompanionBuilder,
    $$PendingActionsTableUpdateCompanionBuilder,
    (
      PendingAction,
      BaseReferences<_$AppDatabase, $PendingActionsTable, PendingAction>
    ),
    PendingAction,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StoriesTableTableManager get stories =>
      $$StoriesTableTableManager(_db, _db.stories);
  $$ChildProfilesTableTableManager get childProfiles =>
      $$ChildProfilesTableTableManager(_db, _db.childProfiles);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db, _db.playlists);
  $$PlaylistStoryEntriesTableTableManager get playlistStoryEntries =>
      $$PlaylistStoryEntriesTableTableManager(_db, _db.playlistStoryEntries);
  $$PendingActionsTableTableManager get pendingActions =>
      $$PendingActionsTableTableManager(_db, _db.pendingActions);
}
