import Foundation
import Postbox
import TelegramCore

enum ChatPresentationInputQueryKind: Int32 {
    case emoji
    case hashtag
    case mention
    case command
    case contextRequest
}

struct ChatInputQueryMentionTypes: OptionSet {
    var rawValue: Int32
    
    init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    static let contextBots = ChatInputQueryMentionTypes(rawValue: 1 << 0)
    static let members = ChatInputQueryMentionTypes(rawValue: 1 << 1)
    static let accountPeer = ChatInputQueryMentionTypes(rawValue: 1 << 2)
}

enum ChatPresentationInputQuery: Hashable, Equatable {
    case emoji(String)
    case hashtag(String)
    case mention(query: String, types: ChatInputQueryMentionTypes)
    case command(String)
    case contextRequest(addressName: String, query: String)
    
    var kind: ChatPresentationInputQueryKind {
        switch self {
            case .emoji:
                return .emoji
            case .hashtag:
                return .hashtag
            case .mention:
                return .mention
            case .command:
                return .command
            case .contextRequest:
                return .contextRequest
        }
    }
    
    var hashValue: Int {
        switch self {
            case let .emoji(value):
                return 1 &+ value.hashValue
            case let .hashtag(value):
                return 2 &+ value.hashValue
            case let .mention(text, types):
                return 3 &+ text.hashValue &* 31 &+ types.rawValue.hashValue
            case let .command(value):
                return 4 &+ value.hashValue
            case let .contextRequest(addressName, query):
                return 5 &+ addressName.hashValue &* 31 + query.hashValue
        }
    }
    
    static func ==(lhs: ChatPresentationInputQuery, rhs: ChatPresentationInputQuery) -> Bool {
        switch lhs {
            case let .emoji(query):
                if case .emoji(query) = rhs {
                    return true
                } else {
                    return false
                }
            case let .hashtag(query):
                if case .hashtag(query) = rhs {
                    return true
                } else {
                    return false
                }
            case let .mention(query, types):
                if case .mention(query, types) = rhs {
                    return true
                } else {
                    return false
                }
            case let .command(query):
                if case .command(query) = rhs {
                    return true
                } else {
                    return false
                }
            case let .contextRequest(addressName, query):
                if case .contextRequest(addressName, query) = rhs {
                    return true
                } else {
                    return false
                }
        }
    }
}

enum ChatPresentationInputQueryResult: Equatable {
    case stickers([FoundStickerItem])
    case hashtags([String])
    case mentions([Peer])
    case commands([PeerCommand])
    case contextRequestResult(Peer?, ChatContextResultCollection?)
    
    static func ==(lhs: ChatPresentationInputQueryResult, rhs: ChatPresentationInputQueryResult) -> Bool {
        switch lhs {
        case let .stickers(lhsItems):
                if case let .stickers(rhsItems) = rhs, lhsItems == rhsItems {
                    return true
                } else {
                    return false
                }
            case let .hashtags(lhsResults):
                if case let .hashtags(rhsResults) = rhs {
                    return lhsResults == rhsResults
                } else {
                    return false
                }
            case let .mentions(lhsPeers):
                if case let .mentions(rhsPeers) = rhs {
                    if lhsPeers.count != rhsPeers.count {
                        return false
                    } else {
                        for i in 0 ..< lhsPeers.count {
                            if !lhsPeers[i].isEqual(rhsPeers[i]) {
                                return false
                            }
                        }
                        return true
                    }
                } else {
                    return false
                }
            case let .commands(lhsCommands):
                if case let .commands(rhsCommands) = rhs {
                    if lhsCommands != rhsCommands {
                        return false
                    }
                    return true
                } else {
                    return false
                }
            case let .contextRequestResult(lhsPeer, lhsCollection):
                if case let .contextRequestResult(rhsPeer, rhsCollection) = rhs {
                    if let lhsPeer = lhsPeer, let rhsPeer = rhsPeer {
                        if !lhsPeer.isEqual(rhsPeer) {
                            return false
                        }
                    } else if (lhsPeer != nil) != (rhsPeer != nil) {
                        return false
                    }
                    
                    if lhsCollection != rhsCollection {
                        return false
                    }
                    return true
                } else {
                    return false
                }
        }
    }
}

enum ChatMediaInputMode {
    case gif
    case other
}

enum ChatInputMode: Equatable {
    case none
    case text
    case media(ChatMediaInputMode)
    case inputButtons
    
    static func ==(lhs: ChatInputMode, rhs: ChatInputMode) -> Bool {
        switch lhs {
            case .none:
                if case .none = rhs {
                    return true
                } else {
                    return false
                }
            case .text:
                if case .text = rhs {
                    return true
                } else {
                    return false
                }
            case let .media(mode):
                if case .media(mode) = rhs {
                    return true
                } else {
                    return false
                }
            case .inputButtons:
                if case .inputButtons = rhs {
                    return true
                } else {
                    return false
                }
        }
    }
}

enum ChatTitlePanelContext: Comparable {
    case pinnedMessage
    case chatInfo
    case requestInProgress
    case toastAlert(String)
    
    private var index: Int {
        switch self {
            case .pinnedMessage:
                return 0
            case .chatInfo:
                return 1
            case .requestInProgress:
                return 2
            case .toastAlert:
                return 3
        }
    }
    
