import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

import '../../domain/entities/channel_entity.dart';

class PlayerScreen extends StatefulWidget {
  final ChannelEntity channel;
  const PlayerScreen({super.key, required this.channel});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  Player? _player;
  VideoController? _videoController;
  VlcPlayerController? _vlcController;

  bool _useVlc = false;
  bool _loading = true;
  bool _showControls = true;

  /// Screen size toggle
  BoxFit _fit = BoxFit.contain;

  Timer? _fallbackTimer;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startMediaKit();
    _autoHideControls();
  }

  // ---------------- MEDIA_KIT FIRST ----------------

  void _startMediaKit() {
    _player = Player(
      configuration: const PlayerConfiguration(
        bufferSize: 32 * 1024 * 1024,
      ),
    );

    _videoController = VideoController(_player!);

    _player!.open(
      Media(
        widget.channel.streamUrl,
        httpHeaders: const {
          'User-Agent': 'VLC/3.0.20 LibVLC/3.0.20',
          'Accept': '*/*',
        },
      ),
      play: true,
    );

    _fallbackTimer = Timer(const Duration(seconds: 5), () {
      if (!(_player?.state.playing ?? false)) {
        _switchToVlc();
      }
    });

    _player!.stream.playing.listen((playing) {
      if (playing && mounted) {
        setState(() => _loading = false);
      }
    });

    _player!.stream.error.listen((_) => _switchToVlc());
  }

  // ---------------- VLC FALLBACK ----------------

  void _switchToVlc() {
    if (_useVlc) return;

    _fallbackTimer?.cancel();
    _player?.dispose();

    final controller = VlcPlayerController.network(
      widget.channel.streamUrl,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(1500),
        ]),
      ),
    );

    setState(() {
      _vlcController = controller;
      _useVlc = true;
      _loading = false;
    });
  }

  // ---------------- CONTROLS ----------------

  void _autoHideControls() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _autoHideControls();
  }

  void _toggleFit() {
    setState(() {
      _fit = _fit == BoxFit.contain ? BoxFit.cover : BoxFit.contain;
    });
  }

  void _togglePlayPause() {
    if (_useVlc) return; // VLC auto-plays (no pause control)
    final playing = _player?.state.playing ?? false;
    playing ? _player?.pause() : _player?.play();
    _autoHideControls();
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _hideTimer?.cancel();
    _player?.dispose();
    _vlcController?.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // 🎥 VIDEO
            Positioned.fill(
              child: Center(
                child: _useVlc
                    ? (_vlcController == null
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Stack(
                            children: [
                              VlcPlayer(
                                controller: _vlcController!,
                                aspectRatio: 16 / 9,
                              ),
                              // 🚫 BLOCK VLC CONTROLS TOUCH
                              IgnorePointer(
                                ignoring: true,
                                child: Container(color: Colors.transparent),
                              ),
                            ],
                          ))
                    : (_videoController == null
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Video(
                            controller: _videoController!,
                            fit: _fit,
                          )),
              ),
            ),

            // 🔝 TOP BAR
            if (_showControls)
              SafeArea(
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black87, Colors.transparent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.channel.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _fit == BoxFit.contain
                              ? Icons.fit_screen
                              : Icons.fullscreen,
                          color: Colors.white,
                        ),
                        onPressed: _toggleFit,
                      ),
                    ],
                  ),
                ),
              ),

            // ⏯ CENTER PLAY / PAUSE (MEDIA_KIT ONLY)
            if (_showControls && !_loading && !_useVlc)
              Center(
                child: GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      (_player?.state.playing ?? false)
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
