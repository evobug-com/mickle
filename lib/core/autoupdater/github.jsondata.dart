import 'package:json_annotation/json_annotation.dart';

part 'github.jsondata.g.dart';

@JsonSerializable()
class GithubRelease {
  @JsonKey(name: "url")
  final String url;

  @JsonKey(name: "html_url")
  final String htmlUrl;

  @JsonKey(name: "assets_url")
  final String assetsUrl;

  @JsonKey(name: "upload_url")
  final String uploadUrl;

  @JsonKey(name: "tarball_url")
  final String? tarballUrl;

  @JsonKey(name: "zipball_url")
  final String? zipballUrl;

  @JsonKey(name: "id")
  final int id;

  @JsonKey(name: "node_id")
  final String nodeId;

  @JsonKey(name: "tag_name")
  final String tagName;

  @JsonKey(name: "target_commitish")
  final String targetCommitish;

  @JsonKey(name: "name")
  final String? name;

  @JsonKey(name: "body")
  final String? body;

  @JsonKey(name: "draft")
  final bool draft;

  @JsonKey(name: "prerelease")
  final bool prerelease;

  @JsonKey(name: "created_at")
  final String createdAt;

  @JsonKey(name: "published_at")
  final String? publishedAt;

  @JsonKey(name: "assets")
  final List<GithubReleaseAsset> assets;

  @JsonKey(name: "body_html")
  final String? bodyHtml;

  @JsonKey(name: "body_text")
  final String? bodyText;

  @JsonKey(name: "mentions_count")
  final int? mentionsCount;

  @JsonKey(name: "discussion_url")
  final String? discussionUrl;

  factory GithubRelease.fromJson(Map<String, dynamic> json) => _$GithubReleaseFromJson(json);
  Map<String, dynamic> toJson() => _$GithubReleaseToJson(this);


  GithubRelease({
      required this.url,
      required this.htmlUrl,
      required this.assetsUrl,
      required this.uploadUrl,
      this.tarballUrl,
      this.zipballUrl,
      required this.id,
      required this.nodeId,
      required this.tagName,
      required this.targetCommitish,
      this.name,
      this.body,
      required this.draft,
      required this.prerelease,
      required this.createdAt,
      this.publishedAt,
      required this.assets,
      this.bodyHtml,
      this.bodyText,
      this.mentionsCount,
      this.discussionUrl});

  @override
  String toString() {
    return 'GithubRelease{url: $url, htmlUrl: $htmlUrl, assetsUrl: $assetsUrl, uploadUrl: $uploadUrl, tarballUrl: $tarballUrl, zipballUrl: $zipballUrl, id: $id, nodeId: $nodeId, tagName: $tagName, targetCommitish: $targetCommitish, name: $name, body: $body, draft: $draft, prerelease: $prerelease, createdAt: $createdAt, publishedAt: $publishedAt, assets: $assets, bodyHtml: $bodyHtml, bodyText: $bodyText, mentionsCount: $mentionsCount, discussionUrl: $discussionUrl}';
  }
}

@JsonSerializable()
class GithubReleaseAsset {

  @JsonKey(name: "url")
  final String url;

  @JsonKey(name: "browser_download_url")
  final String browserDownloadUrl;

  @JsonKey(name: "id")
  final int id;

  @JsonKey(name: "node_id")
  final String nodeId;

  @JsonKey(name: "name")
  final String name;

  @JsonKey(name: "label")
  final String? label;

  @JsonKey(name: "state")
  final String state;

  @JsonKey(name: "content_type")
  final String contentType;

  @JsonKey(name: "size")
  final int size;

  @JsonKey(name: "download_count")
  final int downloadCount;

  @JsonKey(name: "created_at")
  final String createdAt;

  @JsonKey(name: "updated_at")
  final String updatedAt;

  factory GithubReleaseAsset.fromJson(Map<String, dynamic> json) => _$GithubReleaseAssetFromJson(json);
  Map<String, dynamic> toJson() => _$GithubReleaseAssetToJson(this);

  GithubReleaseAsset({
      required this.url,
      required this.browserDownloadUrl,
      required this.id,
      required this.nodeId,
      required this.name,
      this.label,
      required this.state,
      required this.contentType,
      required this.size,
      required this.downloadCount,
      required this.createdAt,
      required this.updatedAt});

  @override
  String toString() {
    return 'GithubReleaseAsset{url: $url, browserDownloadUrl: $browserDownloadUrl, id: $id, nodeId: $nodeId, name: $name, label: $label, state: $state, contentType: $contentType, size: $size, downloadCount: $downloadCount, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

// @JsonKey(name: "uploader")
// final GithubUser? uploader;
}