    static func ==(lhs: ChatTitlePanelContext, rhs: ChatTitlePanelContext) -> Bool {
        switch lhs {
            case .pinnedMessage:
                if case .pinnedMessage = rhs {
                    return true
                } else {
                    return false
                }
            case .chatInfo:
                if case .chatInfo = rhs {
                    return true
                } else {
                    return false
                }
            case .requestInProgress:
                if case .requestInProgress = rhs {
                    return true
                } else {
                    return false
                }
            case let .toastAlert(text):
                if case .toastAlert(text) = rhs {
                    return true
                } else {
                    return false
                }
        }
    }
    
    static func <(lhs: ChatTitlePanelContext, rhs: ChatTitlePanelContext) -> Bool {
        return lhs.index < rhs.index
    }
}

struct ChatSearchResultsState: Equatable {
    let messageIndices: [MessageIndex]
    let currentId: MessageId?
    
    static func ==(lhs: ChatSearchResultsState, rhs: ChatSearchResultsState) -> Bool {
        if lhs.messageIndices != rhs.messageIndices {
            return false
        }
        if lhs.currentId != rhs.currentId {
            return false
        }
        return false
    }
}

enum ChatSearchDomain: Equatable {
    case everything
    case members
    case member(Peer)
    
    static func ==(lhs: ChatSearchDomain, rhs: ChatSearchDomain) -> Bool {
        switch lhs {
            case .everything:
                if case .everything = rhs {
                    return true
                } else {
                    return false
                }
            case .members:
                if case .members = rhs {
                    return true
                } else {
                    return false
                }
            case let .member(lhsPeer):
                if case let .member(rhsPeer) = rhs, arePeersEqual(lhsPeer, rhsPeer) {
                    return true
                } else {
                    return false
                }
        }
    }
}
    
enum ChatSearchDomainSuggestionContext: Equatable {
    case none
    case members(String)
    
    static func ==(lhs: ChatSearchDomainSuggestionContext, rhs: ChatSearchDomainSuggestionContext) -> Bool {
        switch lhs {
            case .none:
                if case .none = rhs {
                    return true
                } else {
                    return false
                }
            case let .members(query):
                if case .members(query) = rhs {
                    return true
                } else {
                    return false
                }
        }
    }
}

struct ChatSearchData: Equatable {
    let query: String
    let domain: ChatSearchDomain
    let domainSuggestionContext: ChatSearchDomainSuggestionContext
    let resultsState: ChatSearchResultsState?
    
    init(query: String = "", domain: ChatSearchDomain = .everything, domainSuggestionContext: ChatSearchDomainSuggestionContext = .none, resultsState: ChatSearchResultsState? = nil) {
        self.query = query
        self.domain = domain
        self.domainSuggestionContext = domainSuggestionContext
        self.resultsState = resultsState
    }
    
    static func ==(lhs: ChatSearchData, rhs: ChatSearchData) -> Bool {
        if lhs.query != rhs.query {
            return false
        }
        if lhs.domain != rhs.domain {
            return false
        }
        if lhs.domainSuggestionContext != rhs.domainSuggestionContext {
            return false
        }
        if lhs.resultsState != rhs.resultsState {
            return false
        }
        return true
    }
    
    func withUpdatedQuery(_ query: String) -> ChatSearchData {
        return ChatSearchData(query: query, domain: self.domain, domainSuggestionContext: self.domainSuggestionContext, resultsState: self.resultsState)
    }
    
    func withUpdatedDomain(_ domain: ChatSearchDomain) -> ChatSearchData {
        return ChatSearchData(query: self.query, domain: domain, domainSuggestionContext: self.domainSuggestionContext, resultsState: self.resultsState)
    }
    
    func withUpdatedDomainSuggestionContext(_ domain: ChatSearchDomainSuggestionContext) -> ChatSearchData {
        return ChatSearchData(query: self.query, domain: self.domain, domainSuggestionContext: domainSuggestionContext, resultsState: self.resultsState)
    }
    
    func withUpdatedResultsState(_ resultsState: ChatSearchResultsState?) -> ChatSearchData {
        return ChatSearchData(query: self.query, domain: self.domain, domainSuggestionContext: self.domainSuggestionContext, resultsState: resultsState)
    }
}

final class ChatRecordedMediaPreview: Equatable {
    let resource: TelegramMediaResource
    let fileSize: Int32
    let duration: Int32
    let waveform: AudioWaveform
    
    init(resource: TelegramMediaResource, duration: Int32, fileSize: Int32, waveform: AudioWaveform) {
        self.resource = resource
        self.duration = duration
        self.fileSize = fileSize
        self.waveform = waveform
    }
    
    static func ==(lhs: ChatRecordedMediaPreview, rhs: ChatRecordedMediaPreview) -> Bool {
        if !lhs.resource.isEqual(to: rhs.resource) {
            return false
        }
        if lhs.duration != rhs.duration {
            return false
        }
        if lhs.fileSize != rhs.fileSize {
            return false
        }
        if lhs.waveform != rhs.waveform {
            return false
        }
        return true
    }
}

struct ChatPresentationInterfaceState: Equatable {
    let interfaceState: ChatInterfaceState
    let chatLocation: ChatLocation
    let peer: Peer?
    let inputTextPanelState: ChatTextInputPanelState
    let recordedMediaPreview: ChatRecordedMediaPreview?
    let inputQueryResults: [ChatPresentationInputQueryKind: ChatPresentationInputQueryResult]
    let inputMode: ChatInputMode
    let titlePanelContexts: [ChatTitlePanelContext]
    let keyboardButtonsMessage: Message?
    let pinnedMessageId: MessageId?
    let pinnedMessage: Message?
    let peerIsBlocked: Bool
    let peerIsMuted: Bool
    let canReportPeer: Bool
    let chatHistoryState: ChatHistoryNodeHistoryState?
    let botStartPayload: String?
    let urlPreview: (String, TelegramMediaWebpage)?
    let editingUrlPreview: (String, TelegramMediaWebpage)?
    let search: ChatSearchData?
    let searchQuerySuggestionResult: ChatPresentationInputQueryResult?
    let chatWallpaper: TelegramWallpaper
    let theme: PresentationTheme
    let strings: PresentationStrings
    let fontSize: PresentationFontSize
    let accountPeerId: PeerId
    let mode: ChatControllerPresentationMode
    
