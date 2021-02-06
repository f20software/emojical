//
//  ObserverList.swift
//  Emojical
//
//  Created by Alexander Rogachev on 13.07.2020.
//  Copyright © 2020 Feed Me LLC. All rights reserved.
//

import Foundation
import os.lock

/// List that stores weak references to observing objects and associated observer values.
final class ObserverList<T> {

    /// List of observers.
    private var observers: [Observer<T>] = []

    /// Lock to ensure thread safety when modifying the list.
    private var lockRef = os_unfair_lock_s()

    /// Adds new observer.
    ///
    /// - parameters:
    ///   - disposable: Object that determines life span of an observable. When
    ///     disposable is deallocated, the observer is removed from the observer
    ///     list.
    ///   - observer: Observer value. Can be anything but most likely should be
    ///     some kind of a executable closure/block.
    func addObserver(_ disposable: AnyObject, _ observer: T) {
        os_unfair_lock_lock(&lockRef)
        cleanUpDisposedObservers()
        if !observers.contains(where: { $0.disposable === disposable }) {
            observers.append(Observer(disposable: disposable, observer: observer))
        }
        os_unfair_lock_unlock(&lockRef)
    }

    /// Explicitly removes an observer without waiting for it to deallocate.
    ///
    /// - parameters:
    ///   - disposable: Observer's "parent" to identify the observer to remove.
    func removeObserver(_ disposable: AnyObject) {
        os_unfair_lock_lock(&lockRef)
        cleanUpDisposedObservers()
        observers.removeAll(where: { $0.disposable === disposable })
        os_unfair_lock_unlock(&lockRef)
    }

    /// Goes through the list of currently alive observers and invokes given
    /// block on them.
    ///
    /// - parameters:
    ///   - block: Block to execute for each observer.
    func forEach(block: (T) -> Void) {
        os_unfair_lock_lock(&lockRef)
        cleanUpDisposedObservers()
        for observer in observers {
            block(observer.observer)
        }
        os_unfair_lock_unlock(&lockRef)
    }

    /// Checks if there are currently no valid observers in the list.
    var isEmpty: Bool {
        os_unfair_lock_lock(&lockRef)
        cleanUpDisposedObservers()
        os_unfair_lock_unlock(&lockRef)

        return observers.isEmpty
    }

    // MARK: - Private helpers

    private func cleanUpDisposedObservers() {
        observers = observers.filter { $0.disposable != nil }
    }

    // MARK: - Supplementary data classes

    final class Observer<T> {
        weak var disposable: AnyObject?
        let observer: T

        init(disposable: AnyObject, observer: T) {
            self.disposable = disposable
            self.observer = observer
        }
    }
}
