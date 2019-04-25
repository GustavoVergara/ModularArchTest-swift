//
//  PageControl.swift
//  MATKit
//
//  Created by Gustavo Vergara Garcia on 22/04/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation

public protocol PageControlType: class {
    associatedtype Element
    
    var elements: [Element] { get }
    
    @discardableResult
    func insert(_ elements: [Element], at page: Int) -> [Element]?
    func add(_ elements: [Element])
    func clear()
    
    func onElementsUpdate(do closure: @escaping (PageControl<Element>) -> Void) -> NSObjectProtocol
    func removeObserver(_ token: NSObjectProtocol)
}
public class PageControl<Element>: PageControlType {
    
    let notificationCenter: NotificationCenter = .default
    
    private var elementsPerPage = [Int: [Element]]() {
        didSet {
            self._availablePages = nil
            self._elements = nil
            NotificationCenter.default.post(name: PageControl<Element>.didUpdateElements, object: self)
        }
    }
    
    public var isEmpty: Bool {
        return self.elementsPerPage.isEmpty
    }
    
    private var _availablePages: [Int]?
    public var availablePages: [Int] {
        if let availablePages = self._availablePages {
            return availablePages
        } else {
            let availablePages = self.elementsPerPage.keys.sorted()
            self._availablePages = availablePages
            return availablePages
        }
    }
    
    private var _elements: [Element]?
    public var elements: [Element] {
        if let elements = self._elements {
            return elements
        } else {
            let elements = self.elementsPerPage.sorted(by: { $0.key < $1.key }).flatMap({ $0.value })
            self._elements = elements
            return elements
        }
    }
    
    public init() {
        
    }
    
    public init(elements: [Element]) {
        self.elementsPerPage[0] = elements
    }
    
    deinit {
        self.notificationCenter.removeObserver(self)
    }
    
    @discardableResult
    public func insert(_ elements: [Element], at page: Int) -> [Element]? {
        let previousElements = self.elementsPerPage[page]
        self.elementsPerPage[page] = elements
        return previousElements
    }
    
    public func add(_ elements: [Element]) {
        let page = (self.availablePages.last ?? -1) + 1
        self.insert(elements, at: page)
    }
    
    public func clear() {
        self.elementsPerPage = [:]
    }
    
    @discardableResult
    public func onElementsUpdate(do closure: @escaping (PageControl) -> Void) -> NSObjectProtocol {
        return self.notificationCenter.addObserver(forName: PageControl.didUpdateElements, object: self) { [weak self] _ in
            guard let strongSelf = self else { return }
            closure(strongSelf)
        }
    }
    
    public func removeObserver(_ token: NSObjectProtocol) {
        self.notificationCenter.removeObserver(token)
    }
    
    // MARK: Notifications
    
    static var didUpdateElements: Notification.Name { return .auto() }
    
}

#if canImport(RxSwift)
import RxSwift

extension PageControl: ReactiveCompatible {}
extension Reactive where Base: PageControlType {
    
    public var elements: Observable<[Base.Element]> {
        return Observable.create({ [weak base] observer in
            guard let base = base else { return Disposables.create() }
            let token = base.onElementsUpdate(do: { base in
                observer.onNext(base.elements)
            })

            return Disposables.create {
                base.removeObserver(token)
            }
        })
    }
    
}
#endif

#if canImport(RxCocoa)
import RxCocoa

extension Reactive where Base: PageControlType {

    public var insert: Binder<(elements: [Base.Element], page: Int)> {
        return Binder(self.base, binding: { (base, args) in
            base.insert(args.elements, at: args.page)
        })
    }
    
    public var add: Binder<[Base.Element]> {
        return Binder(self.base, binding: { (base, elements) in
            base.add(elements)
        })
    }
    
    public var clear: Binder<Void> {
        return Binder(self.base, binding: { (base, void) in
            base.clear()
        })
    }
    
}
#endif
