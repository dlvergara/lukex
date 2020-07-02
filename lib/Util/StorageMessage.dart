class StorageMessage {
  String value;
  String date;

  StorageMessage(this.value, this.date);

  Map toJson() =>
      {
        'date': date,
        'value': value,
      };
}