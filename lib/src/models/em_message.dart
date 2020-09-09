import 'package:flutter/material.dart';

// 消息类型
enum EMMessageChatType {
  Chat, // 单聊消息
  GroupChat, // 群聊消息
  ChatRoom, // 聊天室消息
}

// 消息方向
enum EMMessageDirection {
  SEND,  // 发送的消息
  RECEIVE,  // 接收的消息
}

// 消息状态
enum EMMessageStatus {
  CREATE, // 创建
  PROGRESS, // 发送中
  SUCCESS, // 发送成功
  FAIL, // 发送失败
}

// 附件状态
enum EMDownloadStatus {
  PENDING,  // 下载未开始
  DOWNLOADING, // 下载中
  SUCCESS, // 下载成功
  FAILED, // 下载失败
}

/// body类型
enum EMMessageBodyType {
  TXT, // 文字消息
  IMAGE, // 图片消息
  VIDEO, // 视频消息
  LOCATION, // 位置消息
  VOICE, // 音频消息
  FILE, // 文件消息
  CMD, // CMD消息
  CUSTOM, // CUSTOM消息
}

class EMMessage {

  EMMessage({this.body, this.to});

  /// 构造接收的消息
  EMMessage.createReceiveMessage({this.body, this.direction = EMMessageDirection.RECEIVE});

  /// 构造发送的消息
  EMMessage.createSendMessage({this.body, this.direction = EMMessageDirection.SEND, this.to});

  /// 构造发送的文字消息
  EMMessage.createTxtSendMessage({@required String userName, String content = ""}) : this.createSendMessage (
      to:userName,
      body:EMTextMessageBody(content: content)
  );

  /// 构造发送的图片消息
  EMMessage.createImageSendMessage({
    @required String userName,
    @required String filePath,
    String displayName,
    String thumbnailLocalPath,
    bool sendOriginalImage = false,
    int width,
    int height,
  }) : this.createSendMessage (
      to:userName,
      body:EMImageMessageBody(
        localPath: filePath,
        displayName: displayName,
        thumbnailLocalPath: thumbnailLocalPath,
        sendOriginalImage: sendOriginalImage,
        width: width,
        height: height,
      )
  );

  /// 构造发送的视频消息
  EMMessage.createVideoSendMessage({
    @required String userName,
    @required String filePath,
    String displayName,
    int duration,
    String thumbnailLocalPath ,
    int width,
    int height,
  }) : this.createSendMessage (
      to: userName,
      body: EMVideoMessageBody (
        localPath: filePath,
        displayName: displayName,
        duration: duration,
        thumbnailLocalPath: thumbnailLocalPath,
        width: width,
        height: height,
      )
  );

  /// 构造发送的音频消息
  EMMessage.createVoiceSendMessage({
    @required String userName,
    @required String filePath,
    int duration,
    String displayName,
  }) : this.createSendMessage (
      to: userName,
      body: EMVoiceMessageBody(
          localPath: filePath,
          duration: duration,
          displayName: displayName
      )
  );

  /// 构造发送的位置消息
  EMMessage.createLocationSendMessage({
    @required String userName,
    @required double latitude,
    @required double longitude,
    String address
  }) : this.createSendMessage (
      to:userName,
      body:EMLocationMessageBody(
          latitude: latitude,
          longitude: longitude,
          address: address
      )
  );

  /// 构造发送的cmd消息
  EMMessage.createCmdSendMessage({
    @required String userName, @required action
  }) : this.createSendMessage (
      to: userName,
      body:EMCmdMessageBody(
          action: action
      )
  );

  /// 构造发送的自定义消息
  EMMessage.createCustomSendMessage({
    @required String userName, @required event, Map params
  }) : this.createSendMessage (
      to:userName,
      body: EMCustomMessageBody(
          event: event,
          params: params
      )
  );


  // 消息id
  String msgId = DateTime.now().millisecondsSinceEpoch.toString();

  // 消息所属会话id
  String conversationId;

  // 消息发送方
  String from;

  // 消息接收方
  String to;

  // 消息本地时间
  int localTime = DateTime.now().millisecondsSinceEpoch;

  // 消息的服务器时间
  int serverTime = DateTime.now().millisecondsSinceEpoch;

  // 消息是否收到已送达回执
  bool hasDeliverAck = false;

  // 消息是否收到已读回执
  bool hasReadAck = false;

