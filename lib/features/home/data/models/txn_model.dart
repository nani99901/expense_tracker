import 'package:hive/hive.dart';

class TxnModel extends HiveObject {
  String id;
  double amount;
  bool isIncome;
  String category;
  String description;
  int dateMillis;
  String walletId;

  TxnModel({
    required this.id,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.description,
    required this.dateMillis,
    required this.walletId,
  });
}

class TxnModelAdapter extends TypeAdapter<TxnModel> {
  @override
  final int typeId = 2;

  @override
  TxnModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return TxnModel(
      id: fields[0] as String,
      amount: fields[1] as double,
      isIncome: fields[2] as bool,
      category: fields[3] as String,
      description: fields[4] as String,
      dateMillis: fields[5] as int,
      walletId: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TxnModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.isIncome)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.dateMillis)
      ..writeByte(6)
      ..write(obj.walletId);
  }
}
