import Foundation
import TelegramCore
import Postbox
import Display

struct PossibleContextQueryTypes: OptionSet {
    var rawValue: Int32
    
    init() {
        self.rawValue = 0
    }
    
    init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    static let emoji = PossibleContextQueryTypes(rawValue: (1 << 0))
    static let hashtag = PossibleContextQueryTypes(rawValue: (1 << 1))
    static let mention = PossibleContextQueryTypes(rawValue: (1 << 2))
    static let command = PossibleContextQueryTypes(rawValue: (1 << 3))
    static let contextRequest = PossibleContextQueryTypes(rawValue: (1 << 4))
}

private func makeScalar(_ c: Character) -> Character {
    return c
}

private let spaceScalar = " " as UnicodeScalar
private let newlineScalar = "\n" as UnicodeScalar
private let hashScalar = "#" as UnicodeScalar
private let atScalar = "@" as UnicodeScalar
private let slashScalar = "/" as UnicodeScalar
private let alphanumerics = CharacterSet.alphanumerics

func textInputStateContextQueryRangeAndType(_ inputState: ChatTextInputState) -> [(NSRange, PossibleContextQueryTypes, NSRange?)] {
    if inputState.selectionRange.count != 0 {
        return []
    }
    
    let inputText = inputState.inputText
    let inputString: NSString = inputText.string as NSString
    var results: [(NSRange, PossibleContextQueryTypes, NSRange?)] = []
    let inputLength = inputString.length
    
    if inputLength != 0 {
        if inputString.hasPrefix("@") && inputLength != 1 {
            let startIndex = 1
            var index = startIndex
            var contextAddressRange: NSRange?
            
            while true {
                if index == inputLength {
                    break
                }
                if let c = UnicodeScalar(inputString.character(at: index)) {
                    if c == " " {
                        if index != startIndex {
                            contextAddressRange = NSRange(location: startIndex, length: index - startIndex)
                            index += 1
                        }
                        break
                    } else {
                        if !((c >= "a" && c <= "z") || (c >= "A" && c <= "Z") || (c >= "0" && c <= "9") || c == "_") {
                            break
                        }
                    }
                    
                    if index == inputLength {
                        break
                    } else {
                        index += 1
                    }
                } else {
                    index += 1
                }
            }
            
            if let contextAddressRange = contextAddressRange {
                results.append((contextAddressRange, [.contextRequest], NSRange(location: index, length: inputLength - index)))
            }
        }
        
        let maxIndex = min(inputState.selectionRange.lowerBound, inputLength)
        if maxIndex == 0 {
            return results
        }
        var index = maxIndex - 1
        
        var possibleQueryRange: NSRange?
        
        if (inputString as String).isSingleEmoji {
            return [(NSRange(location: 0, length: inputLength), [.emoji], nil)]
        }
        
        var possibleTypes = PossibleContextQueryTypes([.command, .mention, .hashtag])
        var definedType = false
        
        while true {
            if let c = UnicodeScalar(inputString.character(at: index)) {
                if c == spaceScalar || c == newlineScalar {
                    possibleTypes = []
                } else if c == hashScalar {
                    possibleTypes = possibleTypes.intersection([.hashtag])
                    definedType = true
                    index += 1
                    possibleQueryRange = NSRange(location: index, length: maxIndex - index)
                    break
                } else if c == atScalar {
                    possibleTypes = possibleTypes.intersection([.mention])
                    definedType = true
                    index += 1
                    possibleQueryRange = NSRange(location: index, length: maxIndex - index)
                    break
                } else if c == slashScalar {
                    possibleTypes = possibleTypes.intersection([.command])
                    definedType = true
                    index += 1
                    possibleQueryRange = NSRange(location: index, length: maxIndex - index)
                    break
                }
            }
            
            if index == 0 {
                break
            } else {
                index -= 1
                possibleQueryRange = NSRange(location: index, length: maxIndex - index)
            }
        }
        
        if let possibleQueryRange = possibleQueryRange, definedType && !possibleTypes.isEmpty {
            results.append((possibleQueryRange, possibleTypes, nil))
        }
    }
    return results
}

func inputContextQueriesForChatPresentationIntefaceState(_ chatPresentationInterfaceState: ChatPresentationInterfaceState) -> [ChatPresentationInputQuery] {
    let inputState = chatPresentationInterfaceState.interfaceState.effectiveInputState
    let inputString: NSString = inputState.inputText.string as NSString
    var result: [ChatPresentationInputQuery] = []
    for (possibleQueryRange, possibleTypes, additionalStringRange) in textInputStateContextQueryRangeAndType(inputState) {
        let query = inputString.substring(with: possibleQueryRange)
        if possibleTypes == [.emoji] {
            result.append(.emoji(query))
        } else if possibleTypes == [.hashtag] {
            result.append(.hashtag(query))
        } else if possibleTypes == [.mention] {
            var types: ChatInputQueryMentionTypes = [.members]
            if possibleQueryRange.lowerBound == 1 {
                types.insert(.contextBots)
            }
            result.append(.mention(query: query, types: types))
        } else if possibleTypes == [.command] {
            result.append(.command(query))
        } else if possibleTypes == [.contextRequest], let additionalStringRange = additionalStringRange {
            let additionalString = inputString.substring(with: additionalStringRange)
            result.append(.contextRequest(addressName: query, query: additionalString))
        }
    }
    return result
}

