import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:tako_play/utils/constants.dart';
import 'package:uuid/uuid.dart';
import '../models/anime.dart';
import '../services/request_service.dart';

class AnimeService {
  var uuid = const Uuid();
  Future<AnimeResults> getAnimes(request) async {
    List<Anime> _animeList = [];
    final response = await request;
    dom.Document document = parse(response.body);

    var list = document.getElementsByClassName('items').first.children;

    for (var element in list) {
      var img = element
          .getElementsByClassName('img')
          .first
          .getElementsByTagName('a')
          .first
          .getElementsByTagName('img')
          .first
          .attributes
          .values
          .first;

      var animeUrl = element
          .getElementsByClassName('name')
          .first
          .getElementsByTagName('a')
          .first
          .attributes
          .values
          .first;
      var name = element
          .getElementsByClassName('name')
          .first
          .getElementsByTagName('a')
          .first
          .attributes
          .values
          .last;
      var releasedDate =
          element.getElementsByClassName('released').first.text.trim();

      Anime animeInfo = Anime(
        id: uuid.v4(),
        name: name,
        animeUrl: animeUrl,
        imageUrl: img,
        releasedDate: releasedDate,
      );
      _animeList.add(animeInfo);
    }
    return AnimeResults(animeList: _animeList);
  }

  Future<Anime> fetchAnimeDetails(String path) async {
    List<String> _genre = [];
    List<String>? _epLinks = [];
    final detailResponse =
        await RequestService.create().requestAnimeDetailResponse(path);
    dom.Document detailDoc = parse(detailResponse.body);
    final info = detailDoc.getElementsByClassName('anime_info_body_bg').first;

    final summary = info
        .getElementsByClassName('type')[1]
        .text
        .trim()
        .split('Plot Summary:')
        .last;
    final genres =
        info.getElementsByClassName('type')[2].getElementsByTagName('a');
    for (var gen in genres) {
      _genre.add(gen.text.split(',').last);
    }

    final released = info
        .getElementsByClassName('type')[3]
        .text
        .trim()
        .split('Released:')
        .last;
    final status = info
        .getElementsByClassName('type')[4]
        .getElementsByTagName('a')
        .first
        .text
        .trim();
    final id = detailDoc
        .getElementsByClassName('anime_info_episodes_next')
        .first
        .getElementsByTagName('input')
        .first
        .attributes
        .values
        .elementAt(1);

    final episodesResponse =
        await RequestService.create().requestEpisodesResponse(id);
    dom.Document epDoc = parse(episodesResponse.body);
    final list =
        epDoc.getElementById('episode_related')?.getElementsByTagName('li');

    if (list != null) {
      for (var element in list) {
        final href = element
            .getElementsByTagName('a')
            .first
            .attributes
            .values
            .first
            .trim();
        _epLinks.add(href);
      }
    } else {
      _epLinks = [];
    }

    Anime anime = Anime(
      id: id,
      summary: summary,
      genres: _genre,
      releasedDate: released,
      status: status,
      epLinks: _epLinks.reversed.toList(),
    );

    return anime;
  }

  Future<String> fetchIframeEmbedded(url) async {
    final response =
        await RequestService.create().requestAnimeDetailResponse(url);
    dom.Document document = parse(response.body);
    var embededIframeUrl = document
        .getElementsByClassName('play-video')
        .first
        .getElementsByTagName('iframe')
        .first
        .attributes
        .values
        .first;
    return embededIframeUrl;
  }

  Future<Map<String, String>> fetchCdnStreamLink(url) async {
    final response = await RequestService.create().requestCdnVideoLink(
        url.toString().replaceFirst('streaming.php', 'download'));
    Map<String, String> streamingDatas = {};
    dom.Document doc = parse(response.body);
    final streamingInfo = doc
        .getElementsByClassName('mirror_link')
        .first
        .getElementsByClassName('dowload');

    for (var link in streamingInfo) {
      final url = link.getElementsByTagName('a').first.attributes.values.first;
      final resolutionText = link.getElementsByTagName('a').first.text;
      var resolution =
          resolutionRegExp.firstMatch(resolutionText)!.group(0).toString();

      streamingDatas.putIfAbsent(resolution, () => url);
    }
    return streamingDatas;
  }

  Future<Map<String, String>> getVideoWithResolution(url) async {
    final iframeEmbedded = await fetchIframeEmbedded(url);
    final resolutions = await fetchCdnStreamLink(iframeEmbedded);
    return resolutions;
  }

  Future<AnimeResults> getRecentlyAddedAnimes() async {
    List<Anime> _animeList = [];
    final response =
        await RequestService.create().requestRecentlyAddedResponse();
    dom.Document document = parse(response.body);
    var list = document.getElementsByClassName('items').first.children;

    for (var element in list) {
      var info = element
          .getElementsByClassName('name')
          .first
          .getElementsByTagName('a')
          .first
          .attributes
          .values;
      var img = element
          .getElementsByClassName('img')
          .first
          .getElementsByTagName('a')
          .first
          .getElementsByTagName('img')
          .first
          .attributes
          .values
          .first;

      var name = info.last;
      var animeUrl = info.first;
      var currentEp = element.getElementsByClassName('episode').first.text;
      Anime animeInfo = Anime(
        id: uuid.v4(),
        name: name,
        animeUrl: animeUrl,
        currentEp: currentEp,
        imageUrl: img,
      );
      _animeList.add(animeInfo);
    }
    return AnimeResults(animeList: _animeList);
  }
}
