import Combine
import ComposableArchitecture
import ComposableAVPlayer
import AVFoundation
import XCTest

#if os(iOS)
  import PlayerManagerMobile
#elseif os(macOS)
  import PlayerManagerDesktop
#endif

@MainActor
final class CommonTests: XCTestCase {
    
    enum SomeError: Error {
        case invalidURL
    }
    
    typealias Store = TestStoreOf<AudioPlayerFeature>
    
    let rateStep: Float = 0.25
    let backwardSeconds: Double = 5
    let forwardSeconds: Double = 10
    static let testError = AudioPlayerClient.Error(SomeError.invalidURL)
    static let testNotification = Notification(name: AVPlayerItem.didPlayToEndTimeNotification)
    
    var duration: Double = 0 {
        didSet { durationStream.continuation.yield(duration) }
    }
    
    var progress: Double = 0 {
        didSet { progressStream.continuation.yield(progress) }
    }
    
    var rate: Float = 1 {
        didSet { rateStream.continuation.yield(rate) }
    }
    
    var error = testError {
        didSet { errorStream.continuation.yield(error) }
    }
    
    var didPlayToEndTimeNotification = testNotification {
        didSet { didPlayToEndTimeStream.continuation.yield(didPlayToEndTimeNotification) }
    }
    
    var durationStream = AsyncStream.makeStream(of: Double.self)
    var errorStream = AsyncStream.makeStream(of: AudioPlayerClient.Error.self)
    var rateStream = AsyncStream.makeStream(of: Float.self)
    var progressStream = AsyncStream.makeStream(of: TimeInterval.self)
    var didPlayToEndTimeStream = AsyncStream.makeStream(of: Notification.self)
    
    func testStartObservingOnAppear() async throws {
        let store = makeStore()
        
        await store.send(.onAppear)
        
        await store.receive(.audioPlayerClient(.startObserving))
        
        await store.receive(.playButtonTapped)
        
        await store.receive(.audioPlayerClient(.play(url: store.state.currentChapter.playUrl))) {
            $0.audioPlayerClient.isPlaying = true
        }
        
        await store.receive(.audioPlayerClient(.startListenProgress))
        await store.receive(.audioPlayerClient(.update(rate: store.state.audioPlayerClient.rate)))
        await store.receive(.audioPlayerClient(.startListenDuration))

        await store.receive(.audioPlayerClient(.startListenRate))
        await store.receive(.audioPlayerClient(.startListenDidPlayToEndTime))
        await store.receive(.audioPlayerClient(.startListenError))
        
        await finishObservers(store: store)
    }
    
    func testUpdateRate() async throws {
        let store = makeStore()
        
        await store.send(.changeRateButtonTapped)
        let newRate = store.state.audioPlayerClient.rate + rateStep
        await store.receive(.audioPlayerClient(.update(rate: newRate))) {
            $0.audioPlayerClient.rate = newRate
        }
        
        await store.send(.audioPlayerClient(.startListenRate))
        
        rate = .zero
        await store.receive(.audioPlayerClient(.rateUpdated(rate)))
        
        rate = 1
        await store.receive(.audioPlayerClient(.rateUpdated(rate))) {
            $0.audioPlayerClient.isPlaying = true
        }
        
        await finishObservers(store: store)
    }
    
    func testUpdateDuration() async throws {
        let store = makeStore()
        
        await store.send(.audioPlayerClient(.startListenDuration))
        
        duration = 200
        await store.receive(.audioPlayerClient(.durationUpdated(duration))) {
            $0.audioPlayerClient.duration = self.duration
        }
        
        await finishObservers(store: store)
    }
    
    func testUpdateProgress() async throws {
        let store = makeStore()
        
        await store.send(.audioPlayerClient(.startListenProgress))
        
        progress += 20
        await store.receive(.audioPlayerClient(.progressUpdated(progress))) {
            $0.audioPlayerClient.progress = self.progress
        }
        
        await finishObservers(store: store)
    }
    
    func testReceiveError() async throws {
        let store = makeStore()
        
        await store.send(.audioPlayerClient(.startListenError))
        
        error = Self.testError
        await store.receive(.audioPlayerClient(.errorReceived(error)))
        
        await finishObservers(store: store)
    }
    
    func testDidPlayToEndTimeNotification() async throws {
        let store = makeStore()
        
        await store.send(.audioPlayerClient(.startListenDidPlayToEndTime))
        
        didPlayToEndTimeNotification = Self.testNotification
        await store.receive(.audioPlayerClient(.didPlayToEndTimeReceived))
        
        await store.receive(.skipToNextButtonTapped) {
            $0.currentChapter = store.state.book.chapters[1]
        }
        await store.receive(.audioPlayerClient(.skipToNext(url: store.state.currentChapter.playUrl)))
        await store.receive(.audioPlayerClient(.update(rate: store.state.audioPlayerClient.rate)))
        
        await finishObservers(store: store)
    }
    
