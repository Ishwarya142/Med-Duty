import 'profile_share_data.dart';
import '../core/services/profile_link_service.dart';

/// What is being shared through MedDuty's unified share sheet.
class SharePayload {
  final String sheetTitle;
  final String shareText;
  final String? link;
  final String? subject;
  final ProfileShareData? profileData;

  const SharePayload({
    required this.sheetTitle,
    required this.shareText,
    this.link,
    this.subject,
    this.profileData,
  });

  String get copyLink => link ?? shareText;

  factory SharePayload.profile(ProfileShareData data, {String sheetTitle = 'Share Profile'}) {
    return SharePayload(
      sheetTitle: sheetTitle,
      shareText: ProfileLinkService.shareText(data),
      link: ProfileLinkService.publicUrl(data),
      subject: 'MedDuty Profile — ${data.name}',
      profileData: data,
    );
  }

  factory SharePayload.communityPost({
    required String postId,
    required String authorName,
    required String snippet,
  }) {
    final link = ProfileLinkService.communityPostUrl(postId);
    final text = StringBuffer()
      ..writeln('Check out this post on MedDuty')
      ..writeln()
      ..writeln(authorName)
      ..writeln(snippet.trim())
      ..writeln()
      ..write(link);
    return SharePayload(
      sheetTitle: 'Share Post',
      shareText: text.toString(),
      link: link,
      subject: 'MedDuty Community Post',
    );
  }

  factory SharePayload.duty({
    required String title,
    required String hospital,
    required String location,
    String? dutyId,
  }) {
    final id = dutyId ?? title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    final link = 'https://www.medduty.in/duty/${Uri.encodeComponent(id)}';
    final text = StringBuffer()
      ..writeln('Duty opportunity on MedDuty')
      ..writeln()
      ..writeln(title)
      ..writeln(hospital)
      ..writeln(location)
      ..writeln()
      ..write(link);
    return SharePayload(
      sheetTitle: 'Share Duty',
      shareText: text.toString(),
      link: link,
      subject: 'MedDuty Duty — $title',
    );
  }

  factory SharePayload.generic({
    required String sheetTitle,
    required String shareText,
    String? link,
    String? subject,
  }) {
    return SharePayload(
      sheetTitle: sheetTitle,
      shareText: shareText,
      link: link,
      subject: subject,
    );
  }
}
