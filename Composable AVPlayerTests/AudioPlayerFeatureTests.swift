//
//  AudioPlayerFeatureTests.swift
//  Composable AVPlayerTests
//
//  Created by Anton Gorb on 08.01.2024.
//

import XCTest
import ComposableArchitecture
import Combine
import AVFoundation

@testable import Composable_AVPlayer

@MainActor
final class SwiftUITestTests: XCTestCase {
    
    enum SomeError: Error {
        case invalidURL
    }
    
    let rateStep: Float = 0.25
    let backwardSeconds: Double = 5
    let forwardSeconds: Double = 10
    static let testError = AudioPlayerClient.Error(SomeError.invalidURL)
    static let testNotification = Notification(name: AVPlayerItem.didPlayToEndTimeNotification)
    
    var duration: Double = 0 {
        didSet { durationEffect.send(duration) }
    }
    
    var progress: Double = 0 {
        didSet { progressEffect.send(progress) }
    }
    
    var rate: Float = 1 {
        didSet { rateEffect.send(rate) }
    }
    
    var error = testError {
        didSet { errorEffect.send(error) }
    }
    
    var didPlayToEndTimeNotification = testNotification {
        didSet { didPlayToEndTimeEffect.send(didPlayToEndTimeNotification) }
    }
    
    var durationEffect = PassthroughSubject<Double, Never>()
    var errorEffect = PassthroughSubject<AudioPlayerClient.Error, Never>()
    var rateEffect = PassthroughSubject<Float, Never>()
    var progressEffect = PassthroughSubject<TimeInterval, Never>()
    var didPlayToEndTimeEffect = PassthroughSubject<Notification, Never>()
    
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
        
        self.finishObservers()
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
        
        finishObservers()
    }
    
    func testUpdateDuration() async throws {
        let store = makeStore()
        
        await store.send(.audioPlayerClient(.startListenDuration))
        
        duration = 200
        await store.receive(.audioPlayerClient(.durationUpdated(duration))) {
            $0.audioPlayerClient.duration = self.duration
        }
        
        finishObservers()
    }
    
    func testUpdateProgress() async throws {
        let store = makeStore()
        
        await store.send(.audioPlayerClient(.startListenProgress))
        
        progress += 20
        await store.receive(.audioPlayerClient(.progressUpdated(progress))) {
            $0.audioPlayerClient.progress = self.progress
        }
        
        finishObservers()
    }
    
    func testReceiveError() async throws {
        let store = makeStore()
        
        await store.send(.audioPlayerClient(.startListenError))
        
        error = Self.testError
        await store.receive(.audioPlayerClient(.errorReceived(error)))
        
        finishObservers()
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
        
        finishObservers()
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
        
        finishObservers()
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
        
        finishObservers()
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
        
        finishObservers()
    }
}

extension SwiftUITestTests {
    
    override func setUp() {
        duration = 0
        progress = 0
        rate = 1
        error = Self.testError
        didPlayToEndTimeNotification = Self.testNotification
        
        durationEffect = PassthroughSubject<Double, Never>()
        errorEffect = PassthroughSubject<AudioPlayerClient.Error, Never>()
        rateEffect = PassthroughSubject<Float, Never>()
        progressEffect = PassthroughSubject<TimeInterval, Never>()
        didPlayToEndTimeEffect = PassthroughSubject<Notification, Never>()
    }
    
    func finishObservers() {
        durationEffect.send(completion: .finished)
        errorEffect.send(completion: .finished)
        rateEffect.send(completion: .finished)
        progressEffect.send(completion: .finished)
        didPlayToEndTimeEffect.send(completion: .finished)
    }
    
    func makeStore(currentChapter: Chapter = Chapter.dummyChapter(0)) -> TestStore<AudioPlayerFeature.State, AudioPlayerFeature.Action> {
        return TestStore(
            initialState: AudioPlayerFeature.State(
                book: Book.dummyBook,
                currentChapter: currentChapter,
                audioPlayerClient: AudioPlayerClientFeature.State()
            )
        ) {
            AudioPlayerFeature()
        } withDependencies: {
            $0.audioPlayer.play = { _ in }
            $0.audioPlayer.pause = { }
            $0.audioPlayer.setRate = { _ in }
            $0.audioPlayer.seekTime = { _ in }
            $0.audioPlayer.durationEffect = {
                return .publisher { self.durationEffect }
            }
            $0.audioPlayer.rateEffect = {
                return .publisher { self.rateEffect }
            }
            $0.audioPlayer.progressEffect = {
                return .publisher { self.progressEffect }
            }
            $0.audioPlayer.errorEffect = {
                return .publisher { self.errorEffect }
            }
            $0.audioPlayer.didPlayToEndTimeEffect = {
                return .publisher { self.didPlayToEndTimeEffect }
            }
        }
    }
}