    init(chatWallpaper: TelegramWallpaper, theme: PresentationTheme, strings: PresentationStrings, fontSize: PresentationFontSize, accountPeerId: PeerId, mode: ChatControllerPresentationMode, chatLocation: ChatLocation) {
        self.interfaceState = ChatInterfaceState()
        self.inputTextPanelState = ChatTextInputPanelState()
        self.recordedMediaPreview = nil
        self.chatLocation = chatLocation
        self.peer = nil
        self.inputQueryResults = [:]
        self.inputMode = .none
        self.titlePanelContexts = []
        self.keyboardButtonsMessage = nil
        self.pinnedMessageId = nil
        self.pinnedMessage = nil
        self.peerIsBlocked = false
        self.peerIsMuted = false
        self.canReportPeer = false
        self.chatHistoryState = nil
        self.botStartPayload = nil
        self.urlPreview = nil
        self.editingUrlPreview = nil
        self.search = nil
        self.searchQuerySuggestionResult = nil
        self.chatWallpaper = chatWallpaper
        self.theme = theme
        self.strings = strings
        self.fontSize = fontSize
        self.accountPeerId = accountPeerId
        self.mode = mode
    }
    
    init(interfaceState: ChatInterfaceState, chatLocation: ChatLocation, peer: Peer?, inputTextPanelState: ChatTextInputPanelState, recordedMediaPreview: ChatRecordedMediaPreview?, inputQueryResults: [ChatPresentationInputQueryKind: ChatPresentationInputQueryResult], inputMode: ChatInputMode, titlePanelContexts: [ChatTitlePanelContext], keyboardButtonsMessage: Message?, pinnedMessageId: MessageId?, pinnedMessage: Message?, peerIsBlocked: Bool, peerIsMuted: Bool, canReportPeer: Bool, chatHistoryState: ChatHistoryNodeHistoryState?, botStartPayload: String?, urlPreview: (String, TelegramMediaWebpage)?, editingUrlPreview: (String, TelegramMediaWebpage)?, search: ChatSearchData?, searchQuerySuggestionResult: ChatPresentationInputQueryResult?, chatWallpaper: TelegramWallpaper, theme: PresentationTheme, strings: PresentationStrings, fontSize: PresentationFontSize, accountPeerId: PeerId, mode: ChatControllerPresentationMode) {
        self.interfaceState = interfaceState
        self.chatLocation = chatLocation
        self.peer = peer
        self.inputTextPanelState = inputTextPanelState
        self.recordedMediaPreview = recordedMediaPreview
        self.inputQueryResults = inputQueryResults
        self.inputMode = inputMode
        self.titlePanelContexts = titlePanelContexts
        self.keyboardButtonsMessage = keyboardButtonsMessage
        self.pinnedMessageId = pinnedMessageId
        self.pinnedMessage = pinnedMessage
        self.peerIsBlocked = peerIsBlocked
        self.peerIsMuted = peerIsMuted
        self.canReportPeer = canReportPeer
        self.chatHistoryState = chatHistoryState
        self.botStartPayload = botStartPayload
        self.urlPreview = urlPreview
        self.editingUrlPreview = editingUrlPreview
        self.search = search
        self.searchQuerySuggestionResult = searchQuerySuggestionResult
        self.chatWallpaper = chatWallpaper
        self.theme = theme
        self.strings = strings
        self.fontSize = fontSize
        self.accountPeerId = accountPeerId
        self.mode = mode
    }
    
