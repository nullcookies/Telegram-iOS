import Foundation
import Display

private final class LegacyICloudFileController: LegacyController, UIDocumentPickerDelegate {
    let completion: ([URL]) -> Void
    
    init(presentation: LegacyControllerPresentation, theme: PresentationTheme?, completion: @escaping ([URL]) -> Void) {
        self.completion = completion
        
        super.init(presentation: presentation, theme: theme)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.completion([])
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        self.completion(urls)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        self.completion([url])
    }
}

func legacyICloudFileController(theme: PresentationTheme, completion: @escaping ([URL]) -> Void) -> ViewController {
    var dismissImpl: (() -> Void)?
    let legacyController = LegacyICloudFileController(presentation: .modal(animateIn: true), theme: theme, completion: { urls in
        dismissImpl?()
        completion(urls)
    })
    legacyController.statusBar.statusBarStyle = .Black
    
    let documentTypes: [String] = [
        "public.composite-content",
        "public.text",
        "public.image",
        "public.audio",
        "public.video",
        "public.movie",
        "public.font",
        "org.telegram.Telegram.webp",
        "com.apple.iwork.pages.pages",
        "com.apple.iwork.numbers.numbers",
        "com.apple.iwork.keynote.key"
    ]
    
    let controller = UIDocumentPickerViewController(documentTypes: documentTypes, in: .open)
    controller.delegate = legacyController
    
    legacyController.presentationCompleted = { [weak legacyController] in
        if let legacyController = legacyController {
            legacyController.view.window?.rootViewController?.present(controller, animated: true)
        }
    }
    
    dismissImpl = { [weak legacyController] in
        if let legacyController = legacyController {
            legacyController.dismiss()
        }
    }
    legacyController.bind(controller: UIViewController())
    return legacyController
}
