import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/stage_ref.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/app_user.dart';
import '../../courses/application/courses_providers.dart';
import '../../courses/domain/course.dart';
import '../../students/application/students_providers.dart';
import '../../students/domain/student.dart';
import '../data/import_templates.dart';
import '../data/import_writer.dart';
import '../data/spreadsheet_reader.dart';
import '../domain/import_models.dart';
import '../domain/import_parsers.dart';

final importWriterProvider = Provider<ImportWriter>((ref) => ImportWriter(ref.watch(firestoreProvider)));

final class ImportState {
  const ImportState({
    this.updateExisting = false,
    this.defaultStage,
    this.defaultSemester = 1,
    this.fileName,
    this.preview,
    this.loading = false,
    this.saving = false,
    this.fileProblem,
    this.error,
    this.result,
    this.problemsOnly = false,
  });

  final bool updateExisting;
  final StageRef? defaultStage;
  final int defaultSemester;
  final String? fileName;
  final ImportPreview<Object?>? preview;
  final bool loading;
  final bool saving;
  final FileProblem? fileProblem;
  final Object? error;
  final ImportWriteResult? result;
  final bool problemsOnly;

  ImportState copyWith({
    bool? updateExisting,
    StageRef? Function()? defaultStage,
    int? defaultSemester,
    String? Function()? fileName,
    ImportPreview<Object?>? Function()? preview,
    bool? loading,
    bool? saving,
    FileProblem? Function()? fileProblem,
    Object? Function()? error,
    ImportWriteResult? Function()? result,
    bool? problemsOnly,
  }) =>
      ImportState(
        updateExisting: updateExisting ?? this.updateExisting,
        defaultStage: defaultStage != null ? defaultStage() : this.defaultStage,
        defaultSemester: defaultSemester ?? this.defaultSemester,
        fileName: fileName != null ? fileName() : this.fileName,
        preview: preview != null ? preview() : this.preview,
        loading: loading ?? this.loading,
        saving: saving ?? this.saving,
        fileProblem: fileProblem != null ? fileProblem() : this.fileProblem,
        error: error != null ? error() : this.error,
        result: result != null ? result() : this.result,
        problemsOnly: problemsOnly ?? this.problemsOnly,
      );
}

/// Drives one import tab: read file → preview (with duplicates detected
/// against the database) → save.
class ImportController extends Notifier<ImportState> {
  ImportController(this.kind);

  final ImportKind kind;

  SheetTable? _table;
  Map<String, Object>? _existing;

  @override
  ImportState build() => const ImportState();

  Uint8List template() => ImportTemplates.build(kind);

  Future<void> loadFile(Uint8List bytes, String fileName) async {
    state = state.copyWith(
      fileName: () => fileName,
      loading: true,
      preview: () => null,
      fileProblem: () => null,
      error: () => null,
      result: () => null,
    );
    try {
      _table = SpreadsheetReader.read(bytes, fileName);
      _existing = await _fetchExisting();
      _reparse();
    } on SpreadsheetException catch (e) {
      _table = null;
      state = state.copyWith(fileProblem: () => e.problem);
    } catch (e) {
      _table = null;
      state = state.copyWith(error: () => e);
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  void setUpdateExisting(bool value) {
    state = state.copyWith(updateExisting: value);
    _reparse();
  }

  void setDefaultStage(StageRef? stage) {
    state = state.copyWith(defaultStage: () => stage);
    _reparse();
  }

  void setDefaultSemester(int semester) {
    state = state.copyWith(defaultSemester: semester);
    _reparse();
  }

  void setProblemsOnly(bool value) => state = state.copyWith(problemsOnly: value);

  Future<void> commit() async {
    final preview = state.preview;
    if (preview == null || !preview.canCommit || state.saving) return;
    state = state.copyWith(saving: true, error: () => null);
    try {
      final result = await ref.read(importWriterProvider).commit(preview, actor: ref.read(signedInUserProvider).id);
      _table = null;
      _existing = null;
      state = state.copyWith(result: () => result, preview: () => null, fileName: () => null);
    } catch (e) {
      state = state.copyWith(error: () => e);
    } finally {
      state = state.copyWith(saving: false);
    }
  }

  void _reparse() {
    final table = _table;
    final existing = _existing;
    if (table == null || existing == null) return;
    final perms = ref.read(permissionsProvider);
    final user = ref.read(signedInUserProvider);
    final options = ImportOptions(
      updateExisting: state.updateExisting,
      defaultStage: state.defaultStage,
      defaultSemester: state.defaultSemester,
      allowedStageIds: perms.isAdmin ? null : user.stageScopes.toSet(),
      canEditAdmins: perms.isSuperAdmin,
    );
    final ImportPreview<Object?> preview = switch (kind) {
      ImportKind.students => parseStudents(table, existing: existing.cast<String, Student>(), options: options),
      ImportKind.teachers => parseTeachers(table, existing: existing.cast<String, AppUser>(), options: options),
      ImportKind.courses => parseCourses(table, existing: existing.cast<String, Course>(), options: options),
    };
    state = state.copyWith(preview: () => preview);
  }

  Future<Map<String, Object>> _fetchExisting() async {
    final perms = ref.read(permissionsProvider);
    return switch (kind) {
      ImportKind.students => await ref
          .read(studentsRepositoryProvider)
          .fetchByStages(perms.isAdmin ? null : ref.read(signedInUserProvider).stageScopes),
      ImportKind.teachers => {
          for (final u in await ref.read(usersRepositoryProvider).fetchAll()) u.id: u,
        },
      ImportKind.courses => await ref.read(coursesRepositoryProvider).fetchAll(),
    };
  }
}

final importControllerProvider =
    NotifierProvider.autoDispose.family<ImportController, ImportState, ImportKind>(ImportController.new);
