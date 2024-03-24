part of '../common.dart';

class Team {
  String division;
  Map<String, int> quarters;
  Map<String, int> players;
  Team({
    required this.division,
    required this.quarters,
    required this.players,
  });

  factory Team.fromMap(Map item) {
    return Team(
      division: item['division'],
      quarters: Map.from(item['quarters'] ?? {}),
      players: Map.from(item['players'] ?? {}),
    );
  }

  Map<String, dynamic> get map => {
        'division': division,
        'quarters': quarters,
        'players': players,
      };

  void quaterFoulControl({bool isIncrease = true, required int quarter}) {
    int getCurrentFoul = quarters[quarter.toString()]!;

    if (!isIncrease) {
      if (getCurrentFoul != 0) {
        getCurrentFoul--;
        quarters[quarter.toString()] = getCurrentFoul;
        return;
      }
      return;
    }

    getCurrentFoul++;
    quarters[quarter.toString()] = getCurrentFoul;
  }

  void init() {
    players = {};
    quarters = {
      '1': 0,
      '2': 0,
      '3': 0,
      '4': 0,
    };
  }

  void setPlayer({
    required String number,
  }) {
    if (players[number] != null) {
      return;
    }
    players[number] = 0;
  }

  void removePlayer({required String number}) {
    if (players[number] == null) {
      return;
    }
    players.removeWhere((key, value) => key == number);
  }

  void playerFoulControl({
    bool isIncrease = true,
    required String number,
  }) {
    int getCurrentFoul = players[number]!;
    if (!isIncrease) {
      if (getCurrentFoul != 0) {
        getCurrentFoul--;
        players[number] = getCurrentFoul;
        return;
      }
      return;
    }

    getCurrentFoul++;
    players[number] = getCurrentFoul;
  }
}