    func testSkipBackward() async throws {
        let store = makeStore()
        
        await store.send(.audioPlayerClient(.startListenProgress))
        
        progress = 20
        await store.receive(.audioPlayerClient(.progressUpdated(progress))) {
            $0.audioPlayerClient.progress = self.progress
        }
        
        await store.send(.skipBackwardButtonTapped)
        
        await store.receive(.audioPlayerClient(.skipBackward(seconds: backwardSeconds)))
        await store.receive(.audioPlayerClient(.seek(time: store.state.audioPlayerClient.progress - backwardSeconds))) {
            $0.audioPlayerClient.progress = store.state.audioPlayerClient.progress - self.backwardSeconds
        }
        
        await finishObservers(store: store)
    }
    
    func testSkipForward() async throws {
        let store = makeStore()
        
        await store.send(.audioPlayerClient(.startListenDuration))
        duration = 200
        await store.receive(.audioPlayerClient(.durationUpdated(duration))) {
            $0.audioPlayerClient.duration = self.duration
        }
        
        await store.send(.audioPlayerClient(.startListenProgress))
        progress = 20
        await store.receive(.audioPlayerClient(.progressUpdated(progress))) {
            $0.audioPlayerClient.progress = self.progress
        }
        
        await store.send(.skipForwardButtonTapped)
        
        await store.receive(.audioPlayerClient(.skipForward(seconds: forwardSeconds)))
        await store.receive(.audioPlayerClient(.seek(time: store.state.audioPlayerClient.progress + forwardSeconds))) {
            $0.audioPlayerClient.progress = store.state.audioPlayerClient.progress + self.forwardSeconds
        }
        
        await finishObservers(store: store)
    }
    
    func testSkipToNext() async throws {
        let store = makeStore()
        
        await store.send(.skipToNextButtonTapped) {
            let currentIndex = store.state.book.chapters.firstIndex(of: store.state.currentChapter)!
            
            $0.currentChapter = store.state.book.chapters[currentIndex + 1]
        }
        await store.receive(.audioPlayerClient(.skipToNext(url: store.state.currentChapter.playUrl)))
        await store.receive(.audioPlayerClient(.update(rate: store.state.audioPlayerClient.rate)))        
    }
    
    func testSkipToPrevious() async throws {
        let store = makeStore(currentChapter: Book.dummyBook.chapters.last!)
        
        await store.send(.skipToPreviousButtonTapped) {
            let currentIndex = store.state.book.chapters.firstIndex(of: store.state.currentChapter)!
            
            $0.currentChapter = store.state.book.chapters[currentIndex - 1]
        }
        await store.receive(.audioPlayerClient(.skipToPrevious(url: store.state.currentChapter.playUrl)))
        await store.receive(.audioPlayerClient(.update(rate: store.state.audioPlayerClient.rate)))
    }
    
    func testPause() async throws {
        let store = makeStore()
        
        await store.send(.playButtonTapped)
        await store.receive(.audioPlayerClient(.play(url: store.state.currentChapter.playUrl))) {
            $0.audioPlayerClient.isPlaying = true
        }
        await store.receive(.audioPlayerClient(.update(rate: store.state.audioPlayerClient.rate)))
        
        await store.send(.playButtonTapped)
        await store.receive(.audioPlayerClient(.pause)) {
            $0.audioPlayerClient.isPlaying = false
        }
        
        await finishObservers(store: store)
    }
}

extension CommonTests {
    
    override func setUp() {
        duration = 0
        progress = 0
        rate = 1
        error = Self.testError
        didPlayToEndTimeNotification = Self.testNotification
        
        durationStream = AsyncStream.makeStream(of: Double.self)
        errorStream = AsyncStream.makeStream(of: AudioPlayerClient.Error.self)
        rateStream = AsyncStream.makeStream(of: Float.self)
        progressStream = AsyncStream.makeStream(of: TimeInterval.self)
        didPlayToEndTimeStream = AsyncStream.makeStream(of: Notification.self)
    }
    
    func finishObservers(store: Store) async {
        durationStream.continuation.finish()
        errorStream.continuation.finish()
        rateStream.continuation.finish()
        progressStream.continuation.finish()
        didPlayToEndTimeStream.continuation.finish()
        
        await store.finish()
    }
    
    func makeStore(currentChapter: Chapter = Chapter.dummyChapter(0)) -> Store {
        
        return Store(
            initialState: AudioPlayerFeature.State(
                book: Book.dummyBook,
                currentChapter: currentChapter,
                audioPlayerClient: AudioPlayerClientFeature.State()
            )
        ) {
            AudioPlayerFeature()
        } withDependencies: {
            $0.audioPlayer.play = { @Sendable _ in }
            $0.audioPlayer.pause = { }
            $0.audioPlayer.setRate = { @Sendable _ in }
            $0.audioPlayer.seekTime = { @Sendable _ in }
            $0.audioPlayer.duration = {
                return await self.durationStream.stream
            }
            $0.audioPlayer.rate = {
                return await self.rateStream.stream
            }
            $0.audioPlayer.progress = {
                return await self.progressStream.stream
            }
            $0.audioPlayer.error = {
                return await self.errorStream.stream
            }
            $0.audioPlayer.didPlayToEndTime = {
                return await self.didPlayToEndTimeStream.stream
            }
        }
    }
}
