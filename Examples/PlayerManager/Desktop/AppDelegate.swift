import Cocoa
import ComposableArchitecture
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let contentView = AudioPlayerView(
            store: Store(
                initialState: AudioPlayerFeature.State(
                    book: Book.dummyBook,
                    currentChapter: Chapter.dummyChapter(1)
                ),
                reducer: { AudioPlayerFeature() }
            )
        ).edgesIgnoringSafeArea([.all])
        
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 500),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        window.center()
        window.setFrameAutosaveName("Main Window")
        if !_XCTIsTesting {
            window.contentView = NSHostingView(rootView: contentView)
            window.makeKeyAndOrderFront(nil)
        }
    }
}
