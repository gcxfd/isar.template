import 'package:isar/isar.dart';
import 'package:rmw/isar.g.dart';
import 'package:rmw/db.dart';

void main(List<String> arguments) async {
  final isar = await openIsar(
      directory:".",
      name:"db"
  );
  final contact = Contact()
      ..name = "My first contact";

  await isar.writeTxn((isar) async {
    isar.contacts.put(contact);
  });

  final allContacts = isar.contacts.where().findAll();

  print(allContacts);
}