  // 消息类型
  EMMessageChatType chatType = EMMessageChatType.Chat;

  // 消息方向
  EMMessageDirection direction = EMMessageDirection.SEND;

  // 消息状态
  EMMessageStatus status = EMMessageStatus.CREATE;

  // 消息扩展
  Map attributes;
  // msg body
  EMMessageBody body;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from'] = this.from;
    data['to'] = this.to;
    data['body'] = this.body.toJson();
    data['attributes'] = this.attributes;
    data['direction'] = this.direction == EMMessageDirection.SEND ? 'send' : 'rec';
    data['hasReadAck'] = this.hasReadAck;
    data['hasDeliverAck'] = this.hasDeliverAck;
    data['msgId'] = this.msgId;
    data['conversationId'] = this.conversationId;
    data['chatType'] = EMMessage._chatTypeToInt(this.chatType);
    data['localTime'] = this.localTime;
    data['serverTime'] = this.serverTime;
    data['status'] = EMMessage._chatStatusToInt(this.status);

    return data;
  }

  static EMMessage fromJson(Map <String, dynamic> map) {
    EMMessage message = EMMessage();
    message.to = map['to'];
    message.from = map['from'];
    message.body = EMMessage._bodyFromMap(map['body']);
    message.attributes = map['attributes'];
    message.direction = map['direction'] == 'send' ? EMMessageDirection.SEND : EMMessageDirection.RECEIVE;
    message.hasReadAck = map['hasReadAck'];
    message.hasDeliverAck = map['hasDeliverAck'];
    message.msgId = map['msgId'];
    message.conversationId = map['conversationId'];
    message.chatType = EMMessage._chatTypeFromInt(map['chatType']);
    message.localTime = map['localTime'];
    message.serverTime = map['serverTime'];
    message.status = EMMessage._chatStatusFromInt(map['status']);

    return message;
  }

  static int _chatTypeToInt(EMMessageChatType type) {
    if(type == EMMessageChatType.ChatRoom) {
      return 2;
    }else if (type == EMMessageChatType.GroupChat) {
      return 1;
    } else {
      return 0;
    }
  }

  static EMMessageChatType _chatTypeFromInt(int type) {
    if(type == 2) {
      return EMMessageChatType.ChatRoom;
    }else if (type == 1) {
      return EMMessageChatType.GroupChat;
    } else {
      return EMMessageChatType.Chat;
    }
  }

  static int _chatStatusToInt(EMMessageStatus status) {
      if(status == EMMessageStatus.FAIL) {
        return 3;
      }else if (status == EMMessageStatus.SUCCESS) {
        return 2;
      }else if (status == EMMessageStatus.PROGRESS) {
        return 1;
      }else {
        return 0;
      }
  }

  static EMMessageStatus _chatStatusFromInt(int status) {
    if(status == 3) {
      return EMMessageStatus.FAIL;
    }else if (status == 2) {
      return EMMessageStatus.SUCCESS;
    }else if (status == 1) {
      return EMMessageStatus.PROGRESS;
    }else {
      return EMMessageStatus.CREATE;
    }
  }

  static EMMessageBody _bodyFromMap(Map map) {
    EMMessageBody body;
    switch(map['type']) {
      case 'txt':
        body = EMTextMessageBody.fromJson(map: map);
        break;
      case 'img':
        body = EMImageMessageBody.fromJson(map: map);
        break;
      case 'loc':
        body = EMLocationMessageBody.fromJson(map: map);
        break;
      case 'video':
        body = EMVideoMessageBody.fromJson(map: map);
        break;
      case 'voice':
        body = EMVoiceMessageBody.fromJson(map: map);
        break;
      case 'file':
        body = EMFileMessageBody.fromJson(map: map);
        break;
      case 'cmd':
        body = EMCmdMessageBody.fromJson(map: map);
        break;
      case 'custom':
        body = EMCustomMessageBody.fromJson(map: map);
        break;
      default:
    }

    return body;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

// message body
abstract class EMMessageBody{

  EMMessageBody({@required this.type});

  EMMessageBody.fromJson({@required Map map, this.type});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = _bodyTypeToTypeStr();
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }

  String _bodyTypeToTypeStr() {
    switch(this.type) {
      case EMMessageBodyType.TXT:
        return 'txt';
      case EMMessageBodyType.IMAGE:
        return 'img';
      case EMMessageBodyType.LOCATION:
        return 'loc';
      case EMMessageBodyType.VIDEO:
        return 'video';
      case EMMessageBodyType.VOICE:
        return 'voice';
      case EMMessageBodyType.FILE:
        return 'file';
      case EMMessageBodyType.CMD:
        return 'cmd';
      case EMMessageBodyType.CUSTOM:
        return 'custom';
    }
    return '';
  }

  // body 类型
  EMMessageBodyType type;
}

