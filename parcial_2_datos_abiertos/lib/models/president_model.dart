class President {
  final int id;
  final String name;
  final String? period;
  final String? politicalParty;

  President({required this.id, required this.name, this.period, this.politicalParty});

  factory President.fromJson(Map<String, dynamic> json) {
    return President(
      id: json['id'],
      name: json['name'],
      period: json['period'],
      politicalParty: json['politicalParty'],
    );
  }
}