    static func ==(lhs: ChatPresentationInterfaceState, rhs: ChatPresentationInterfaceState) -> Bool {
        if lhs.interfaceState != rhs.interfaceState {
            return false
        }
        if let lhsPeer = lhs.peer, let rhsPeer = rhs.peer {
            if !lhsPeer.isEqual(rhsPeer) {
                return false
            }
        } else if (lhs.peer == nil) != (rhs.peer == nil) {
            return false
        }
        
        if lhs.inputTextPanelState != rhs.inputTextPanelState {
            return false
        }
        
        if lhs.recordedMediaPreview != rhs.recordedMediaPreview {
            return false
        }
        
        if lhs.inputQueryResults != rhs.inputQueryResults {
            return false
        }
        
        if lhs.inputMode != rhs.inputMode {
            return false
        }
        
        if lhs.titlePanelContexts != rhs.titlePanelContexts {
            return false
        }
        
        if let lhsMessage = lhs.keyboardButtonsMessage, let rhsMessage = rhs.keyboardButtonsMessage {
            if lhsMessage.id != rhsMessage.id {
                return false
            }
            if lhsMessage.stableVersion != rhsMessage.stableVersion {
                return false
            }
        } else if (lhs.keyboardButtonsMessage != nil) != (rhs.keyboardButtonsMessage != nil) {
            return false
        }
        
        if lhs.pinnedMessageId != rhs.pinnedMessageId {
            return false
        }
        
        if let lhsMessage = lhs.pinnedMessage, let rhsMessage = rhs.pinnedMessage {
            if lhsMessage.id != rhsMessage.id {
                return false
            }
            if lhsMessage.stableVersion != rhsMessage.stableVersion {
                return false
            }
        } else if (lhs.pinnedMessage != nil) != (rhs.pinnedMessage != nil) {
            return false
        }
        
        if lhs.canReportPeer != rhs.canReportPeer {
            return false
        }
        
        if lhs.peerIsBlocked != rhs.peerIsBlocked {
            return false
        }
        
        if lhs.peerIsMuted != rhs.peerIsMuted {
            return false
        }
        
        if lhs.chatHistoryState != rhs.chatHistoryState {
            return false
        }
        
        if lhs.botStartPayload != rhs.botStartPayload {
            return false
        }
        
        if let lhsUrlPreview = lhs.urlPreview, let rhsUrlPreview = rhs.urlPreview {
            if lhsUrlPreview.0 != rhsUrlPreview.0 {
                return false
            }
            if !lhsUrlPreview.1.isEqual(rhsUrlPreview.1) {
                return false
            }
        } else if (lhs.urlPreview != nil) != (rhs.urlPreview != nil) {
            return false
        }
        
        if let lhsEditingUrlPreview = lhs.editingUrlPreview, let rhsEditingUrlPreview = rhs.editingUrlPreview {
            if lhsEditingUrlPreview.0 != rhsEditingUrlPreview.0 {
                return false
            }
            if !lhsEditingUrlPreview.1.isEqual(rhsEditingUrlPreview.1) {
                return false
            }
        } else if (lhs.editingUrlPreview != nil) != (rhs.editingUrlPreview != nil) {
            return false
        }
        
        if lhs.search != rhs.search {
            return false
        }
        
        if lhs.searchQuerySuggestionResult != rhs.searchQuerySuggestionResult {
            return false
        }
        
        if lhs.chatWallpaper != rhs.chatWallpaper {
            return false
        }
        
        if lhs.theme !== rhs.theme {
            return false
        }
        
        if lhs.strings !== rhs.strings {
            return false
        }
        
        if lhs.fontSize != rhs.fontSize {
            return false
        }
        
        if lhs.accountPeerId != rhs.accountPeerId {
            return false
        }
        
        if lhs.mode != rhs.mode {
            return false
        }
        
        return true
    }
    
    func updatedInterfaceState(_ f: (ChatInterfaceState) -> ChatInterfaceState) -> ChatPresentationInterfaceState {
        return ChatPresentationInterfaceState(interfaceState: f(self.interfaceState), chatLocation: self.chatLocation, peer: self.peer, inputTextPanelState: self.inputTextPanelState, recordedMediaPreview: self.recordedMediaPreview, inputQueryResults: self.inputQueryResults, inputMode: self.inputMode, titlePanelContexts: self.titlePanelContexts, keyboardButtonsMessage: self.keyboardButtonsMessage, pinnedMessageId: self.pinnedMessageId, pinnedMessage: self.pinnedMessage, peerIsBlocked: self.peerIsBlocked, peerIsMuted: self.peerIsMuted, canReportPeer: self.canReportPeer, chatHistoryState: self.chatHistoryState, botStartPayload: self.botStartPayload, urlPreview: self.urlPreview, editingUrlPreview: self.editingUrlPreview, search: self.search, searchQuerySuggestionResult: self.searchQuerySuggestionResult, chatWallpaper: self.chatWallpaper, theme: self.theme, strings: self.strings, fontSize: self.fontSize, accountPeerId: self.accountPeerId, mode: self.mode)
    }
    
    func updatedPeer(_ f: (Peer?) -> Peer?) -> ChatPresentationInterfaceState {
        return ChatPresentationInterfaceState(interfaceState: self.interfaceState, chatLocation: self.chatLocation, peer: f(self.peer), inputTextPanelState: self.inputTextPanelState, recordedMediaPreview: self.recordedMediaPreview, inputQueryResults: self.inputQueryResults, inputMode: self.inputMode, titlePanelContexts: self.titlePanelContexts, keyboardButtonsMessage: self.keyboardButtonsMessage, pinnedMessageId: self.pinnedMessageId, pinnedMessage: self.pinnedMessage, peerIsBlocked: self.peerIsBlocked, peerIsMuted: self.peerIsMuted, canReportPeer: self.canReportPeer, chatHistoryState: self.chatHistoryState, botStartPayload: self.botStartPayload, urlPreview: self.urlPreview, editingUrlPreview: self.editingUrlPreview, search: self.search, searchQuerySuggestionResult: self.searchQuerySuggestionResult, chatWallpaper: self.chatWallpaper, theme: self.theme, strings: self.strings, fontSize: self.fontSize, accountPeerId: self.accountPeerId, mode: self.mode)
    }
    
