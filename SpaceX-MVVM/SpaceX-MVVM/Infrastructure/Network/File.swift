//
//  File.swift
//  SpaceX-MVVM
//
//  Created by Vivek Sehrawat on 13/08/23.
//

import Foundation

//
//class DefaultWorkItemProvider: WorkItemProvider {
//    func workItem(actionBlock: @escaping () -> ()) -> DispatchWorkItem? {
//        return nil
//    }
//}
//
//class SessionWatcher {
//    private var workItemProvider: WorkItemProvider
//    private var workItem: DispatchWorkItem?
//    private let sessionTime: TimeInterval
//    private let queue: DispatchQueue
//
//    var onTimeExceeded: (() -> Void)?
//
//    init(sessionTime: TimeInterval = 5, workItemProvider: WorkItemProvider, queue: DispatchQueue) {
//        self.workItemProvider = workItemProvider
//        self.sessionTime = sessionTime
//        self.queue = queue
//    }
//
//     func start() {
//        resetWorkItem()
//        scheduleWorkItem()
//    }
//    
//    func receivedUserAction() {
//        resetWorkItem()
//        scheduleWorkItem()
//    }
//    
//    func stop() {
//        workItem?.cancel()
//        workItem = nil
//    }
//
//     private func resetWorkItem() {
//        workItem?.cancel()
//        workItem = workItemProvider.workItem { [weak self] in
//            self?.onTimeExceeded?()
//        }
//    }
//    
//    private func scheduleWorkItem() {
//        queue.asyncAfter(deadline: .now() + sessionTime, execute: workItem!)
//    }
//    
//}
