import '../../data/models/channel_model.dart';

List<ChannelModel> parseM3U(String data) {
  final lines = data.split('\n');
  final List<ChannelModel> channels = [];

  for (int i = 0; i < lines.length; i++) {
    if (lines[i].startsWith('#EXTINF')) {
      final name = lines[i].split(',').last.trim();

      final logo =
          RegExp(r'tvg-logo="(.*?)"').firstMatch(lines[i])?.group(1) ?? '';

      final group =
          RegExp(r'group-title="(.*?)"').firstMatch(lines[i])?.group(1) ??
              'Others';

      final url = (i + 1 < lines.length) ? lines[i + 1].trim() : '';

      if (url.startsWith('http')) {
        channels.add(
          ChannelModel(
            name: name,
            streamUrl: url,
            category: group,
            logo: logo,
          ),
        );
      }
    }
  }
  return channels;
}