    func updatedInputQueryResult(queryKind: ChatPresentationInputQueryKind, _ f: (ChatPresentationInputQueryResult?) -> ChatPresentationInputQueryResult?) -> ChatPresentationInterfaceState {
        var inputQueryResults = self.inputQueryResults
        let updated = f(inputQueryResults[queryKind])
        if let updated = updated {
            inputQueryResults[queryKind] = updated
        } else {
            inputQueryResults.removeValue(forKey: queryKind)
        }
        return ChatPresentationInterfaceState(interfaceState: self.interfaceState, chatLocation: self.chatLocation, peer: self.peer, inputTextPanelState: self.inputTextPanelState, recordedMediaPreview: self.recordedMediaPreview, inputQueryResults: inputQueryResults, inputMode: self.inputMode, titlePanelContexts: self.titlePanelContexts, keyboardButtonsMessage: self.keyboardButtonsMessage, pinnedMessageId: self.pinnedMessageId, pinnedMessage: self.pinnedMessage, peerIsBlocked: self.peerIsBlocked, peerIsMuted: self.peerIsMuted, canReportPeer: self.canReportPeer, chatHistoryState: self.chatHistoryState, botStartPayload: self.botStartPayload, urlPreview: self.urlPreview, editingUrlPreview: self.editingUrlPreview, search: self.search, searchQuerySuggestionResult: self.searchQuerySuggestionResult, chatWallpaper: self.chatWallpaper, theme: self.theme, strings: self.strings, fontSize: self.fontSize, accountPeerId: self.accountPeerId, mode: self.mode)
    }
    
    func updatedInputTextPanelState(_ f: (ChatTextInputPanelState) -> ChatTextInputPanelState) -> ChatPresentationInterfaceState {
        return ChatPresentationInterfaceState(interfaceState: self.interfaceState, chatLocation: self.chatLocation, peer: self.peer, inputTextPanelState: f(self.inputTextPanelState), recordedMediaPreview: self.recordedMediaPreview, inputQueryResults: self.inputQueryResults, inputMode: self.inputMode, titlePanelContexts: self.titlePanelContexts, keyboardButtonsMessage: self.keyboardButtonsMessage, pinnedMessageId: self.pinnedMessageId, pinnedMessage: self.pinnedMessage, peerIsBlocked: self.peerIsBlocked, peerIsMuted: self.peerIsMuted, canReportPeer: self.canReportPeer, chatHistoryState: self.chatHistoryState, botStartPayload: self.botStartPayload, urlPreview: self.urlPreview, editingUrlPreview: self.editingUrlPreview, search: self.search, searchQuerySuggestionResult: self.searchQuerySuggestionResult, chatWallpaper: self.chatWallpaper, theme: self.theme, strings: self.strings, fontSize: self.fontSize, accountPeerId: self.accountPeerId, mode: self.mode)
    }
    
    func updatedRecordedMediaPreview(_ recordedMediaPreview: ChatRecordedMediaPreview?) -> ChatPresentationInterfaceState {
        return ChatPresentationInterfaceState(interfaceState: self.interfaceState, chatLocation: self.chatLocation, peer: self.peer, inputTextPanelState: self.inputTextPanelState, recordedMediaPreview: recordedMediaPreview, inputQueryResults: self.inputQueryResults, inputMode: self.inputMode, titlePanelContexts: self.titlePanelContexts, keyboardButtonsMessage: self.keyboardButtonsMessage, pinnedMessageId: self.pinnedMessageId, pinnedMessage: self.pinnedMessage, peerIsBlocked: self.peerIsBlocked, peerIsMuted: self.peerIsMuted, canReportPeer: self.canReportPeer, chatHistoryState: self.chatHistoryState, botStartPayload: self.botStartPayload, urlPreview: self.urlPreview, editingUrlPreview: self.editingUrlPreview, search: self.search, searchQuerySuggestionResult: self.searchQuerySuggestionResult, chatWallpaper: self.chatWallpaper, theme: self.theme, strings: self.strings, fontSize: self.fontSize, accountPeerId: self.accountPeerId, mode: self.mode)
    }
    
    func updatedInputMode(_ f: (ChatInputMode) -> ChatInputMode) -> ChatPresentationInterfaceState {
        return ChatPresentationInterfaceState(interfaceState: self.interfaceState, chatLocation: self.chatLocation, peer: self.peer, inputTextPanelState: self.inputTextPanelState, recordedMediaPreview: self.recordedMediaPreview, inputQueryResults: self.inputQueryResults, inputMode: f(self.inputMode), titlePanelContexts: self.titlePanelContexts, keyboardButtonsMessage: self.keyboardButtonsMessage, pinnedMessageId: self.pinnedMessageId, pinnedMessage: self.pinnedMessage, peerIsBlocked: self.peerIsBlocked, peerIsMuted: self.peerIsMuted, canReportPeer: self.canReportPeer, chatHistoryState: self.chatHistoryState, botStartPayload: self.botStartPayload, urlPreview: self.urlPreview, editingUrlPreview: self.editingUrlPreview, search: self.search, searchQuerySuggestionResult: self.searchQuerySuggestionResult, chatWallpaper: self.chatWallpaper, theme: self.theme, strings: self.strings, fontSize: self.fontSize, accountPeerId: self.accountPeerId, mode: self.mode)
    }
    
    func updatedTitlePanelContext(_ f: ([ChatTitlePanelContext]) -> [ChatTitlePanelContext]) -> ChatPresentationInterfaceState {
        return ChatPresentationInterfaceState(interfaceState: self.interfaceState, chatLocation: self.chatLocation, peer: self.peer, inputTextPanelState: self.inputTextPanelState, recordedMediaPreview: self.recordedMediaPreview, inputQueryResults: self.inputQueryResults, inputMode: self.inputMode, titlePanelContexts: f(self.titlePanelContexts), keyboardButtonsMessage: self.keyboardButtonsMessage, pinnedMessageId: self.pinnedMessageId, pinnedMessage: self.pinnedMessage, peerIsBlocked: self.peerIsBlocked, peerIsMuted: self.peerIsMuted, canReportPeer: self.canReportPeer, chatHistoryState: self.chatHistoryState, botStartPayload: self.botStartPayload, urlPreview: self.urlPreview, editingUrlPreview: self.editingUrlPreview, search: self.search, searchQuerySuggestionResult: self.searchQuerySuggestionResult, chatWallpaper: self.chatWallpaper, theme: self.theme, strings: self.strings, fontSize: self.fontSize, accountPeerId: self.accountPeerId, mode: self.mode)
    }
    
