import Flutter
import UIKit
import ChatProvidersSDK

public class SwiftFlutterZendeskChatPlugin: NSObject, FlutterPlugin {
    
    var connectionToken: ObservationToken?
    var accountToken: ObservationToken?
    var chatToken: ObservationToken?
    static var connectionStreamHandler: StreamHandler? = StreamHandler()
    static var accountStreamHandler: StreamHandler? = StreamHandler()
    static var chatItemStreamHandler: StreamHandler? = StreamHandler()
    static var chatAgentStreamHandler: StreamHandler? = StreamHandler()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_zendesk_chat", binaryMessenger: registrar.messenger())
        let connectionStatusEventsChannel = FlutterEventChannel(name: "flutter_zendesk_chat/connection_status_events", binaryMessenger: registrar.messenger());
        let accountStatusEventsChannel = FlutterEventChannel(name: "flutter_zendesk_chat/account_status_events", binaryMessenger: registrar.messenger());
        let agentEventsChannel = FlutterEventChannel(name: "flutter_zendesk_chat/agent_events", binaryMessenger: registrar.messenger());
        let chatItemsEventsChannel = FlutterEventChannel(name: "flutter_zendesk_chat/chat_items_events", binaryMessenger: registrar.messenger());
        let instance = SwiftFlutterZendeskChatPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        connectionStatusEventsChannel.setStreamHandler(connectionStreamHandler)
        accountStatusEventsChannel.setStreamHandler(accountStreamHandler)
        agentEventsChannel.setStreamHandler(chatAgentStreamHandler)
        chatItemsEventsChannel.setStreamHandler(chatItemStreamHandler)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "start" {
            guard let args = call.arguments else {
                result("no arguments found for method: (start)")
                return
            }
            
            if let myArgs = args as? [String: Any],
                let accountKey = myArgs["accountKey"] as? String,
                let name = myArgs["name"] as? String {
                
                let email = myArgs["email"] as? String;
                let phoneNumber = myArgs["phoneNumber"] as? String;
                let department = myArgs["department"] as? String;
                let tags = myArgs["tags"] as? [String];
                
                do {
                    try self.initialize(accountKey: accountKey, appId: myArgs["appId"] as? String, department: department, name: name, email: email, phoneNumber: phoneNumber, tags: tags)
                } catch {
                    print("Chat error: \(error). End of chat error.")
                    result(false)
                }
                Chat.chatProvider?.sendOfflineForm(OfflineForm(visitorInfo: Chat.instance?.configuration.visitorInfo, departmentId: Chat.instance?.configuration.department, message: "It's a test message. WWW. HELP!")) { (outcome) in
                        switch outcome {
                        case .success:
                            result(true)
                            return;
                        case .failure(let error):
                            result(false)
                            return;
                        default:
                            result(false)
                        }
                }
            } else {
                result("'token' and 'language' are required in method: (beginKyc)")
            }
            
        } else if call.method == "sendMessage" {
            guard let args = call.arguments else {
                result("no arguments found for method: (sendMessage)")
                return
            }
            
            if let myArgs = args as? [String: Any],
                let message = myArgs["message"] as? String
            {
                Chat.chatProvider?.sendMessage(message) { (outcome) in
                    switch outcome {
                    case .success(_):
                        result(true)
                        return;
                    case .failure(_):
                        result(false)
                        return;
                    default:
                        result(false)
                    }
                }
            } else {
                result(false)
            }
        } else if call.method == "resendMessage" {
            guard let args = call.arguments else {
                result("no arguments found for method: (resendMessage)")
                return
            }
            
            if let myArgs = args as? [String: Any],
                let messageId = myArgs["messageId"] as? String
            {
                Chat.chatProvider?.resendFailedMessage(withId: messageId) { (outcome) in
                    switch outcome {
                    case .success(_):
                        result(true)
                        return;
                    case .failure(_):
                        result(false)
                        return;
                    default:
                        result(false)
                    }
                }
            } else {
                result(false)
            }
        } else if call.method == "sendComment" {
            guard let args = call.arguments else {
                result("no arguments found for method: (sendComment)")
                return
            }
            
            if let myArgs = args as? [String: Any],
                let comment = myArgs["comment"] as? String
            {
                Chat.chatProvider?.sendChatComment(comment) { (outcome) in
                    switch outcome {
                    case .success(_):
                        result(true)
                        return;
                    case .failure(_):
                        result(false)
                        return;
                    default:
                        result(false)
                    }
                }
            } else {
                result(false)
            }
        } else if call.method == "sendChatRating" {
            guard let args = call.arguments else {
                result("no arguments found for method: (sendChatRating)")
                return
            }
            
            if let myArgs = args as? [String: Any],
                let rating: String = myArgs["rating"] as? String
            {
                Chat.chatProvider?.sendChatRating(SwiftFlutterZendeskChatPlugin.stringToRating(value: rating)) { (outcome) in
                    switch outcome {
                    case .success(_):
                        result(true)
                        return;
                    case .failure(_):
                        result(false)
                        return;
                    default:
                        result(false)
                    }
                }
            } else {
                result(false)
            }
        } else if call.method == "sendOfflineMessage" {
            guard let args = call.arguments else {
                result(false)
                return
            }
            if let myArgs = args as? [String: Any],
            let message: String = myArgs["message"] as? String
            {
                do {
                    let visitorInfo = VisitorInfo(name: "Test", email: "clients@travelunion.eu", phoneNumber: "+48570851167")
                    let offlineForm = OfflineForm(visitorInfo: visitorInfo, departmentId: "Mobile Bankk", message: "Message")
                    try Chat.chatProvider?.sendOfflineForm(offlineForm) { (outcome) in
                        switch outcome {
                        case .success:
                            result(true)
                            return;
                        case .failure(let error):
                            result(false)
                            return;
                        default:
                            result(false)
                        }
                    }
                    print("FINISH sendOfflineForm")
                } catch {
                    result(false)
                }
            } else {
                result(false)
            }
        } else if call.method == "endChat" {
            Chat.instance?.chatProvider.endChat { (outcome) in
                switch outcome {
                case .success(_):
                    self.unbindObservers()
                    result(true)
                    return;
                case .failure(_):
                    result(false)
                    return;
                default:
                    result(false)
                }
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    func initialize(accountKey: String, appId: String?, department: String?, name: String, email: String?, phoneNumber: String?, tags: [String]?) throws {
        if(appId != nil) {
            print(appId ?? "");
            Chat.initialize(accountKey: accountKey, appId: appId, queue: .main)
        } else {
            Chat.initialize(accountKey: accountKey, queue: .main)
        }
        
        let chatAPIConfiguration = ChatAPIConfiguration()
        
        if(tags != nil){
            chatAPIConfiguration.tags = tags!
        }
        
        if(department != nil) {
            chatAPIConfiguration.department = department
        }
        
        chatAPIConfiguration.visitorInfo = VisitorInfo(name: name, email: email ?? "", phoneNumber: phoneNumber ?? "")
        Chat.instance?.configuration = chatAPIConfiguration
        
        self.initObservers()
        
        Chat.connectionProvider?.connect()
    }
    
    func initObservers() -> Void {
        accountToken = Chat.accountProvider?.observeAccount { (account) in
            switch account.accountStatus {
            case .online:
                SwiftFlutterZendeskChatPlugin.accountStreamHandler?.success(value: "ONLINE")
                break
            default:
                SwiftFlutterZendeskChatPlugin.accountStreamHandler?.success(value: "OFFLINE")
            }
        }
        
        connectionToken = Chat.connectionProvider?.observeConnectionStatus { (connection) in
            switch connection {
            case .connected:
                SwiftFlutterZendeskChatPlugin.connectionStreamHandler?.success(value: "CONNECTED")
                break
            case .connecting:
                SwiftFlutterZendeskChatPlugin.connectionStreamHandler?.success(value: "CONNECTING")
                break
            case.disconnected:
                SwiftFlutterZendeskChatPlugin.connectionStreamHandler?.success(value: "DISCONNECTING")
                break
            case .failed:
                SwiftFlutterZendeskChatPlugin.connectionStreamHandler?.success(value: "FAILED")
                break
            case .reconnecting:
                SwiftFlutterZendeskChatPlugin.connectionStreamHandler?.success(value: "RECONNECTING")
                break
            default:
                SwiftFlutterZendeskChatPlugin.connectionStreamHandler?.success(value: "UNREACHABLE")
                break
            }
        }
        
        chatToken = Chat.chatProvider?.observeChatState { (chatState) in
            let _logs = chatState.logs.map { (log : ChatLog) -> ChatLogEvent in
                let _type = SwiftFlutterZendeskChatPlugin.typeToString(type: log.type)
                let _deliveryStatus = SwiftFlutterZendeskChatPlugin.deliveryStatusToString(status: log.status)
                let _participant = SwiftFlutterZendeskChatPlugin.participantToString(participant: log.participant)
                
                var _message: String? = nil;
                var _currentRating: String? = nil;
                var _comment: String? = nil;
                var _newComment: String? = nil;
                var _attachment: ChatLogAttachment? = nil;
                
                if let _messageLog = log as? ChatMessage {
                    _message = _messageLog.message;
                } else if let _ratingLog = log as? ChatRating {
                    _currentRating = SwiftFlutterZendeskChatPlugin.ratingoString(rating: _ratingLog.rating);
                } else if let _attachmentLog = log as? ChatAttachment {
                    _attachment = ChatLogAttachment(mimeType: _attachmentLog.mimeType, name: _attachmentLog.name, size: _attachmentLog.size, url: _attachmentLog.url, localUrl: _attachmentLog.localURL)
                } else if let _ratingLog = log as? ChatComment {
                    _comment = _ratingLog.comment;
                    _newComment = _ratingLog.newComment;
                }
                
                return ChatLogEvent(
                    id: log.id,
                    type: _type,
                    createTimestamp: log.createdTimestamp,
                    modifyTimestamp: log.lastModifiedTimestamp,
                    deliveryStatus: _deliveryStatus,
                    displayName: log.displayName,
                    nick: log.nick,
                    participant: _participant,
                    message: _message,
                    currentRating: _currentRating,
                    previousComment: _comment,
                    currentComment: _newComment,
                    attachment: _attachment
                )
            }
            let _logsData = try! JSONEncoder().encode(_logs)
            let _logsJson = String(data: _logsData, encoding: .utf8)!
            SwiftFlutterZendeskChatPlugin.chatItemStreamHandler?.success(json: _logsJson)
            
            let _agents = chatState.agents.map {(agent: Agent) -> ChatAgent in
                return ChatAgent(displayName: agent.displayName, nick: agent.nick, avatarPath: agent.avatar, isTyping: agent.isTyping)
            }
            
            let _agentsData = try! JSONEncoder().encode(_agents)
            let _agentsJson = String(data: _agentsData, encoding: .utf8)!
            SwiftFlutterZendeskChatPlugin.chatAgentStreamHandler?.success(json: _agentsJson)
        }
    }
    
    func unbindObservers() {
        connectionToken?.cancel()
        accountToken?.cancel()
        chatToken?.cancel()
    }
    
    deinit {
        self.unbindObservers()
    }
    
    static func typeToString(type: ChatLogType) -> String {
        switch type {
        case .attachmentMessage:
            return "ATTACHMENT_MESSAGE"
        case .chatComment:
            return "COMMENT"
        case .chatRating:
            return "RATING"
        case .chatRatingRequest:
            return "RATING_REQUEST"
        case .memberJoin:
            return "MEMBER_JOIN"
        case .memberLeave:
            return "MEMBER_LEAVE"
        case .message:
            return "MESSAGE"
        default:
            return "UNKNOWN"
        }
    }
    
    static func deliveryStatusToString(status: DeliveryStatus) -> String {
        switch status {
        case .delivered:
            return "DELIVERED"
        case .failed:
            return "FAILED"
        case .pending:
            return "PENDING"
        default:
            return "UNKNOWN"
        }
    }
    
    static func participantToString(participant: ChatParticipant) -> String {
        switch participant {
        case .agent:
            return "AGENT"
        case .system:
            return "SYSTEM"
        case .visitor:
            return "VISITOR"
        case .trigger:
            return "TRIGGER"
        default:
            return "UNKNOWN"
        }
    }
    
    static func ratingoString(rating: Rating) -> String {
        switch rating {
        case .good:
            return "GOOD"
        case .bad:
            return "BAD"
        default:
            return "UNKNOWN"
        }
    }
    
    static func stringToRating(value: String?) -> Rating {
        switch value {
        case "ChatRating.GOOD":
            return Rating.good;
        case "ChatRating.BAD":
            return Rating.bad;
        default:
            return Rating.none;
        }
    }
}

class StreamHandler: NSObject, FlutterStreamHandler {
    private var _eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        _eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        _eventSink = nil
        return nil
    }
    
    func success(json: String) {
        _eventSink?(json)
    }
    
    func success(value: String) {
        _eventSink?(value)
    }
}

struct ChatLogEvent : Encodable {
    var id: String;
    var type: String;
    var createTimestamp: TimeInterval;
    var modifyTimestamp: TimeInterval;
    var deliveryStatus: String;
    var displayName: String;
    var nick: String;
    var participant: String;
    var message: String?;
    var previousRating: String?;
    var currentRating: String?;
    var previousComment: String?;
    var currentComment: String?;
    var attachment: ChatLogAttachment?;
    
    enum CodingKeys: String, CodingKey {
        case createTimestamp = "create_timestamp"
        case modifyTimestamp = "modify_timestamp"
        case deliveryStatus = "delivery_status"
        case displayName = "display_name"
        case previousRating = "previous_rating"
        case currentRating = "current_rating"
        case previousComment = "previous_comment"
        case currentComment = "current_comment"
        case id
        case message
        case nick
        case type
        case participant
        case attachment
    }
}

struct ChatAgent : Encodable {
    var displayName: String;
    var nick: String;
    var avatarPath: URL?;
    var isTyping: Bool;
    
    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case avatarPath = "avatar_url"
        case isTyping = "is_typing"
        case nick
    }
}

struct ChatLogAttachment : Encodable {
    var mimeType: String;
    var name: String;
    var size: Int;
    var url: String;
    var localUrl: URL?;
    
    enum CodingKeys: String, CodingKey {
        case mimeType = "mime_type"
        case localUrl = "local_url"
        case name
        case size
        case url
    }
}
