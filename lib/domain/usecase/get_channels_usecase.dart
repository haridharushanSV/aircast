import '../entities/channel_entity.dart';
import '../repositories/iptv_repository.dart';

class GetChannelsUseCase {
  final IptvRepository repository;

  GetChannelsUseCase(this.repository);

  Future<List<ChannelEntity>> call() {
    return repository.getChannels();
  }
}
