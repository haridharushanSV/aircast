class ChannelEntity {
  final String name;
  final String streamUrl;
  final String category;
  final String logo;
  final String language;

  ChannelEntity({
    required this.name,
    required this.streamUrl,
    required this.category,
    required this.logo,
    required this.language, // ✅ REQUIRED
  });
}
