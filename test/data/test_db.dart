import 'package:drift/native.dart';
import 'package:finance_hub/data/db/app_database.dart';

/// Banco em memória com relógio controlável.
AppDatabase memoryDb({DateTime Function()? clock}) => AppDatabase(NativeDatabase.memory(), clock: clock);
