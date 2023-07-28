class SavedRoll {
  String description;
  int numberOfDice;
  int dieSize;
  String symbol;
  int bonus;

  SavedRoll(this.description, this.numberOfDice, this.dieSize, this.symbol,
      this.bonus);

  Map toJson() => {
        'description': description,
        'numberOfDice': numberOfDice,
        'dieSize': dieSize,
        'symbol': symbol,
        'bonus': bonus
      };

  factory SavedRoll.fromJson(dynamic json) => SavedRoll(
      json['description'] as String,
      json['numberOfDice'] as int,
      json['dieSize'] as int,
      json['symbol'] as String,
      json['bonus'] as int);
}
