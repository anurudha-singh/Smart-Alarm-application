import 'package:get_it/get_it.dart';
import 'repository/alarm_repository.dart';

final sl = GetIt.instance;

void setupLocator() {
  sl.registerLazySingleton<AlarmRepository>(() => AlarmRepository());
}
