import Foundation
import Postbox
import SwiftSignalKit
import TelegramCore
import Display

public enum ChatFinishMediaRecordingAction {
    case dismiss
    case preview
    case send
}

final class ChatPanelInterfaceInteractionStatuses {
    let editingMessage: Signal<Bool, NoError>
    let startingBot: Signal<Bool, NoError>
    let unblockingPeer: Signal<Bool, NoError>
    let searching: Signal<Bool, NoError>
    let loadingMessage: Signal<Bool, NoError>
    
    init(editingMessage: Signal<Bool, NoError>, startingBot: Signal<Bool, NoError>, unblockingPeer: Signal<Bool, NoError>, searching: Signal<Bool, NoError>, loadingMessage: Signal<Bool, NoError>) {
        self.editingMessage = editingMessage
        self.startingBot = startingBot
        self.unblockingPeer = unblockingPeer
        self.searching = searching
        self.loadingMessage = loadingMessage
    }
}

enum ChatPanelSearchNavigationAction {
    case earlier
    case later
}

final class ChatPanelInterfaceInteraction {
    let setupReplyMessage: (MessageId) -> Void
    let setupEditMessage: (MessageId) -> Void
    let beginMessageSelection: ([MessageId]) -> Void
    let deleteSelectedMessages: () -> Void
    let forwardSelectedMessages: () -> Void
    let shareSelectedMessages: () -> Void
    let updateTextInputState: (@escaping (ChatTextInputState) -> ChatTextInputState) -> Void
    let updateInputModeAndDismissedButtonKeyboardMessageId: ((ChatPresentationInterfaceState) -> (ChatInputMode, MessageId?)) -> Void
    let editMessage: () -> Void
    let beginMessageSearch: (ChatSearchDomain) -> Void
    let dismissMessageSearch: () -> Void
    let updateMessageSearch: (String) -> Void
    let navigateMessageSearch: (ChatPanelSearchNavigationAction) -> Void
    let openCalendarSearch: () -> Void
    let toggleMembersSearch: (Bool) -> Void
    let navigateToMessage: (MessageId) -> Void
    let openPeerInfo: () -> Void
    let togglePeerNotifications: () -> Void
    let sendContextResult: (ChatContextResultCollection, ChatContextResult) -> Void
    let sendBotCommand: (Peer, String) -> Void
    let sendBotStart: (String?) -> Void
    let botSwitchChatWithPayload: (PeerId, String) -> Void
    let beginMediaRecording: (Bool) -> Void
    let finishMediaRecording: (ChatFinishMediaRecordingAction) -> Void
    let stopMediaRecording: () -> Void
    let lockMediaRecording: () -> Void
    let deleteRecordedMedia: () -> Void
    let sendRecordedMedia: () -> Void
    let switchMediaRecordingMode: () -> Void
    let setupMessageAutoremoveTimeout: () -> Void
    let sendSticker: (TelegramMediaFile) -> Void
    let unblockPeer: () -> Void
    let pinMessage: (MessageId) -> Void
    let unpinMessage: () -> Void
    let reportPeer: () -> Void
    let dismissReportPeer: () -> Void
    let deleteChat: () -> Void
    let beginCall: () -> Void
    let toggleMessageStickerStarred: (MessageId) -> Void
    let presentController: (ViewController, Any?) -> Void
    let navigateFeed: () -> Void
    let openGrouping: () -> Void
    let toggleSilentPost: () -> Void
    let statuses: ChatPanelInterfaceInteractionStatuses?
    
