//
//  StateMachine.swift
//  LXStateMachine
//
//  Created by Stan Chang Khin Boon on 29/9/15.
//  Copyright © 2015 lxcid. All rights reserved.
//

import Foundation

public protocol EventType {
}

public protocol StateType {
    typealias Event: EventType
}

public struct Transition<State: StateType> {
    public let event: State.Event
    public let fromState: State
    public let toState: State
    
    public init(event: State.Event, fromState: State, toState: State) {
        self.event = event
        self.fromState = fromState
        self.toState = toState
    }
}


public protocol StateMachineDelegate: class {
    typealias State: StateType
    
    // FIXME: (me@lxcid.com) Define `stateMachine` type as `AnyObject` instead of `StateMachine<Self>` to prevent requiring the conforming class to be final.
    func stateMachine(stateMachine: AnyObject, nextStateForEvent event: State.Event, inCurrentState currentState: State) -> State?
    func stateMachine(stateMachine: AnyObject, willPerformTransition transition: Transition<State>?)
    func stateMachine(stateMachine: AnyObject, didPerformTransition transition: Transition<State>?)
}

public class StateMachine<Delegate: StateMachineDelegate> {
    public var currentState: Delegate.State
    public weak var delegate: Delegate?
    
    public init(initialState: Delegate.State) {
        self.currentState = initialState
    }
    
    public func sendEvent(event: Delegate.State.Event) {
        guard let nextState = self.delegate?.stateMachine(self, nextStateForEvent: event, inCurrentState: self.currentState) else {
            return
        }
        let transition = Transition(event: event, fromState: self.currentState, toState: nextState)
        self.performTransition(transition)
    }
    
    public func performTransition(transition: Transition<Delegate.State>) {
        self.delegate?.stateMachine(self, willPerformTransition: transition)
        self.currentState = transition.toState
        self.delegate?.stateMachine(self, didPerformTransition: transition)
    }
}