    func updatedKeyboardButtonsMessage(_ message: Message?) -> ChatPresentationInterfaceState {
        return ChatPresentationInterfaceState(interfaceState: self.interfaceState, chatLocation: self.chatLocation, peer: self.peer, inputTextPanelState: self.inputTextPanelState, recordedMediaPreview: self.recordedMediaPreview, inputQueryResults: self.inputQueryResults, inputMode: self.inputMode, titlePanelContexts: self.titlePanelContexts, keyboardButtonsMessage: message, pinnedMessageId: self.pinnedMessageId, pinnedMessage: self.pinnedMessage, peerIsBlocked: self.peerIsBlocked, peerIsMuted: self.peerIsMuted, canReportPeer: self.canReportPeer, chatHistoryState: self.chatHistoryState, botStartPayload: self.botStartPayload, urlPreview: self.urlPreview, editingUrlPreview: self.editingUrlPreview, search: self.search, searchQuerySuggestionResult: self.searchQuerySuggestionResult, chatWallpaper: self.chatWallpaper, theme: self.theme, strings: self.strings, fontSize: self.fontSize, accountPeerId: self.accountPeerId, mode: self.mode)
    }
    
    func updatedPinnedMessageId(_ pinnedMessageId: MessageId?) -> ChatPresentationInterfaceState {
        return ChatPresentationInterfaceState(interfaceState: self.interfaceState, chatLocation: self.chatLocation, peer: self.peer, inputTextPanelState: self.inputTextPanelState, recordedMediaPreview: self.recordedMediaPreview, inputQueryResults: self.inputQueryResults, inputMode: self.inputMode, titlePanelContexts: self.titlePanelContexts, keyboardButtonsMessage: self.keyboardButtonsMessage, pinnedMessageId: pinnedMessageId, pinnedMessage: self.pinnedMessage, peerIsBlocked: self.peerIsBlocked, peerIsMuted: self.peerIsMuted, canReportPeer: self.canReportPeer, chatHistoryState: self.chatHistoryState, botStartPayload: self.botStartPayload, urlPreview: self.urlPreview, editingUrlPreview: self.editingUrlPreview, search: self.search, searchQuerySuggestionResult: self.searchQuerySuggestionResult, chatWallpaper: self.chatWallpaper, theme: self.theme, strings: self.strings, fontSize: self.fontSize, accountPeerId: self.accountPeerId, mode: self.mode)
    }
    
    func updatedPinnedMessage(_ pinnedMessage: Message?) -> ChatPresentationInterfaceState {
        return ChatPresentationInterfaceState(interfaceState: self.interfaceState, chatLocation: self.chatLocation, peer: self.peer, inputTextPanelState: self.inputTextPanelState, recordedMediaPreview: self.recordedMediaPreview, inputQueryResults: self.inputQueryResults, inputMode: self.inputMode, titlePanelContexts: self.titlePanelContexts, keyboardButtonsMessage: self.keyboardButtonsMessage, pinnedMessageId: self.pinnedMessageId, pinnedMessage: pinnedMessage, peerIsBlocked: self.peerIsBlocked, peerIsMuted: self.peerIsMuted, canReportPeer: self.canReportPeer, chatHistoryState: self.chatHistoryState, botStartPayload: self.botStartPayload, urlPreview: self.urlPreview, editingUrlPreview: self.editingUrlPreview, search: self.search, searchQuerySuggestionResult: self.searchQuerySuggestionResult, chatWallpaper: self.chatWallpaper, theme: self.theme, strings: self.strings, fontSize: self.fontSize, accountPeerId: self.accountPeerId, mode: self.mode)
    }
    
    func updatedPeerIsBlocked(_ peerIsBlocked: Bool) -> ChatPresentationInterfaceState {
        return ChatPresentationInterfaceState(interfaceState: self.interfaceState, chatLocation: self.chatLocation, peer: self.peer, inputTextPanelState: self.inputTextPanelState, recordedMediaPreview: self.recordedMediaPreview, inputQueryResults: self.inputQueryResults, inputMode: self.inputMode, titlePanelContexts: self.titlePanelContexts, keyboardButtonsMessage: self.keyboardButtonsMessage, pinnedMessageId: self.pinnedMessageId, pinnedMessage: self.pinnedMessage, peerIsBlocked: peerIsBlocked, peerIsMuted: self.peerIsMuted, canReportPeer: self.canReportPeer, chatHistoryState: self.chatHistoryState, botStartPayload: self.botStartPayload, urlPreview: self.urlPreview, editingUrlPreview: self.editingUrlPreview, search: self.search, searchQuerySuggestionResult: self.searchQuerySuggestionResult, chatWallpaper: self.chatWallpaper, theme: self.theme, strings: self.strings, fontSize: self.fontSize, accountPeerId: self.accountPeerId, mode: self.mode)
    }
    
