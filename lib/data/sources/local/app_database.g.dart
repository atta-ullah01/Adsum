// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileImageMeta = const VerificationMeta(
    'profileImage',
  );
  @override
  late final GeneratedColumn<String> profileImage = GeneratedColumn<String>(
    'profile_image',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _universityIdMeta = const VerificationMeta(
    'universityId',
  );
  @override
  late final GeneratedColumn<String> universityId = GeneratedColumn<String>(
    'university_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _homeHostelIdMeta = const VerificationMeta(
    'homeHostelId',
  );
  @override
  late final GeneratedColumn<String> homeHostelId = GeneratedColumn<String>(
    'home_hostel_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultSectionMeta = const VerificationMeta(
    'defaultSection',
  );
  @override
  late final GeneratedColumn<String> defaultSection = GeneratedColumn<String>(
    'default_section',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('A'),
  );
  static const VerificationMeta _settingsJsonMeta = const VerificationMeta(
    'settingsJson',
  );
  @override
  late final GeneratedColumn<String> settingsJson = GeneratedColumn<String>(
    'settings_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    email,
    fullName,
    profileImage,
    universityId,
    homeHostelId,
    defaultSection,
    settingsJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('profile_image')) {
      context.handle(
        _profileImageMeta,
        profileImage.isAcceptableOrUnknown(
          data['profile_image']!,
          _profileImageMeta,
        ),
      );
    }
    if (data.containsKey('university_id')) {
      context.handle(
        _universityIdMeta,
        universityId.isAcceptableOrUnknown(
          data['university_id']!,
          _universityIdMeta,
        ),
      );
    }
    if (data.containsKey('home_hostel_id')) {
      context.handle(
        _homeHostelIdMeta,
        homeHostelId.isAcceptableOrUnknown(
          data['home_hostel_id']!,
          _homeHostelIdMeta,
        ),
      );
    }
    if (data.containsKey('default_section')) {
      context.handle(
        _defaultSectionMeta,
        defaultSection.isAcceptableOrUnknown(
          data['default_section']!,
          _defaultSectionMeta,
        ),
      );
    }
    if (data.containsKey('settings_json')) {
      context.handle(
        _settingsJsonMeta,
        settingsJson.isAcceptableOrUnknown(
          data['settings_json']!,
          _settingsJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      profileImage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_image'],
      ),
      universityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}university_id'],
      ),
      homeHostelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}home_hostel_id'],
      ),
      defaultSection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_section'],
      )!,
      settingsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String userId;
  final String email;
  final String fullName;
  final String? profileImage;
  final String? universityId;
  final String? homeHostelId;
  final String defaultSection;
  final String settingsJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const User({
    required this.userId,
    required this.email,
    required this.fullName,
    this.profileImage,
    this.universityId,
    this.homeHostelId,
    required this.defaultSection,
    required this.settingsJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['email'] = Variable<String>(email);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || profileImage != null) {
      map['profile_image'] = Variable<String>(profileImage);
    }
    if (!nullToAbsent || universityId != null) {
      map['university_id'] = Variable<String>(universityId);
    }
    if (!nullToAbsent || homeHostelId != null) {
      map['home_hostel_id'] = Variable<String>(homeHostelId);
    }
    map['default_section'] = Variable<String>(defaultSection);
    map['settings_json'] = Variable<String>(settingsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      userId: Value(userId),
      email: Value(email),
      fullName: Value(fullName),
      profileImage: profileImage == null && nullToAbsent
          ? const Value.absent()
          : Value(profileImage),
      universityId: universityId == null && nullToAbsent
          ? const Value.absent()
          : Value(universityId),
      homeHostelId: homeHostelId == null && nullToAbsent
          ? const Value.absent()
          : Value(homeHostelId),
      defaultSection: Value(defaultSection),
      settingsJson: Value(settingsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      userId: serializer.fromJson<String>(json['userId']),
      email: serializer.fromJson<String>(json['email']),
      fullName: serializer.fromJson<String>(json['fullName']),
      profileImage: serializer.fromJson<String?>(json['profileImage']),
      universityId: serializer.fromJson<String?>(json['universityId']),
      homeHostelId: serializer.fromJson<String?>(json['homeHostelId']),
      defaultSection: serializer.fromJson<String>(json['defaultSection']),
      settingsJson: serializer.fromJson<String>(json['settingsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'email': serializer.toJson<String>(email),
      'fullName': serializer.toJson<String>(fullName),
      'profileImage': serializer.toJson<String?>(profileImage),
      'universityId': serializer.toJson<String?>(universityId),
      'homeHostelId': serializer.toJson<String?>(homeHostelId),
      'defaultSection': serializer.toJson<String>(defaultSection),
      'settingsJson': serializer.toJson<String>(settingsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  User copyWith({
    String? userId,
    String? email,
    String? fullName,
    Value<String?> profileImage = const Value.absent(),
    Value<String?> universityId = const Value.absent(),
    Value<String?> homeHostelId = const Value.absent(),
    String? defaultSection,
    String? settingsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => User(
    userId: userId ?? this.userId,
    email: email ?? this.email,
    fullName: fullName ?? this.fullName,
    profileImage: profileImage.present ? profileImage.value : this.profileImage,
    universityId: universityId.present ? universityId.value : this.universityId,
    homeHostelId: homeHostelId.present ? homeHostelId.value : this.homeHostelId,
    defaultSection: defaultSection ?? this.defaultSection,
    settingsJson: settingsJson ?? this.settingsJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      userId: data.userId.present ? data.userId.value : this.userId,
      email: data.email.present ? data.email.value : this.email,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      profileImage: data.profileImage.present
          ? data.profileImage.value
          : this.profileImage,
      universityId: data.universityId.present
          ? data.universityId.value
          : this.universityId,
      homeHostelId: data.homeHostelId.present
          ? data.homeHostelId.value
          : this.homeHostelId,
      defaultSection: data.defaultSection.present
          ? data.defaultSection.value
          : this.defaultSection,
      settingsJson: data.settingsJson.present
          ? data.settingsJson.value
          : this.settingsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('userId: $userId, ')
          ..write('email: $email, ')
          ..write('fullName: $fullName, ')
          ..write('profileImage: $profileImage, ')
          ..write('universityId: $universityId, ')
          ..write('homeHostelId: $homeHostelId, ')
          ..write('defaultSection: $defaultSection, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    email,
    fullName,
    profileImage,
    universityId,
    homeHostelId,
    defaultSection,
    settingsJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.userId == this.userId &&
          other.email == this.email &&
          other.fullName == this.fullName &&
          other.profileImage == this.profileImage &&
          other.universityId == this.universityId &&
          other.homeHostelId == this.homeHostelId &&
          other.defaultSection == this.defaultSection &&
          other.settingsJson == this.settingsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> userId;
  final Value<String> email;
  final Value<String> fullName;
  final Value<String?> profileImage;
  final Value<String?> universityId;
  final Value<String?> homeHostelId;
  final Value<String> defaultSection;
  final Value<String> settingsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.userId = const Value.absent(),
    this.email = const Value.absent(),
    this.fullName = const Value.absent(),
    this.profileImage = const Value.absent(),
    this.universityId = const Value.absent(),
    this.homeHostelId = const Value.absent(),
    this.defaultSection = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String userId,
    required String email,
    required String fullName,
    this.profileImage = const Value.absent(),
    this.universityId = const Value.absent(),
    this.homeHostelId = const Value.absent(),
    this.defaultSection = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       email = Value(email),
       fullName = Value(fullName);
  static Insertable<User> custom({
    Expression<String>? userId,
    Expression<String>? email,
    Expression<String>? fullName,
    Expression<String>? profileImage,
    Expression<String>? universityId,
    Expression<String>? homeHostelId,
    Expression<String>? defaultSection,
    Expression<String>? settingsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (email != null) 'email': email,
      if (fullName != null) 'full_name': fullName,
      if (profileImage != null) 'profile_image': profileImage,
      if (universityId != null) 'university_id': universityId,
      if (homeHostelId != null) 'home_hostel_id': homeHostelId,
      if (defaultSection != null) 'default_section': defaultSection,
      if (settingsJson != null) 'settings_json': settingsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? userId,
    Value<String>? email,
    Value<String>? fullName,
    Value<String?>? profileImage,
    Value<String?>? universityId,
    Value<String?>? homeHostelId,
    Value<String>? defaultSection,
    Value<String>? settingsJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      profileImage: profileImage ?? this.profileImage,
      universityId: universityId ?? this.universityId,
      homeHostelId: homeHostelId ?? this.homeHostelId,
      defaultSection: defaultSection ?? this.defaultSection,
      settingsJson: settingsJson ?? this.settingsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (profileImage.present) {
      map['profile_image'] = Variable<String>(profileImage.value);
    }
    if (universityId.present) {
      map['university_id'] = Variable<String>(universityId.value);
    }
    if (homeHostelId.present) {
      map['home_hostel_id'] = Variable<String>(homeHostelId.value);
    }
    if (defaultSection.present) {
      map['default_section'] = Variable<String>(defaultSection.value);
    }
    if (settingsJson.present) {
      map['settings_json'] = Variable<String>(settingsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('userId: $userId, ')
          ..write('email: $email, ')
          ..write('fullName: $fullName, ')
          ..write('profileImage: $profileImage, ')
          ..write('universityId: $universityId, ')
          ..write('homeHostelId: $homeHostelId, ')
          ..write('defaultSection: $defaultSection, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EnrollmentsTable extends Enrollments
    with TableInfo<$EnrollmentsTable, Enrollment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnrollmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _enrollmentIdMeta = const VerificationMeta(
    'enrollmentId',
  );
  @override
  late final GeneratedColumn<String> enrollmentId = GeneratedColumn<String>(
    'enrollment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseCodeMeta = const VerificationMeta(
    'courseCode',
  );
  @override
  late final GeneratedColumn<String> courseCode = GeneratedColumn<String>(
    'course_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customCourseJsonMeta = const VerificationMeta(
    'customCourseJson',
  );
  @override
  late final GeneratedColumn<String> customCourseJson = GeneratedColumn<String>(
    'custom_course_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sectionMeta = const VerificationMeta(
    'section',
  );
  @override
  late final GeneratedColumn<String> section = GeneratedColumn<String>(
    'section',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('A'),
  );
  static const VerificationMeta _targetAttendanceMeta = const VerificationMeta(
    'targetAttendance',
  );
  @override
  late final GeneratedColumn<double> targetAttendance = GeneratedColumn<double>(
    'target_attendance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(75.0),
  );
  static const VerificationMeta _colorThemeMeta = const VerificationMeta(
    'colorTheme',
  );
  @override
  late final GeneratedColumn<String> colorTheme = GeneratedColumn<String>(
    'color_theme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#6366F1'),
  );
  static const VerificationMeta _statsJsonMeta = const VerificationMeta(
    'statsJson',
  );
  @override
  late final GeneratedColumn<String> statsJson = GeneratedColumn<String>(
    'stats_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(
      '{"total_classes":0,"attended":0,"safe_bunks":0}',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    enrollmentId,
    courseCode,
    customCourseJson,
    section,
    targetAttendance,
    colorTheme,
    statsJson,
    createdAt,
    updatedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'enrollments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Enrollment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('enrollment_id')) {
      context.handle(
        _enrollmentIdMeta,
        enrollmentId.isAcceptableOrUnknown(
          data['enrollment_id']!,
          _enrollmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_enrollmentIdMeta);
    }
    if (data.containsKey('course_code')) {
      context.handle(
        _courseCodeMeta,
        courseCode.isAcceptableOrUnknown(data['course_code']!, _courseCodeMeta),
      );
    }
    if (data.containsKey('custom_course_json')) {
      context.handle(
        _customCourseJsonMeta,
        customCourseJson.isAcceptableOrUnknown(
          data['custom_course_json']!,
          _customCourseJsonMeta,
        ),
      );
    }
    if (data.containsKey('section')) {
      context.handle(
        _sectionMeta,
        section.isAcceptableOrUnknown(data['section']!, _sectionMeta),
      );
    }
    if (data.containsKey('target_attendance')) {
      context.handle(
        _targetAttendanceMeta,
        targetAttendance.isAcceptableOrUnknown(
          data['target_attendance']!,
          _targetAttendanceMeta,
        ),
      );
    }
    if (data.containsKey('color_theme')) {
      context.handle(
        _colorThemeMeta,
        colorTheme.isAcceptableOrUnknown(data['color_theme']!, _colorThemeMeta),
      );
    }
    if (data.containsKey('stats_json')) {
      context.handle(
        _statsJsonMeta,
        statsJson.isAcceptableOrUnknown(data['stats_json']!, _statsJsonMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {enrollmentId};
  @override
  Enrollment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Enrollment(
      enrollmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enrollment_id'],
      )!,
      courseCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_code'],
      ),
      customCourseJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_course_json'],
      ),
      section: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section'],
      )!,
      targetAttendance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_attendance'],
      )!,
      colorTheme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_theme'],
      )!,
      statsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stats_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $EnrollmentsTable createAlias(String alias) {
    return $EnrollmentsTable(attachedDatabase, alias);
  }
}

class Enrollment extends DataClass implements Insertable<Enrollment> {
  final String enrollmentId;
  final String? courseCode;
  final String? customCourseJson;
  final String section;
  final double targetAttendance;
  final String colorTheme;
  final String statsJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  const Enrollment({
    required this.enrollmentId,
    this.courseCode,
    this.customCourseJson,
    required this.section,
    required this.targetAttendance,
    required this.colorTheme,
    required this.statsJson,
    required this.createdAt,
    required this.updatedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['enrollment_id'] = Variable<String>(enrollmentId);
    if (!nullToAbsent || courseCode != null) {
      map['course_code'] = Variable<String>(courseCode);
    }
    if (!nullToAbsent || customCourseJson != null) {
      map['custom_course_json'] = Variable<String>(customCourseJson);
    }
    map['section'] = Variable<String>(section);
    map['target_attendance'] = Variable<double>(targetAttendance);
    map['color_theme'] = Variable<String>(colorTheme);
    map['stats_json'] = Variable<String>(statsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  EnrollmentsCompanion toCompanion(bool nullToAbsent) {
    return EnrollmentsCompanion(
      enrollmentId: Value(enrollmentId),
      courseCode: courseCode == null && nullToAbsent
          ? const Value.absent()
          : Value(courseCode),
      customCourseJson: customCourseJson == null && nullToAbsent
          ? const Value.absent()
          : Value(customCourseJson),
      section: Value(section),
      targetAttendance: Value(targetAttendance),
      colorTheme: Value(colorTheme),
      statsJson: Value(statsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }

  factory Enrollment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Enrollment(
      enrollmentId: serializer.fromJson<String>(json['enrollmentId']),
      courseCode: serializer.fromJson<String?>(json['courseCode']),
      customCourseJson: serializer.fromJson<String?>(json['customCourseJson']),
      section: serializer.fromJson<String>(json['section']),
      targetAttendance: serializer.fromJson<double>(json['targetAttendance']),
      colorTheme: serializer.fromJson<String>(json['colorTheme']),
      statsJson: serializer.fromJson<String>(json['statsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'enrollmentId': serializer.toJson<String>(enrollmentId),
      'courseCode': serializer.toJson<String?>(courseCode),
      'customCourseJson': serializer.toJson<String?>(customCourseJson),
      'section': serializer.toJson<String>(section),
      'targetAttendance': serializer.toJson<double>(targetAttendance),
      'colorTheme': serializer.toJson<String>(colorTheme),
      'statsJson': serializer.toJson<String>(statsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Enrollment copyWith({
    String? enrollmentId,
    Value<String?> courseCode = const Value.absent(),
    Value<String?> customCourseJson = const Value.absent(),
    String? section,
    double? targetAttendance,
    String? colorTheme,
    String? statsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) => Enrollment(
    enrollmentId: enrollmentId ?? this.enrollmentId,
    courseCode: courseCode.present ? courseCode.value : this.courseCode,
    customCourseJson: customCourseJson.present
        ? customCourseJson.value
        : this.customCourseJson,
    section: section ?? this.section,
    targetAttendance: targetAttendance ?? this.targetAttendance,
    colorTheme: colorTheme ?? this.colorTheme,
    statsJson: statsJson ?? this.statsJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
  );
  Enrollment copyWithCompanion(EnrollmentsCompanion data) {
    return Enrollment(
      enrollmentId: data.enrollmentId.present
          ? data.enrollmentId.value
          : this.enrollmentId,
      courseCode: data.courseCode.present
          ? data.courseCode.value
          : this.courseCode,
      customCourseJson: data.customCourseJson.present
          ? data.customCourseJson.value
          : this.customCourseJson,
      section: data.section.present ? data.section.value : this.section,
      targetAttendance: data.targetAttendance.present
          ? data.targetAttendance.value
          : this.targetAttendance,
      colorTheme: data.colorTheme.present
          ? data.colorTheme.value
          : this.colorTheme,
      statsJson: data.statsJson.present ? data.statsJson.value : this.statsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Enrollment(')
          ..write('enrollmentId: $enrollmentId, ')
          ..write('courseCode: $courseCode, ')
          ..write('customCourseJson: $customCourseJson, ')
          ..write('section: $section, ')
          ..write('targetAttendance: $targetAttendance, ')
          ..write('colorTheme: $colorTheme, ')
          ..write('statsJson: $statsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    enrollmentId,
    courseCode,
    customCourseJson,
    section,
    targetAttendance,
    colorTheme,
    statsJson,
    createdAt,
    updatedAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Enrollment &&
          other.enrollmentId == this.enrollmentId &&
          other.courseCode == this.courseCode &&
          other.customCourseJson == this.customCourseJson &&
          other.section == this.section &&
          other.targetAttendance == this.targetAttendance &&
          other.colorTheme == this.colorTheme &&
          other.statsJson == this.statsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced);
}

class EnrollmentsCompanion extends UpdateCompanion<Enrollment> {
  final Value<String> enrollmentId;
  final Value<String?> courseCode;
  final Value<String?> customCourseJson;
  final Value<String> section;
  final Value<double> targetAttendance;
  final Value<String> colorTheme;
  final Value<String> statsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const EnrollmentsCompanion({
    this.enrollmentId = const Value.absent(),
    this.courseCode = const Value.absent(),
    this.customCourseJson = const Value.absent(),
    this.section = const Value.absent(),
    this.targetAttendance = const Value.absent(),
    this.colorTheme = const Value.absent(),
    this.statsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EnrollmentsCompanion.insert({
    required String enrollmentId,
    this.courseCode = const Value.absent(),
    this.customCourseJson = const Value.absent(),
    this.section = const Value.absent(),
    this.targetAttendance = const Value.absent(),
    this.colorTheme = const Value.absent(),
    this.statsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : enrollmentId = Value(enrollmentId);
  static Insertable<Enrollment> custom({
    Expression<String>? enrollmentId,
    Expression<String>? courseCode,
    Expression<String>? customCourseJson,
    Expression<String>? section,
    Expression<double>? targetAttendance,
    Expression<String>? colorTheme,
    Expression<String>? statsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (enrollmentId != null) 'enrollment_id': enrollmentId,
      if (courseCode != null) 'course_code': courseCode,
      if (customCourseJson != null) 'custom_course_json': customCourseJson,
      if (section != null) 'section': section,
      if (targetAttendance != null) 'target_attendance': targetAttendance,
      if (colorTheme != null) 'color_theme': colorTheme,
      if (statsJson != null) 'stats_json': statsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EnrollmentsCompanion copyWith({
    Value<String>? enrollmentId,
    Value<String?>? courseCode,
    Value<String?>? customCourseJson,
    Value<String>? section,
    Value<double>? targetAttendance,
    Value<String>? colorTheme,
    Value<String>? statsJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return EnrollmentsCompanion(
      enrollmentId: enrollmentId ?? this.enrollmentId,
      courseCode: courseCode ?? this.courseCode,
      customCourseJson: customCourseJson ?? this.customCourseJson,
      section: section ?? this.section,
      targetAttendance: targetAttendance ?? this.targetAttendance,
      colorTheme: colorTheme ?? this.colorTheme,
      statsJson: statsJson ?? this.statsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (enrollmentId.present) {
      map['enrollment_id'] = Variable<String>(enrollmentId.value);
    }
    if (courseCode.present) {
      map['course_code'] = Variable<String>(courseCode.value);
    }
    if (customCourseJson.present) {
      map['custom_course_json'] = Variable<String>(customCourseJson.value);
    }
    if (section.present) {
      map['section'] = Variable<String>(section.value);
    }
    if (targetAttendance.present) {
      map['target_attendance'] = Variable<double>(targetAttendance.value);
    }
    if (colorTheme.present) {
      map['color_theme'] = Variable<String>(colorTheme.value);
    }
    if (statsJson.present) {
      map['stats_json'] = Variable<String>(statsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnrollmentsCompanion(')
          ..write('enrollmentId: $enrollmentId, ')
          ..write('courseCode: $courseCode, ')
          ..write('customCourseJson: $customCourseJson, ')
          ..write('section: $section, ')
          ..write('targetAttendance: $targetAttendance, ')
          ..write('colorTheme: $colorTheme, ')
          ..write('statsJson: $statsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfflineQueueTable extends OfflineQueue
    with TableInfo<$OfflineQueueTable, OfflineQueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _actionTypeMeta = const VerificationMeta(
    'actionType',
  );
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
    'action_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta(
    'nextRetryAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
    'next_retry_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    actionType,
    entityType,
    entityId,
    payloadJson,
    status,
    retryCount,
    nextRetryAt,
    lastError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<OfflineQueueItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('action_type')) {
      context.handle(
        _actionTypeMeta,
        actionType.isAcceptableOrUnknown(data['action_type']!, _actionTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(
          data['next_retry_at']!,
          _nextRetryAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineQueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineQueueItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      actionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_type'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_retry_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $OfflineQueueTable createAlias(String alias) {
    return $OfflineQueueTable(attachedDatabase, alias);
  }
}

class OfflineQueueItem extends DataClass
    implements Insertable<OfflineQueueItem> {
  final int id;
  final String actionType;
  final String entityType;
  final String entityId;
  final String payloadJson;
  final String status;
  final int retryCount;
  final DateTime? nextRetryAt;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
  const OfflineQueueItem({
    required this.id,
    required this.actionType,
    required this.entityType,
    required this.entityId,
    required this.payloadJson,
    required this.status,
    required this.retryCount,
    this.nextRetryAt,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['action_type'] = Variable<String>(actionType);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OfflineQueueCompanion toCompanion(bool nullToAbsent) {
    return OfflineQueueCompanion(
      id: Value(id),
      actionType: Value(actionType),
      entityType: Value(entityType),
      entityId: Value(entityId),
      payloadJson: Value(payloadJson),
      status: Value(status),
      retryCount: Value(retryCount),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory OfflineQueueItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineQueueItem(
      id: serializer.fromJson<int>(json['id']),
      actionType: serializer.fromJson<String>(json['actionType']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'actionType': serializer.toJson<String>(actionType),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  OfflineQueueItem copyWith({
    int? id,
    String? actionType,
    String? entityType,
    String? entityId,
    String? payloadJson,
    String? status,
    int? retryCount,
    Value<DateTime?> nextRetryAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => OfflineQueueItem(
    id: id ?? this.id,
    actionType: actionType ?? this.actionType,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    payloadJson: payloadJson ?? this.payloadJson,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  OfflineQueueItem copyWithCompanion(OfflineQueueCompanion data) {
    return OfflineQueueItem(
      id: data.id.present ? data.id.value : this.id,
      actionType: data.actionType.present
          ? data.actionType.value
          : this.actionType,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      nextRetryAt: data.nextRetryAt.present
          ? data.nextRetryAt.value
          : this.nextRetryAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineQueueItem(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    actionType,
    entityType,
    entityId,
    payloadJson,
    status,
    retryCount,
    nextRetryAt,
    lastError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineQueueItem &&
          other.id == this.id &&
          other.actionType == this.actionType &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.payloadJson == this.payloadJson &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.nextRetryAt == this.nextRetryAt &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OfflineQueueCompanion extends UpdateCompanion<OfflineQueueItem> {
  final Value<int> id;
  final Value<String> actionType;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> payloadJson;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<DateTime?> nextRetryAt;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const OfflineQueueCompanion({
    this.id = const Value.absent(),
    this.actionType = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  OfflineQueueCompanion.insert({
    this.id = const Value.absent(),
    required String actionType,
    required String entityType,
    required String entityId,
    required String payloadJson,
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : actionType = Value(actionType),
       entityType = Value(entityType),
       entityId = Value(entityId),
       payloadJson = Value(payloadJson);
  static Insertable<OfflineQueueItem> custom({
    Expression<int>? id,
    Expression<String>? actionType,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? payloadJson,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<DateTime>? nextRetryAt,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actionType != null) 'action_type': actionType,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  OfflineQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? actionType,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? payloadJson,
    Value<String>? status,
    Value<int>? retryCount,
    Value<DateTime?>? nextRetryAt,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return OfflineQueueCompanion(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      payloadJson: payloadJson ?? this.payloadJson,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineQueueCompanion(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMeta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _etagMeta = const VerificationMeta('etag');
  @override
  late final GeneratedColumn<String> etag = GeneratedColumn<String>(
    'etag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [entityType, lastSyncedAt, etag];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMeta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSyncedAtMeta);
    }
    if (data.containsKey('etag')) {
      context.handle(
        _etagMeta,
        etag.isAcceptableOrUnknown(data['etag']!, _etagMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType};
  @override
  SyncMeta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMeta(
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      )!,
      etag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etag'],
      ),
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMeta extends DataClass implements Insertable<SyncMeta> {
  final String entityType;
  final DateTime lastSyncedAt;
  final String? etag;
  const SyncMeta({
    required this.entityType,
    required this.lastSyncedAt,
    this.etag,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    if (!nullToAbsent || etag != null) {
      map['etag'] = Variable<String>(etag);
    }
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      entityType: Value(entityType),
      lastSyncedAt: Value(lastSyncedAt),
      etag: etag == null && nullToAbsent ? const Value.absent() : Value(etag),
    );
  }

  factory SyncMeta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMeta(
      entityType: serializer.fromJson<String>(json['entityType']),
      lastSyncedAt: serializer.fromJson<DateTime>(json['lastSyncedAt']),
      etag: serializer.fromJson<String?>(json['etag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'lastSyncedAt': serializer.toJson<DateTime>(lastSyncedAt),
      'etag': serializer.toJson<String?>(etag),
    };
  }

  SyncMeta copyWith({
    String? entityType,
    DateTime? lastSyncedAt,
    Value<String?> etag = const Value.absent(),
  }) => SyncMeta(
    entityType: entityType ?? this.entityType,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    etag: etag.present ? etag.value : this.etag,
  );
  SyncMeta copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMeta(
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      etag: data.etag.present ? data.etag.value : this.etag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMeta(')
          ..write('entityType: $entityType, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('etag: $etag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entityType, lastSyncedAt, etag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMeta &&
          other.entityType == this.entityType &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.etag == this.etag);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMeta> {
  final Value<String> entityType;
  final Value<DateTime> lastSyncedAt;
  final Value<String?> etag;
  final Value<int> rowid;
  const SyncMetadataCompanion({
    this.entityType = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.etag = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    required String entityType,
    required DateTime lastSyncedAt,
    this.etag = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entityType = Value(entityType),
       lastSyncedAt = Value(lastSyncedAt);
  static Insertable<SyncMeta> custom({
    Expression<String>? entityType,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? etag,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (etag != null) 'etag': etag,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataCompanion copyWith({
    Value<String>? entityType,
    Value<DateTime>? lastSyncedAt,
    Value<String?>? etag,
    Value<int>? rowid,
  }) {
    return SyncMetadataCompanion(
      entityType: entityType ?? this.entityType,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      etag: etag ?? this.etag,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (etag.present) {
      map['etag'] = Variable<String>(etag.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('entityType: $entityType, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('etag: $etag, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $EnrollmentsTable enrollments = $EnrollmentsTable(this);
  late final $OfflineQueueTable offlineQueue = $OfflineQueueTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    enrollments,
    offlineQueue,
    syncMetadata,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String userId,
      required String email,
      required String fullName,
      Value<String?> profileImage,
      Value<String?> universityId,
      Value<String?> homeHostelId,
      Value<String> defaultSection,
      Value<String> settingsJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> userId,
      Value<String> email,
      Value<String> fullName,
      Value<String?> profileImage,
      Value<String?> universityId,
      Value<String?> homeHostelId,
      Value<String> defaultSection,
      Value<String> settingsJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileImage => $composableBuilder(
    column: $table.profileImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get universityId => $composableBuilder(
    column: $table.universityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homeHostelId => $composableBuilder(
    column: $table.homeHostelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultSection => $composableBuilder(
    column: $table.defaultSection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileImage => $composableBuilder(
    column: $table.profileImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get universityId => $composableBuilder(
    column: $table.universityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homeHostelId => $composableBuilder(
    column: $table.homeHostelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultSection => $composableBuilder(
    column: $table.defaultSection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get profileImage => $composableBuilder(
    column: $table.profileImage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get universityId => $composableBuilder(
    column: $table.universityId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get homeHostelId => $composableBuilder(
    column: $table.homeHostelId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultSection => $composableBuilder(
    column: $table.defaultSection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String?> profileImage = const Value.absent(),
                Value<String?> universityId = const Value.absent(),
                Value<String?> homeHostelId = const Value.absent(),
                Value<String> defaultSection = const Value.absent(),
                Value<String> settingsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                userId: userId,
                email: email,
                fullName: fullName,
                profileImage: profileImage,
                universityId: universityId,
                homeHostelId: homeHostelId,
                defaultSection: defaultSection,
                settingsJson: settingsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String email,
                required String fullName,
                Value<String?> profileImage = const Value.absent(),
                Value<String?> universityId = const Value.absent(),
                Value<String?> homeHostelId = const Value.absent(),
                Value<String> defaultSection = const Value.absent(),
                Value<String> settingsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                userId: userId,
                email: email,
                fullName: fullName,
                profileImage: profileImage,
                universityId: universityId,
                homeHostelId: homeHostelId,
                defaultSection: defaultSection,
                settingsJson: settingsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$EnrollmentsTableCreateCompanionBuilder =
    EnrollmentsCompanion Function({
      required String enrollmentId,
      Value<String?> courseCode,
      Value<String?> customCourseJson,
      Value<String> section,
      Value<double> targetAttendance,
      Value<String> colorTheme,
      Value<String> statsJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$EnrollmentsTableUpdateCompanionBuilder =
    EnrollmentsCompanion Function({
      Value<String> enrollmentId,
      Value<String?> courseCode,
      Value<String?> customCourseJson,
      Value<String> section,
      Value<double> targetAttendance,
      Value<String> colorTheme,
      Value<String> statsJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$EnrollmentsTableFilterComposer
    extends Composer<_$AppDatabase, $EnrollmentsTable> {
  $$EnrollmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get enrollmentId => $composableBuilder(
    column: $table.enrollmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseCode => $composableBuilder(
    column: $table.courseCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customCourseJson => $composableBuilder(
    column: $table.customCourseJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get section => $composableBuilder(
    column: $table.section,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetAttendance => $composableBuilder(
    column: $table.targetAttendance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorTheme => $composableBuilder(
    column: $table.colorTheme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statsJson => $composableBuilder(
    column: $table.statsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EnrollmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $EnrollmentsTable> {
  $$EnrollmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get enrollmentId => $composableBuilder(
    column: $table.enrollmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseCode => $composableBuilder(
    column: $table.courseCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customCourseJson => $composableBuilder(
    column: $table.customCourseJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get section => $composableBuilder(
    column: $table.section,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetAttendance => $composableBuilder(
    column: $table.targetAttendance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorTheme => $composableBuilder(
    column: $table.colorTheme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statsJson => $composableBuilder(
    column: $table.statsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EnrollmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnrollmentsTable> {
  $$EnrollmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get enrollmentId => $composableBuilder(
    column: $table.enrollmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get courseCode => $composableBuilder(
    column: $table.courseCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customCourseJson => $composableBuilder(
    column: $table.customCourseJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get section =>
      $composableBuilder(column: $table.section, builder: (column) => column);

  GeneratedColumn<double> get targetAttendance => $composableBuilder(
    column: $table.targetAttendance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get colorTheme => $composableBuilder(
    column: $table.colorTheme,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statsJson =>
      $composableBuilder(column: $table.statsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$EnrollmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnrollmentsTable,
          Enrollment,
          $$EnrollmentsTableFilterComposer,
          $$EnrollmentsTableOrderingComposer,
          $$EnrollmentsTableAnnotationComposer,
          $$EnrollmentsTableCreateCompanionBuilder,
          $$EnrollmentsTableUpdateCompanionBuilder,
          (
            Enrollment,
            BaseReferences<_$AppDatabase, $EnrollmentsTable, Enrollment>,
          ),
          Enrollment,
          PrefetchHooks Function()
        > {
  $$EnrollmentsTableTableManager(_$AppDatabase db, $EnrollmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnrollmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnrollmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnrollmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> enrollmentId = const Value.absent(),
                Value<String?> courseCode = const Value.absent(),
                Value<String?> customCourseJson = const Value.absent(),
                Value<String> section = const Value.absent(),
                Value<double> targetAttendance = const Value.absent(),
                Value<String> colorTheme = const Value.absent(),
                Value<String> statsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnrollmentsCompanion(
                enrollmentId: enrollmentId,
                courseCode: courseCode,
                customCourseJson: customCourseJson,
                section: section,
                targetAttendance: targetAttendance,
                colorTheme: colorTheme,
                statsJson: statsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String enrollmentId,
                Value<String?> courseCode = const Value.absent(),
                Value<String?> customCourseJson = const Value.absent(),
                Value<String> section = const Value.absent(),
                Value<double> targetAttendance = const Value.absent(),
                Value<String> colorTheme = const Value.absent(),
                Value<String> statsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnrollmentsCompanion.insert(
                enrollmentId: enrollmentId,
                courseCode: courseCode,
                customCourseJson: customCourseJson,
                section: section,
                targetAttendance: targetAttendance,
                colorTheme: colorTheme,
                statsJson: statsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EnrollmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnrollmentsTable,
      Enrollment,
      $$EnrollmentsTableFilterComposer,
      $$EnrollmentsTableOrderingComposer,
      $$EnrollmentsTableAnnotationComposer,
      $$EnrollmentsTableCreateCompanionBuilder,
      $$EnrollmentsTableUpdateCompanionBuilder,
      (
        Enrollment,
        BaseReferences<_$AppDatabase, $EnrollmentsTable, Enrollment>,
      ),
      Enrollment,
      PrefetchHooks Function()
    >;
typedef $$OfflineQueueTableCreateCompanionBuilder =
    OfflineQueueCompanion Function({
      Value<int> id,
      required String actionType,
      required String entityType,
      required String entityId,
      required String payloadJson,
      Value<String> status,
      Value<int> retryCount,
      Value<DateTime?> nextRetryAt,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$OfflineQueueTableUpdateCompanionBuilder =
    OfflineQueueCompanion Function({
      Value<int> id,
      Value<String> actionType,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> payloadJson,
      Value<String> status,
      Value<int> retryCount,
      Value<DateTime?> nextRetryAt,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$OfflineQueueTableFilterComposer
    extends Composer<_$AppDatabase, $OfflineQueueTable> {
  $$OfflineQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OfflineQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $OfflineQueueTable> {
  $$OfflineQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OfflineQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfflineQueueTable> {
  $$OfflineQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$OfflineQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OfflineQueueTable,
          OfflineQueueItem,
          $$OfflineQueueTableFilterComposer,
          $$OfflineQueueTableOrderingComposer,
          $$OfflineQueueTableAnnotationComposer,
          $$OfflineQueueTableCreateCompanionBuilder,
          $$OfflineQueueTableUpdateCompanionBuilder,
          (
            OfflineQueueItem,
            BaseReferences<_$AppDatabase, $OfflineQueueTable, OfflineQueueItem>,
          ),
          OfflineQueueItem,
          PrefetchHooks Function()
        > {
  $$OfflineQueueTableTableManager(_$AppDatabase db, $OfflineQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> actionType = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => OfflineQueueCompanion(
                id: id,
                actionType: actionType,
                entityType: entityType,
                entityId: entityId,
                payloadJson: payloadJson,
                status: status,
                retryCount: retryCount,
                nextRetryAt: nextRetryAt,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String actionType,
                required String entityType,
                required String entityId,
                required String payloadJson,
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => OfflineQueueCompanion.insert(
                id: id,
                actionType: actionType,
                entityType: entityType,
                entityId: entityId,
                payloadJson: payloadJson,
                status: status,
                retryCount: retryCount,
                nextRetryAt: nextRetryAt,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OfflineQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OfflineQueueTable,
      OfflineQueueItem,
      $$OfflineQueueTableFilterComposer,
      $$OfflineQueueTableOrderingComposer,
      $$OfflineQueueTableAnnotationComposer,
      $$OfflineQueueTableCreateCompanionBuilder,
      $$OfflineQueueTableUpdateCompanionBuilder,
      (
        OfflineQueueItem,
        BaseReferences<_$AppDatabase, $OfflineQueueTable, OfflineQueueItem>,
      ),
      OfflineQueueItem,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadataTableCreateCompanionBuilder =
    SyncMetadataCompanion Function({
      required String entityType,
      required DateTime lastSyncedAt,
      Value<String?> etag,
      Value<int> rowid,
    });
typedef $$SyncMetadataTableUpdateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<String> entityType,
      Value<DateTime> lastSyncedAt,
      Value<String?> etag,
      Value<int> rowid,
    });

class $$SyncMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get etag =>
      $composableBuilder(column: $table.etag, builder: (column) => column);
}

class $$SyncMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetadataTable,
          SyncMeta,
          $$SyncMetadataTableFilterComposer,
          $$SyncMetadataTableOrderingComposer,
          $$SyncMetadataTableAnnotationComposer,
          $$SyncMetadataTableCreateCompanionBuilder,
          $$SyncMetadataTableUpdateCompanionBuilder,
          (
            SyncMeta,
            BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMeta>,
          ),
          SyncMeta,
          PrefetchHooks Function()
        > {
  $$SyncMetadataTableTableManager(_$AppDatabase db, $SyncMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entityType = const Value.absent(),
                Value<DateTime> lastSyncedAt = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion(
                entityType: entityType,
                lastSyncedAt: lastSyncedAt,
                etag: etag,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityType,
                required DateTime lastSyncedAt,
                Value<String?> etag = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion.insert(
                entityType: entityType,
                lastSyncedAt: lastSyncedAt,
                etag: etag,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetadataTable,
      SyncMeta,
      $$SyncMetadataTableFilterComposer,
      $$SyncMetadataTableOrderingComposer,
      $$SyncMetadataTableAnnotationComposer,
      $$SyncMetadataTableCreateCompanionBuilder,
      $$SyncMetadataTableUpdateCompanionBuilder,
      (SyncMeta, BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMeta>),
      SyncMeta,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$EnrollmentsTableTableManager get enrollments =>
      $$EnrollmentsTableTableManager(_db, _db.enrollments);
  $$OfflineQueueTableTableManager get offlineQueue =>
      $$OfflineQueueTableTableManager(_db, _db.offlineQueue);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
}
