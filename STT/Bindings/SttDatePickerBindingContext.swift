//
//  SttDatePickerBindingContext.swift
//  STT
//
//  Created by Peter Standret on 3/18/19.
//  Copyright © 2019 Peter Standret <pstandret@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import UIKit

public class SttDatePickerBindingContext<TViewController: AnyObject>: SttGenericTwoWayBindingContext<TViewController, Date> {
    
    private var lazyWriterApply: ((Date) -> Void)!
    
    private let handler: SttHandlerDatePicker
    private var forTarget: SttActionDatePicker?
    
    weak private var target: Dynamic<String?>!
    unowned private var datePicker: UIDatePicker
    
    internal init (viewController: TViewController, handler: SttHandlerDatePicker, datePicker: UIDatePicker) {
        self.handler = handler
        self.datePicker = datePicker
        
        super.init(viewController: viewController)
        super.withMode(.twoWayBind)
    }
    
    @discardableResult
    override public func to<TValue>(_ value: Dynamic<TValue>) -> SttGenericBindingContext<TViewController, Date> {
        lazyWriterApply = { value.value = $0 as! TValue }
        return super.to(value)
    }
    
    override public func to(_ command: SttCommandType) -> SttGenericBindingContext<TViewController, Date> {
        lazyWriterApply = { command.execute(parametr: $0) }
        return super.to(command)
    }
    
    // MARK: - forTarget
    
    @discardableResult
    public func forTarget(_ value: SttActionDatePicker) -> SttDatePickerBindingContext {
        self.forTarget = value
        
        return self
    }
    
    // MARK: - applier
    
    open override func bindSpecial() {
        handler.addTarget(type: forTarget!, delegate: self,
                          handler: { (d,_) in d.command.execute(parametr: d.parametr) })
        
    }
    
    override public func bindWriting() {
        handler.addTarget(type: .valueChanged, delegate: self,
                          handler: { $0.lazyWriterApply(super.convertBackValue($1.date)) })
    }
    
    override public func bindForProperty(_ value: Date) {
        self.datePicker.date = value
    }
}
