
import 'package:isar/isar.dart';

// https://github.com/isar/samples/blob/main/quotes/lib/quote.dart

@Collection()
class Contact {
  @Id()
  int? id;

  late String name;
}
