class SavedRoll {
  String description;
  int numberOfDice;
  int dieSize;
  String symbol;
  int bonus;
  String extra;

  SavedRoll(this.description, this.numberOfDice, this.dieSize, this.symbol,
      this.bonus,
      {this.extra = ''});

  Map toJson() => {
        'description': description,
        'numberOfDice': numberOfDice,
        'dieSize': dieSize,
        'symbol': symbol,
        'bonus': bonus,
        'extra': extra
      };

  factory SavedRoll.fromJson(dynamic json) => SavedRoll(
      json['description'] as String,
      json['numberOfDice'] as int,
      json['dieSize'] as int,
      json['symbol'] as String,
      json['bonus'] as int,
      extra: json['extra'] == null ? '' : json['extra'] as String);
}