    init(setupReplyMessage: @escaping (MessageId) -> Void, setupEditMessage: @escaping (MessageId) -> Void, beginMessageSelection: @escaping ([MessageId]) -> Void, deleteSelectedMessages: @escaping () -> Void, forwardSelectedMessages: @escaping () -> Void, shareSelectedMessages: @escaping () -> Void, updateTextInputState: @escaping ((ChatTextInputState) -> ChatTextInputState) -> Void, updateInputModeAndDismissedButtonKeyboardMessageId: @escaping ((ChatPresentationInterfaceState) -> (ChatInputMode, MessageId?)) -> Void, editMessage: @escaping () -> Void, beginMessageSearch: @escaping (ChatSearchDomain) -> Void, dismissMessageSearch: @escaping () -> Void, updateMessageSearch: @escaping (String) -> Void, navigateMessageSearch: @escaping (ChatPanelSearchNavigationAction) -> Void, openCalendarSearch: @escaping () -> Void, toggleMembersSearch: @escaping (Bool) -> Void, navigateToMessage: @escaping (MessageId) -> Void, openPeerInfo: @escaping () -> Void, togglePeerNotifications: @escaping () -> Void, sendContextResult: @escaping (ChatContextResultCollection, ChatContextResult) -> Void, sendBotCommand: @escaping (Peer, String) -> Void, sendBotStart: @escaping (String?) -> Void, botSwitchChatWithPayload: @escaping (PeerId, String) -> Void, beginMediaRecording: @escaping (Bool) -> Void, finishMediaRecording: @escaping (ChatFinishMediaRecordingAction) -> Void, stopMediaRecording: @escaping () -> Void, lockMediaRecording: @escaping () -> Void, deleteRecordedMedia: @escaping () -> Void, sendRecordedMedia: @escaping () -> Void, switchMediaRecordingMode: @escaping () -> Void, setupMessageAutoremoveTimeout: @escaping () -> Void, sendSticker: @escaping (TelegramMediaFile) -> Void, unblockPeer: @escaping () -> Void, pinMessage: @escaping (MessageId) -> Void, unpinMessage: @escaping () -> Void, reportPeer: @escaping () -> Void, dismissReportPeer: @escaping () -> Void, deleteChat: @escaping () -> Void, beginCall: @escaping () -> Void, toggleMessageStickerStarred: @escaping (MessageId) -> Void, presentController: @escaping (ViewController, Any?) -> Void, navigateFeed: @escaping () -> Void, openGrouping: @escaping () -> Void, toggleSilentPost: @escaping () -> Void, statuses: ChatPanelInterfaceInteractionStatuses?) {
        self.setupReplyMessage = setupReplyMessage
        self.setupEditMessage = setupEditMessage
        self.beginMessageSelection = beginMessageSelection
        self.deleteSelectedMessages = deleteSelectedMessages
        self.forwardSelectedMessages = forwardSelectedMessages
        self.shareSelectedMessages = shareSelectedMessages
        self.updateTextInputState = updateTextInputState
        self.updateInputModeAndDismissedButtonKeyboardMessageId = updateInputModeAndDismissedButtonKeyboardMessageId
        self.editMessage = editMessage
        self.beginMessageSearch = beginMessageSearch
        self.dismissMessageSearch = dismissMessageSearch
        self.updateMessageSearch = updateMessageSearch
        self.navigateMessageSearch = navigateMessageSearch
        self.openCalendarSearch = openCalendarSearch
        self.toggleMembersSearch = toggleMembersSearch
        self.navigateToMessage = navigateToMessage
        self.openPeerInfo = openPeerInfo
        self.togglePeerNotifications = togglePeerNotifications
        self.sendContextResult = sendContextResult
        self.sendBotCommand = sendBotCommand
        self.sendBotStart = sendBotStart
        self.botSwitchChatWithPayload = botSwitchChatWithPayload
        self.beginMediaRecording = beginMediaRecording
        self.finishMediaRecording = finishMediaRecording
        self.stopMediaRecording = stopMediaRecording
        self.lockMediaRecording = lockMediaRecording
        self.deleteRecordedMedia = deleteRecordedMedia
        self.sendRecordedMedia = sendRecordedMedia
        self.switchMediaRecordingMode = switchMediaRecordingMode
        self.setupMessageAutoremoveTimeout = setupMessageAutoremoveTimeout
        self.sendSticker = sendSticker
        self.unblockPeer = unblockPeer
        self.pinMessage = pinMessage
        self.unpinMessage = unpinMessage
        self.reportPeer = reportPeer
        self.dismissReportPeer = dismissReportPeer
        self.deleteChat = deleteChat
        self.beginCall = beginCall
        self.toggleMessageStickerStarred = toggleMessageStickerStarred
        self.presentController = presentController
        self.navigateFeed = navigateFeed
        self.openGrouping = openGrouping
        self.toggleSilentPost = toggleSilentPost
        self.statuses = statuses
    }
}
