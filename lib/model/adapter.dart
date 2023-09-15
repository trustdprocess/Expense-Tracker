// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hive/hive.dart';

part 'adapter.g.dart';

@HiveType(typeId: 1)
class Expenditure {
  @HiveField(0)
  String name;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String date;
  Expenditure({
    required this.name,
    required this.amount,
    required this.date,
  });
}
