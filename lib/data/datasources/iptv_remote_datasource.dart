import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/m3u_parser.dart';
import '../models/channel_model.dart';
import 'package:flutter/foundation.dart';

abstract class IptvRemoteDataSource {
  Future<List<ChannelModel>> fetchChannels();
}

class IptvRemoteDataSourceImpl implements IptvRemoteDataSource {
  final Dio dio;
  static const _cacheKey = 'iptv_channels_cache';

  IptvRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ChannelModel>> fetchChannels() async {
    final prefs = await SharedPreferences.getInstance();

    // 1️⃣ Load cached channels instantly
    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      final List decoded = jsonDecode(cached);
      return decoded
          .map((e) => ChannelModel(
                name: e['name'],
                streamUrl: e['url'],
                category: e['category'],
                logo: e['logo'],
              ))
          .toList();
    }

    // 2️⃣ Fetch playlist
    final response = await dio.get(
      'https://iptv-org.github.io/iptv/index.m3u',
      options: Options(
        headers: kIsWeb
            ? null // ❌ DO NOT set User-Agent on web
            : {'User-Agent': 'Mozilla/5.0'}, // ✅ mobile only
      ),
    );

    // ✅ Parse DIRECTLY (NO compute)
    final channels = parseM3U(response.data as String);

    // 3️⃣ Cache result
    prefs.setString(
      _cacheKey,
      jsonEncode(channels
          .map((c) => {
                'name': c.name,
                'url': c.streamUrl,
                'category': c.category,
                'logo': c.logo,
              })
          .toList()),
    );

    return channels;
  }
}