func inputTextPanelStateForChatPresentationInterfaceState(_ chatPresentationInterfaceState: ChatPresentationInterfaceState, account: Account) -> ChatTextInputPanelState {
    var contextPlaceholder: NSAttributedString?
    loop: for (_, result) in chatPresentationInterfaceState.inputQueryResults {
        if case let .contextRequestResult(peer, _) = result, let botUser = peer as? TelegramUser, let botInfo = botUser.botInfo, let inlinePlaceholder = botInfo.inlinePlaceholder {
            let inputQueries = inputContextQueriesForChatPresentationIntefaceState(chatPresentationInterfaceState)
            for inputQuery in inputQueries {
                if case let .contextRequest(addressName, query) = inputQuery, query.isEmpty {
                    let baseFontSize: CGFloat = max(17.0, chatPresentationInterfaceState.fontSize.baseDisplaySize)
                    
                    let string = NSMutableAttributedString()
                    string.append(NSAttributedString(string: "@" + addressName, font: Font.regular(baseFontSize), textColor: UIColor.clear))
                    string.append(NSAttributedString(string: " " + inlinePlaceholder, font: Font.regular(baseFontSize), textColor: chatPresentationInterfaceState.theme.chat.inputPanel.inputPlaceholderColor))
                    contextPlaceholder = string
                }
            }
            
            break loop
        }
    }
    switch chatPresentationInterfaceState.inputMode {
        case .media:
            if contextPlaceholder == nil && chatPresentationInterfaceState.interfaceState.editMessage == nil && chatPresentationInterfaceState.interfaceState.composeInputState.inputText.length == 0 && chatPresentationInterfaceState.inputMode == .media(.gif) {
                let baseFontSize: CGFloat = max(17.0, chatPresentationInterfaceState.fontSize.baseDisplaySize)
                
                contextPlaceholder = NSAttributedString(string: "@gif", font: Font.regular(baseFontSize), textColor: chatPresentationInterfaceState.theme.chat.inputPanel.inputPlaceholderColor)
            }
            return ChatTextInputPanelState(accessoryItems: [.keyboard], contextPlaceholder: contextPlaceholder, mediaRecordingState: chatPresentationInterfaceState.inputTextPanelState.mediaRecordingState)
        case .inputButtons:
            return ChatTextInputPanelState(accessoryItems: [.keyboard], contextPlaceholder: contextPlaceholder, mediaRecordingState: chatPresentationInterfaceState.inputTextPanelState.mediaRecordingState)
        case .none, .text:
            if let _ = chatPresentationInterfaceState.interfaceState.editMessage {
                return ChatTextInputPanelState(accessoryItems: [], contextPlaceholder: contextPlaceholder, mediaRecordingState: chatPresentationInterfaceState.inputTextPanelState.mediaRecordingState)
            } else {
                if chatPresentationInterfaceState.interfaceState.composeInputState.inputText.length == 0 {
                    var accessoryItems: [ChatTextInputAccessoryItem] = []
                    if let peer = chatPresentationInterfaceState.peer as? TelegramSecretChat {
                        accessoryItems.append(.messageAutoremoveTimeout(peer.messageAutoremoveTimeout))
                    }
                    if let peer = chatPresentationInterfaceState.peer as? TelegramChannel, case .broadcast = peer.info, canSendMessagesToPeer(peer) {
                        accessoryItems.append(.silentPost(chatPresentationInterfaceState.interfaceState.silentPosting))
                    }
                    if let peer = chatPresentationInterfaceState.peer as? TelegramUser {
                        if let _ = peer.botInfo {
                            accessoryItems.append(.commands)
                        }
                    }
                    accessoryItems.append(.stickers)
                    if let message = chatPresentationInterfaceState.keyboardButtonsMessage, let _ = message.visibleButtonKeyboardMarkup {
                        accessoryItems.append(.inputButtons)
                    }
                    return ChatTextInputPanelState(accessoryItems: accessoryItems, contextPlaceholder: contextPlaceholder, mediaRecordingState: chatPresentationInterfaceState.inputTextPanelState.mediaRecordingState)
                } else {
                    return ChatTextInputPanelState(accessoryItems: [], contextPlaceholder: contextPlaceholder, mediaRecordingState: chatPresentationInterfaceState.inputTextPanelState.mediaRecordingState)
                }
            }
    }
}

func urlPreviewForPresentationInterfaceState() {
    
}
