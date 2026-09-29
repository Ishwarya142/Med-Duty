import '../../models/profile_share_data.dart';

/// Central profile URL / deep-link abstraction.
/// Replace [productionBaseUrl] when production links are ready.
class ProfileLinkService {
  ProfileLinkService._();

  static const productionBaseUrl = 'https://www.medduty.in';

  static String deepLink(ProfileShareData data) {
    return 'medduty://profile/${data.type.name}/${data.id}';
  }

  static String publicUrl(ProfileShareData data) {
    return '$productionBaseUrl/profile/${data.type.name}/${data.id}';
  }

  static String communityPostUrl(String postId) {
    final encoded = Uri.encodeComponent(postId);
    return '$productionBaseUrl/community/post/$encoded';
  }

  static String qrPayload(ProfileShareData data) => publicUrl(data);

  static String shareText(ProfileShareData data) {
    final buffer = StringBuffer()
      ..writeln('MedDuty Profile')
      ..writeln()
      ..writeln(data.name);
    if (data.title != null && data.title!.trim().isNotEmpty) {
      buffer.writeln(data.title!.trim());
    }
    if (data.location != null && data.location!.trim().isNotEmpty) {
      buffer.writeln(data.location!.trim());
    }
    buffer
      ..writeln()
      ..writeln('View profile:')
      ..write(publicUrl(data));
    return buffer.toString();
  }

  static String slugFromName(String name) {
    return name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  static ProfileLinkParseResult? parse(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    final deep = RegExp(r'^medduty://profile/(user|hospital)/([^/?#]+)', caseSensitive: false);
    final deepMatch = deep.firstMatch(value);
    if (deepMatch != null) {
      return ProfileLinkParseResult(
        type: deepMatch.group(1)!.toLowerCase() == 'hospital'
            ? ProfileShareType.hospital
            : ProfileShareType.user,
        id: Uri.decodeComponent(deepMatch.group(2)!),
      );
    }

    final web = RegExp(
      r'^https?://(www\.)?medduty\.in/profile/(user|hospital)/([^/?#]+)',
      caseSensitive: false,
    );
    final webMatch = web.firstMatch(value);
    if (webMatch != null) {
      return ProfileLinkParseResult(
        type: webMatch.group(2)!.toLowerCase() == 'hospital'
            ? ProfileShareType.hospital
            : ProfileShareType.user,
        id: Uri.decodeComponent(webMatch.group(3)!),
      );
    }

    return null;
  }
}
