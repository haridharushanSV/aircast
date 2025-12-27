import '../entities/channel_entity.dart';

abstract class IptvRepository {
  Future<List<ChannelEntity>> getChannels();
}