// text body
class EMTextMessageBody extends EMMessageBody {

  EMTextMessageBody({@required this.content}) : super (
      type: EMMessageBodyType.TXT
  );

  EMTextMessageBody.fromJson({Map map}) : super.fromJson(map: map, type: EMMessageBodyType.TXT)
  {
    this.content = map['content'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['content'] = this.content;
    return data;
  }

  String content;
}

//
// location body
class EMLocationMessageBody extends EMMessageBody {

  EMLocationMessageBody({@required this.latitude, @required this.longitude, this.address}) : super (
      type: EMMessageBodyType.LOCATION
  );

  EMLocationMessageBody.fromJson({Map map}) : super.fromJson(map: map, type: EMMessageBodyType.LOCATION) {
    this.latitude = map['latitude'];
    this.longitude = map['longitude'];
    this.address = map['address'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['address'] = this.address;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }

  // 地址
  String address;

  // 经纬度
  double latitude;
  double longitude;
}

class EMFileMessageBody extends EMMessageBody {

  EMFileMessageBody({this.localPath, this.displayName, EMMessageBodyType type = EMMessageBodyType.FILE,}) : super (
      type: type
  );

  EMFileMessageBody.fromJson({Map map, EMMessageBodyType type = EMMessageBodyType.FILE}) : super.fromJson (map: map, type: type)
  {
    this.secret = map['secret'];
    this.remotePath = map['remotePath'];
    this.fileSize = map['fileSize'];
    this.localPath = map['localPath'];
    this.displayName = map['displayName'];
    this.fileStatus = EMFileMessageBody.downloadStatusFromInt(map['fileStatus']);
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['secret'] = this.secret;
    data['remotePath'] = this.remotePath;
    data['fileSize'] = this.fileSize;
    data['localPath'] = this.localPath;
    data['displayName'] = this.displayName;
    data['fileStatus'] = EMFileMessageBody.downloadStatusToInt(this.fileStatus);
    return data;
  }

  // 本地路径
  String localPath;

  // secret
  String secret;

  // 服务器路径
  String remotePath;

  // 附件状态
  EMDownloadStatus fileStatus = EMDownloadStatus.PENDING;

  // 文件大小
  int fileSize;

  // 文件名称
  String displayName;

  static EMDownloadStatus downloadStatusFromInt(int status) {
    if(status == 0) {
      return EMDownloadStatus.DOWNLOADING;
    }else if (status == 1) {
      return EMDownloadStatus.SUCCESS;
    }else if (status == 2) {
      return EMDownloadStatus.FAILED;
    }else {
      return EMDownloadStatus.PENDING;
    }
  }

  static int downloadStatusToInt(EMDownloadStatus status) {
    if(status == EMDownloadStatus.DOWNLOADING) {
      return 0;
    }else if (status == EMDownloadStatus.SUCCESS) {
      return 1;
    }else if (status == EMDownloadStatus.FAILED) {
      return 2;
    }else {
      return 3;
    }
  }

}

// image body
class EMImageMessageBody extends EMFileMessageBody {

  EMImageMessageBody({
    String localPath,
    String displayName,
    this.thumbnailLocalPath,
    this.sendOriginalImage,
    this.width,
    this.height,
  }) : super (
    localPath: localPath,
    displayName: displayName,
    type: EMMessageBodyType.IMAGE,
  );


  EMImageMessageBody.fromJson({Map map}) : super.fromJson(map: map, type: EMMessageBodyType.IMAGE)
  {
    this.thumbnailLocalPath =  map['thumbnailLocalPath'];
    this.thumbnailRemotePath = map['thumbnailRemotePath'];
    this.thumbnailSecret = map['thumbnailSecret'];
    this.sendOriginalImage = map['sendOriginalImage'];
    this.height = map['height'];
    this.width = map['width'];
    this.thumbnailStatus = EMFileMessageBody.downloadStatusFromInt(map['thumbnailStatus']);
  }


  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['thumbnailLocalPath'] = this.thumbnailLocalPath;
    data['thumbnailRemotePath'] = this.thumbnailRemotePath;
    data['thumbnailSecret'] = this.thumbnailSecret;
    data['sendOriginalImage'] = this.sendOriginalImage;
    data['height'] = this.height;
    data['width'] = this.width;
    data['thumbnailStatus'] = EMFileMessageBody.downloadStatusToInt(this.thumbnailStatus);
    return data;
  }