    func updatedPeerIsMuted(_ peerIsMuted: Bool) -> ChatPresentationInterfaceState {
        return ChatPresentationInterfaceState(interfaceState: self.interfaceState, chatLocation: self.chatLocation, peer: self.peer, inputTextPanelState: self.inputTextPanelState, recordedMediaPreview: self.recordedMediaPreview, inputQueryResults: self.inputQueryResults, inputMode: self.inputMode, titlePanelContexts: self.titlePanelContexts, keyboardButtonsMessage: self.keyboardButtonsMessage, pinnedMessageId: self.pinnedMessageId, pinnedMessage: self.pinnedMessage, peerIsBlocked: self.peerIsBlocked, peerIsMuted: peerIsMuted, canReportPeer: self.canReportPeer, chatHistoryState: self.chatHistoryState, botStartPayload: self.botStartPayload, urlPreview: self.urlPreview, editingUrlPreview: self.editingUrlPreview, search: self.search, searchQuerySuggestionResult: self.searchQuerySuggestionResult, chatWallpaper: self.chatWallpaper, theme: self.theme, strings: self.strings, fontSize: self.fontSize, accountPeerId: self.accountPeerId, mode: self.mode)
    }
    
    func updatedCanReportPeer(_ canReportPeer: Bool) -> ChatPresentationInterfaceState {
        return ChatPresentationInterfaceState(interfaceState: self.interfaceState, chatLocation: self.chatLocation, peer: self.peer, inputTextPanelState: self.inputTextPanelState, recordedMediaPreview: self.recordedMediaPreview, inputQueryResults: self.inputQueryResults, inputMode: self.inputMode, titlePanelContexts: self.titlePanelContexts, keyboardButtonsMessage: self.keyboardButtonsMessage, pinnedMessageId: self.pinnedMessageId, pinnedMessage: self.pinnedMessage, peerIsBlocked: self.peerIsBlocked, peerIsMuted: self.peerIsMuted, canReportPeer: canReportPeer, chatHistoryState: self.chatHistoryState, botStartPayload: self.botStartPayload, urlPreview: self.urlPreview, editingUrlPreview: self.editingUrlPreview, search: self.search, searchQuerySuggestionResult: self.searchQuerySuggestionResult, chatWallpaper: self.chatWallpaper, theme: self.theme, strings: self.strings, fontSize: self.fontSize, accountPeerId: self.accountPeerId, mode: self.mode)
    }
    
    func updatedBotStartPayload(_ botStartPayload: String?) -> ChatPresentationInterfaceState {
        return ChatPresentationInterfaceState(interfaceState: self.interfaceState, chatLocation: self.chatLocation, peer: self.peer, inputTextPanelState: self.inputTextPanelState, recordedMediaPreview: self.recordedMediaPreview, inputQueryResults: self.inputQueryResults, inputMode: self.inputMode, titlePanelContexts: self.titlePanelContexts, keyboardButtonsMessage: self.keyboardButtonsMessage, pinnedMessageId: self.pinnedMessageId, pinnedMessage: self.pinnedMessage, peerIsBlocked: self.peerIsBlocked, peerIsMuted: self.peerIsMuted, canReportPeer: self.canReportPeer, chatHistoryState: self.chatHistoryState, botStartPayload: botStartPayload, urlPreview: self.urlPreview, editingUrlPreview: self.editingUrlPreview, search: self.search, searchQuerySuggestionResult: self.searchQuerySuggestionResult, chatWallpaper: self.chatWallpaper, theme: self.theme, strings: self.strings, fontSize: self.fontSize, accountPeerId: self.accountPeerId, mode: self.mode)
    }
    
    func updatedChatHistoryState(_ chatHistoryState: ChatHistoryNodeHistoryState?) -> ChatPresentationInterfaceState {
        return ChatPresentationInterfaceState(interfaceState: self.interfaceState, chatLocation: self.chatLocation, peer: self.peer, inputTextPanelState: self.inputTextPanelState, recordedMediaPreview: self.recordedMediaPreview, inputQueryResults: self.inputQueryResults, inputMode: self.inputMode, titlePanelContexts: self.titlePanelContexts, keyboardButtonsMessage: self.keyboardButtonsMessage, pinnedMessageId: self.pinnedMessageId, pinnedMessage: self.pinnedMessage, peerIsBlocked: self.peerIsBlocked, peerIsMuted: self.peerIsMuted, canReportPeer: self.canReportPeer, chatHistoryState: chatHistoryState, botStartPayload: self.botStartPayload, urlPreview: self.urlPreview, editingUrlPreview: self.editingUrlPreview, search: self.search, searchQuerySuggestionResult: self.searchQuerySuggestionResult, chatWallpaper: self.chatWallpaper, theme: self.theme, strings: self.strings, fontSize: self.fontSize, accountPeerId: self.accountPeerId, mode: self.mode)
    }
    
    func updatedUrlPreview(_ urlPreview: (String, TelegramMediaWebpage)?) -> ChatPresentationInterfaceState {
        return ChatPresentationInterfaceState(interfaceState: self.interfaceState, chatLocation: self.chatLocation, peer: self.peer, inputTextPanelState: self.inputTextPanelState, recordedMediaPreview: self.recordedMediaPreview, inputQueryResults: self.inputQueryResults, inputMode: self.inputMode, titlePanelContexts: self.titlePanelContexts, keyboardButtonsMessage: self.keyboardButtonsMessage, pinnedMessageId: self.pinnedMessageId, pinnedMessage: self.pinnedMessage, peerIsBlocked: self.peerIsBlocked, peerIsMuted: self.peerIsMuted, canReportPeer: self.canReportPeer, chatHistoryState: self.chatHistoryState, botStartPayload: self.botStartPayload, urlPreview: urlPreview, editingUrlPreview: self.editingUrlPreview, search: self.search, searchQuerySuggestionResult: self.searchQuerySuggestionResult, chatWallpaper: self.chatWallpaper, theme: self.theme, strings: self.strings, fontSize: self.fontSize, accountPeerId: self.accountPeerId, mode: self.mode)
    }
    
