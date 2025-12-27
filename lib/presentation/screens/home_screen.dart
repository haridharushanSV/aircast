import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/entities/channel_entity.dart';
import '../providers/iptv_providers.dart';
import 'player_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  String searchQuery = '';
  Timer? _debounce;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // ✅ Show disclaimer on every app open
    _showDisclaimer();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  // ---------------- DISCLAIMER ----------------

  void _showDisclaimer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          // Auto close after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          });

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            titlePadding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Disclaimer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            content: const Text(
              'This application does not host or own any content.\n\n'
              'All live TV streams are provided by publicly available sources.\n\n'
              'The developer is not responsible for the content you watch.\n'
              'You are watching at your own risk.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          );
        },
      );
    });
  }

  // ---------------- HELPERS ----------------

  String _getQuality(String text) {
    text = text.toLowerCase();
    if (text.contains('4k')) return '4K';
    if (text.contains('1080') || text.contains('fhd')) return 'FHD';
    if (text.contains('hd') || text.contains('720')) return 'HD';
    return 'SD';
  }

  Color _qualityColor(String q) {
    switch (q) {
      case '4K':
        return Colors.purple;
      case 'FHD':
        return Colors.green;
      case 'HD':
        return Colors.blue;
      default:
        return const Color.fromARGB(255, 245, 180, 2);
    }
  }

  bool _isTamil(ChannelEntity c) {
    return c.language.toLowerCase() == 'tam';
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final channelsAsync = ref.watch(channelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // ☀️ Light background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Image.asset(
              'assets/icons/applogo.png',
              height: 28,
              width: 28,
            ),
            const SizedBox(width: 10),
            const Text(
              'Air Cast',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Tamil'),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Search channels...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 300), () {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // ---------------- TAB CONTENT ----------------

      body: channelsAsync.when(
        data: (channels) {
          final filtered = channels
              .where(
                (c) => c.name.toLowerCase().contains(searchQuery),
              )
              .toList();

          final tamilChannels = filtered.where(_isTamil).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(filtered),
              _buildList(tamilChannels),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load channels')),
      ),
    );
  }

  // ---------------- CHANNEL LIST ----------------

  Widget _buildList(List<ChannelEntity> list) {
    if (list.isEmpty) {
      return const Center(child: Text('No channels found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final c = list[i];
        final quality = _getQuality(c.name + c.streamUrl);

        return Card(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            leading: CachedNetworkImage(
              imageUrl: c.logo,
              width: 48,
              height: 48,
              placeholder: (_, __) => const Icon(Icons.tv, size: 36),
              errorWidget: (_, __, ___) => const Icon(Icons.tv, size: 36),
            ),
         title: Text(
              c.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            subtitle: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _qualityColor(quality),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    quality,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                    const SizedBox(width: 8),
    Text(
      c.category,
      style: const TextStyle(
        color: Color.fromARGB(255, 94, 92, 92), // ✅ category color
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),)
              ],
            ),
            trailing: const Icon(Icons.play_circle_fill, size: 30),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlayerScreen(channel: c),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