  // 是否是原图
  bool sendOriginalImage = false;

  // 缩略图本地地址
  String thumbnailLocalPath;

  // 缩略图服务器地址
  String thumbnailRemotePath;

  // 缩略图 secret
  String thumbnailSecret;

  // 缩略图状态
  EMDownloadStatus thumbnailStatus = EMDownloadStatus.PENDING;

  // 宽
  int width;

  // 高
  int height;

}

// video body
class EMVideoMessageBody extends EMFileMessageBody {

  EMVideoMessageBody({
    String localPath,
    String displayName,
    this.duration,
    this.thumbnailLocalPath,
    this.height,
    this.width,
  }) : super (
    localPath: localPath,
    displayName: displayName,
    type: EMMessageBodyType.VIDEO,
  );

  EMVideoMessageBody.fromJson({Map map}) : super.fromJson(map: map, type: EMMessageBodyType.VIDEO)
  {
    this.duration = map['duration'];
    this.thumbnailLocalPath = map['thumbnailLocalPath'];
    this.thumbnailRemotePath = map['thumbnailRemotePath'];
    this.thumbnailSecret = map['thumbnailSecret'];
    this.height = map['height'];
    this.width = map['width'];
    this.thumbnailStatus = EMFileMessageBody.downloadStatusFromInt(map['thumbnailStatus']);
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['duration'] = this.duration;
    data['thumbnailLocalPath'] = this.thumbnailLocalPath;
    data['thumbnailRemotePath'] = this.thumbnailRemotePath;
    data['thumbnailSecret'] = this.thumbnailSecret;
    data['height'] = this.height;
    data['width'] = this.width;
    data['thumbnailStatus'] = EMFileMessageBody.downloadStatusToInt(this.thumbnailStatus);
    return data;
  }

  // 时长。秒
  int duration;

  // 缩略图本地地址
  String thumbnailLocalPath;

  // 缩略图服务器地址
  String thumbnailRemotePath;

  // 缩略图 secret
  String thumbnailSecret;

  // 缩略图状态
  EMDownloadStatus thumbnailStatus = EMDownloadStatus.PENDING;

  // 宽
  int width;

  // 高
  int height;

}

// voice body
class EMVoiceMessageBody extends EMFileMessageBody {

  EMVoiceMessageBody({
    localPath,
    String displayName,
    this.duration,
  }) : super (
    localPath: localPath,
    displayName: displayName,
    type: EMMessageBodyType.VOICE,
  );

  EMVoiceMessageBody.fromJson({Map map}) : super.fromJson(map: map, type: EMMessageBodyType.VOICE)
  {
    this.duration = map['duration'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['duration'] = this.duration;
    return data;
  }

  // 时长, 秒
  int duration;
}


// cmd body
class EMCmdMessageBody extends EMMessageBody {

  EMCmdMessageBody({@required this.action, this.deliverOnlineOnly}) : super (
      type: EMMessageBodyType.CMD
  );

  EMCmdMessageBody.fromJson({Map map}) : super.fromJson(map: map, type: EMMessageBodyType.CMD)
  {
    this.action = map['action'];
    this.deliverOnlineOnly = map['deliverOnlineOnly'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['action'] = this.action;
    data['deliverOnlineOnly'] = this.deliverOnlineOnly;
    return data;
  }

  // cmd 标识
  String action;
  // 是否只投在线
  bool deliverOnlineOnly = false;
}

// custom body
class EMCustomMessageBody extends EMMessageBody {

  EMCustomMessageBody({
    @required this.event,
    this.params
  }) : super (
      type: EMMessageBodyType.CUSTOM
  );

  EMCustomMessageBody.fromJson({Map map}) : super.fromJson(map: map, type: EMMessageBodyType.CUSTOM)
  {
    this.event = map['event'];
    this.params = map['params'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['event'] = event;
    data['params'] = params;
    return data;
  }

  // 自定义事件key
  String event;

  // 附加参数
  Map params;
}