    func updatedEditingUrlPreview(_ editingUrlPreview: (String, TelegramMediaWebpage)?) -> ChatPresentationInterfaceState {
        return ChatPresentationInterfaceState(interfaceState: self.interfaceState, chatLocation: self.chatLocation, peer: self.peer, inputTextPanelState: self.inputTextPanelState, recordedMediaPreview: self.recordedMediaPreview, inputQueryResults: self.inputQueryResults, inputMode: self.inputMode, titlePanelContexts: self.titlePanelContexts, keyboardButtonsMessage: self.keyboardButtonsMessage, pinnedMessageId: self.pinnedMessageId, pinnedMessage: self.pinnedMessage, peerIsBlocked: self.peerIsBlocked, peerIsMuted: self.peerIsMuted, canReportPeer: self.canReportPeer, chatHistoryState: self.chatHistoryState, botStartPayload: self.botStartPayload, urlPreview: self.urlPreview, editingUrlPreview: editingUrlPreview, search: self.search, searchQuerySuggestionResult: self.searchQuerySuggestionResult, chatWallpaper: self.chatWallpaper, theme: self.theme, strings: self.strings, fontSize: self.fontSize, accountPeerId: self.accountPeerId, mode: self.mode)
    }
    
    func updatedSearch(_ search: ChatSearchData?) -> ChatPresentationInterfaceState {
        return ChatPresentationInterfaceState(interfaceState: self.interfaceState, chatLocation: self.chatLocation, peer: self.peer, inputTextPanelState: self.inputTextPanelState, recordedMediaPreview: self.recordedMediaPreview, inputQueryResults: self.inputQueryResults, inputMode: self.inputMode, titlePanelContexts: self.titlePanelContexts, keyboardButtonsMessage: self.keyboardButtonsMessage, pinnedMessageId: self.pinnedMessageId, pinnedMessage: self.pinnedMessage, peerIsBlocked: self.peerIsBlocked, peerIsMuted: self.peerIsMuted, canReportPeer: self.canReportPeer, chatHistoryState: self.chatHistoryState, botStartPayload: self.botStartPayload, urlPreview: self.urlPreview, editingUrlPreview: self.editingUrlPreview, search: search, searchQuerySuggestionResult: self.searchQuerySuggestionResult, chatWallpaper: self.chatWallpaper, theme: self.theme, strings: self.strings, fontSize: self.fontSize, accountPeerId: self.accountPeerId, mode: self.mode)
    }
    
    func updatedSearchQuerySuggestionResult(_ f: (ChatPresentationInputQueryResult?) -> ChatPresentationInputQueryResult?) -> ChatPresentationInterfaceState {
        return ChatPresentationInterfaceState(interfaceState: self.interfaceState, chatLocation: self.chatLocation, peer: self.peer, inputTextPanelState: self.inputTextPanelState, recordedMediaPreview: self.recordedMediaPreview, inputQueryResults: self.inputQueryResults, inputMode: self.inputMode, titlePanelContexts: self.titlePanelContexts, keyboardButtonsMessage: self.keyboardButtonsMessage, pinnedMessageId: self.pinnedMessageId, pinnedMessage: self.pinnedMessage, peerIsBlocked: self.peerIsBlocked, peerIsMuted: self.peerIsMuted, canReportPeer: self.canReportPeer, chatHistoryState: self.chatHistoryState, botStartPayload: self.botStartPayload, urlPreview: self.urlPreview, editingUrlPreview: self.editingUrlPreview, search: self.search, searchQuerySuggestionResult: f(self.searchQuerySuggestionResult), chatWallpaper: self.chatWallpaper, theme: self.theme, strings: self.strings, fontSize: self.fontSize, accountPeerId: self.accountPeerId, mode: self.mode)
    }
    
    func updatedMode(_ mode: ChatControllerPresentationMode) -> ChatPresentationInterfaceState {
        return ChatPresentationInterfaceState(interfaceState: self.interfaceState, chatLocation: self.chatLocation, peer: self.peer, inputTextPanelState: self.inputTextPanelState, recordedMediaPreview: self.recordedMediaPreview, inputQueryResults: self.inputQueryResults, inputMode: self.inputMode, titlePanelContexts: self.titlePanelContexts, keyboardButtonsMessage: self.keyboardButtonsMessage, pinnedMessageId: self.pinnedMessageId, pinnedMessage: self.pinnedMessage, peerIsBlocked: self.peerIsBlocked, peerIsMuted: self.peerIsMuted, canReportPeer: self.canReportPeer, chatHistoryState: self.chatHistoryState, botStartPayload: self.botStartPayload, urlPreview: self.urlPreview, editingUrlPreview: self.editingUrlPreview, search: self.search, searchQuerySuggestionResult: self.searchQuerySuggestionResult, chatWallpaper: self.chatWallpaper, theme: self.theme, strings: self.strings, fontSize: self.fontSize, accountPeerId: self.accountPeerId, mode: mode)
    }
}

func canSendMessagesToChat(_ state: ChatPresentationInterfaceState) -> Bool {
    if let peer = state.peer {
        if canSendMessagesToPeer(peer) {
            return true
        } else {
            return false
        }
    } else {
        return false
    }
}
