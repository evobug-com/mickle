import '../network/request.dart';
import '../network/utils.dart';
import '../notifiers/current_connection.dart';
import '../network/request.dart' as request;

void packetUserChangePresence({
  required String presence,
}) {
  CurrentSession().connection!.send(
    request.UserChangePresence(
      requestId: getNewRequestId(),
      presence: presence,
    ).serialize(),
  );
}

void packetUserChangeAvatar({
  required String avatar,
}) {
  CurrentSession().connection!.send(
    request.UserChangeAvatar(
      requestId: getNewRequestId(),
      avatar: avatar,
    ).serialize(),
  );
}

void packetUserChangeStatus({
  required String status,
}) {
  CurrentSession().connection!.send(
    request.UserChangeStatus(
      requestId: getNewRequestId(),
      status: status,
    ).serialize(),
  );
}

void packetUserChangePassword({
  required String oldPassword,
  required String newPassword,
}) {
  CurrentSession().connection!.send(
    request.UserChangePassword(
      requestId: getNewRequestId(),
      oldPassword: oldPassword,
      newPassword: newPassword,
    ).serialize(),
  );
}

void packetUserChangeDisplayName({
  required String displayName,
}) {
  CurrentSession().connection!.send(
    request.UserChangeDisplayName(
      requestId: getNewRequestId(),
      displayName: displayName,
    ).serialize(),
  );
}

void packetChannelMessageCreate({
  required String value,
  required String channelId,
}) {
  CurrentSession().connection!.send(
    request.ChannelMessageCreate(
      requestId: getNewRequestId(),
      channelId: channelId,
      message: value,
      mentions: parseMessageMentions(value),
    ).serialize(),
  );
}

void packetChannelMessageFetch({
  required String channelId,
  required String? lastMessageId,
}) {
  CurrentSession().connection!.send(
    request.ChannelMessageFetch(
      requestId: getNewRequestId(),
      channelId: channelId,
      lastMessageId: lastMessageId,
    ).serialize(),
  );
}

void packetChannelCreate({
  required String name,
  required String? description,
}) {
  CurrentSession().connection!.send(
    request.ChannelCreate(
      requestId: getNewRequestId(),
      name: name,
      serverId: CurrentSession().connection!.serverId,
      description: description
    ).serialize(),
  );
}

void packetChannelDelete({
  required String channelId,
}) {
  CurrentSession().connection!.send(
    request.ChannelDelete(
      requestId: getNewRequestId(),
      channelId: channelId,
    ).serialize(),
  );
}

void packetChannelUpdate({
  required String channelId,
  required String? name,
  required String? description,
}) {
  CurrentSession().connection!.send(
    request.ChannelUpdate(
      requestId: getNewRequestId(),
      channelId: channelId,
      name: name,
      description: description,
    ).serialize(),
  );
}