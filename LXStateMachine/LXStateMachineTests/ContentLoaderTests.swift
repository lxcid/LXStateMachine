//
//  ContentLoaderTests.swift
//  LXStateMachine
//
//  Created by Stan Chang Khin Boon on 29/9/15.
//  Copyright © 2015 lxcid. All rights reserved.
//

import XCTest

@testable import LXStateMachine

class ContentLoaderTests: XCTestCase {
    var contentLoader = ContentLoader()
    
    override func tearDown() {
        super.tearDown()
        self.contentLoader = ContentLoader()
    }
    
    func testLoadingContent() {
        let expectation = self.expectationWithDescription("Complete loading content with content loader.")
        
        let stateMachine = self.contentLoader.stateMachine
        let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: "https://google.com/")!) { (data, response, error) -> Void in
            XCTAssertEqual(stateMachine.currentState, LoadState.LoadingContent)
            stateMachine.sendEvent(LoadEvent.FinishLoadingContent(data, response, error))
            expectation.fulfill()
        }
        XCTAssertEqual(stateMachine.currentState, LoadState.Initial)
        stateMachine.sendEvent(LoadEvent.LoadContent(task))
        XCTAssertEqual(stateMachine.currentState, LoadState.LoadingContent)
        self.waitForExpectationsWithTimeout(3.0) { (optError) -> Void in
            if let error = optError {
                XCTFail("\(error)")
            } else {
                XCTAssertEqual(stateMachine.currentState, LoadState.ContentLoaded)
            }
        }
    }
}

enum LoadEvent : EventType {
    case LoadContent(NSURLSessionTask)
    case FinishLoadingContent(NSData?, NSURLResponse?, NSError?)
}

enum LoadState : StateType {
    typealias Event = LoadEvent
    
    case Initial
    case LoadingContent
    case ContentLoaded
    case Error
}

class ContentLoader : StateMachineDelegate {
    let stateMachine = StateMachine<ContentLoader>(initialState: .Initial)
    
    init() {
        self.stateMachine.delegate = self
    }
    
    typealias State = LoadState
    
    func stateMachine(stateMachine: AnyObject, nextStateForEvent event: LoadEvent, inCurrentState currentState: LoadState) -> LoadState? {
        switch (currentState, event) {
        case (LoadState.Initial, LoadEvent.LoadContent):
            return .LoadingContent
        case (LoadState.LoadingContent, LoadEvent.FinishLoadingContent(_, _, let optError)):
            if let _ = optError {
                return .Error
            } else {
                return .ContentLoaded
            }
        default:
            return nil
        }
    }
    
    func stateMachine(stateMachine: AnyObject, willPerformTransition transition: Transition<LoadState>?) {
    }
    
    func stateMachine(stateMachine: AnyObject, didPerformTransition transition: Transition<LoadState>?) {
        guard let t = transition else {
            return
        }
        switch t.event {
        case .LoadContent(let task):
            task.resume()
        case .FinishLoadingContent(let data, _, _):
            print(data)
            break
        }
    }
}
