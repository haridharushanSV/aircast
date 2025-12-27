import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/channel_entity.dart';

final channelProvider = FutureProvider<List<ChannelEntity>>((ref) async {
  final allUrl = Uri.parse('https://iptv-org.github.io/iptv/index.m3u');
  final tamilUrl =
      Uri.parse('https://iptv-org.github.io/iptv/languages/tam.m3u');

  final allRes = await http.get(allUrl);
  final tamilRes = await http.get(tamilUrl);

  if (allRes.statusCode != 200 || tamilRes.statusCode != 200) {
    throw Exception('Failed to load IPTV playlists');
  }

  final allChannels = _parseM3U(allRes.body, language: 'all');
  final tamilChannels = _parseM3U(tamilRes.body, language: 'tam');

  // 🔹 Merge without duplicates (by stream URL)
  final Map<String, ChannelEntity> merged = {};

  for (final c in allChannels) {
    merged[c.streamUrl] = c;
  }

  for (final c in tamilChannels) {
    merged[c.streamUrl] = c; // overwrite with Tamil language
  }

  final result = merged.values.toList();

  print('TOTAL CHANNELS: ${result.length}');
  print('TAMIL CHANNELS: ${result.where((c) => c.language == "tam").length}');

  return result;
});

/// ---------------- M3U PARSER ----------------

List<ChannelEntity> _parseM3U(
  String data, {
  required String language,
}) {
  final lines = const LineSplitter().convert(data);

  final List<ChannelEntity> channels = [];

  String? name;
  String? logo;

  for (final line in lines) {
    if (line.startsWith('#EXTINF')) {
      final nameMatch = RegExp(r',(.+)$').firstMatch(line);
      name = nameMatch?.group(1)?.trim();

      final logoMatch = RegExp(r'tvg-logo="([^"]+)"').firstMatch(line);
      logo = logoMatch?.group(1);
    } else if (line.startsWith('http')) {
      if (name != null) {
        channels.add(
          ChannelEntity(
            name: name,
            streamUrl: line.trim(),
            category: language == 'tam' ? 'Tamil' : 'General',
            logo: logo ?? '',
            language: language == 'tam' ? 'tam' : 'other',
          ),
        );
      }
      name = null;
      logo = null;
    }
  }

  return channels;
}
