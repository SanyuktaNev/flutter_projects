class LeadStatus {
  final int? id;
  final String name;

  LeadStatus({
    this.id,
    required this.name,
  });

  /// From JSON
  factory LeadStatus.fromJson(Map<String, dynamic> json) {
    return LeadStatus(
      id: json['id'] != null
          ? int.tryParse(json['id'].toString())
          : null,
      name: json['name']?.toString() ?? '',
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
    };
  }

  /// CopyWith (safe updates)
  LeadStatus copyWith({
    int? id,
    String? name,
  }) {
    return LeadStatus(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
