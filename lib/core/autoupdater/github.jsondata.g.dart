// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github.jsondata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GithubRelease _$GithubReleaseFromJson(Map<String, dynamic> json) =>
    GithubRelease(
      url: json['url'] as String,
      htmlUrl: json['html_url'] as String,
      assetsUrl: json['assets_url'] as String,
      uploadUrl: json['upload_url'] as String,
      tarballUrl: json['tarball_url'] as String?,
      zipballUrl: json['zipball_url'] as String?,
      id: (json['id'] as num).toInt(),
      nodeId: json['node_id'] as String,
      tagName: json['tag_name'] as String,
      targetCommitish: json['target_commitish'] as String,
      name: json['name'] as String?,
      body: json['body'] as String?,
      draft: json['draft'] as bool,
      prerelease: json['prerelease'] as bool,
      createdAt: json['created_at'] as String,
      publishedAt: json['published_at'] as String?,
      assets: (json['assets'] as List<dynamic>)
          .map((e) => GithubReleaseAsset.fromJson(e as Map<String, dynamic>))
          .toList(),
      bodyHtml: json['body_html'] as String?,
      bodyText: json['body_text'] as String?,
      mentionsCount: (json['mentions_count'] as num?)?.toInt(),
      discussionUrl: json['discussion_url'] as String?,
    );

Map<String, dynamic> _$GithubReleaseToJson(GithubRelease instance) =>
    <String, dynamic>{
      'url': instance.url,
      'html_url': instance.htmlUrl,
      'assets_url': instance.assetsUrl,
      'upload_url': instance.uploadUrl,
      'tarball_url': instance.tarballUrl,
      'zipball_url': instance.zipballUrl,
      'id': instance.id,
      'node_id': instance.nodeId,
      'tag_name': instance.tagName,
      'target_commitish': instance.targetCommitish,
      'name': instance.name,
      'body': instance.body,
      'draft': instance.draft,
      'prerelease': instance.prerelease,
      'created_at': instance.createdAt,
      'published_at': instance.publishedAt,
      'assets': instance.assets,
      'body_html': instance.bodyHtml,
      'body_text': instance.bodyText,
      'mentions_count': instance.mentionsCount,
      'discussion_url': instance.discussionUrl,
    };

GithubReleaseAsset _$GithubReleaseAssetFromJson(Map<String, dynamic> json) =>
    GithubReleaseAsset(
      url: json['url'] as String,
      browserDownloadUrl: json['browser_download_url'] as String,
      id: (json['id'] as num).toInt(),
      nodeId: json['node_id'] as String,
      name: json['name'] as String,
      label: json['label'] as String?,
      state: json['state'] as String,
      contentType: json['content_type'] as String,
      size: (json['size'] as num).toInt(),
      downloadCount: (json['download_count'] as num).toInt(),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$GithubReleaseAssetToJson(GithubReleaseAsset instance) =>
    <String, dynamic>{
      'url': instance.url,
      'browser_download_url': instance.browserDownloadUrl,
      'id': instance.id,
      'node_id': instance.nodeId,
      'name': instance.name,
      'label': instance.label,
      'state': instance.state,
      'content_type': instance.contentType,
      'size': instance.size,
      'download_count': instance.downloadCount,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
