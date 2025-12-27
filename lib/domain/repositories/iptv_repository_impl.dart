import 'package:aircast/data/datasources/iptv_remote_datasource.dart';

import '../../domain/entities/channel_entity.dart';
import '../../domain/repositories/iptv_repository.dart';

class IptvRepositoryImpl implements IptvRepository {
  final IptvRemoteDataSource remote;

  IptvRepositoryImpl(this.remote);

  @override
  Future<List<ChannelEntity>> getChannels() async {
    final models = await remote.fetchChannels();
    return models
        .map(
          (e) => ChannelEntity(
            name: e.name,
            streamUrl: e.streamUrl,
            category: e.category,
            logo: e.logo, language: '',
          ),
        )
        .toList();
  }
}
