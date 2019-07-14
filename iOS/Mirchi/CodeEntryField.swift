//
//  CodeEntryField.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 12/12/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit

@objc protocol CodeEntryFieldDelegate{
    func codeEntryComplete(code:String)
    func codeEntryIncomplete()
}

class CodeEntryField: UIView{//} UITextInputTraits, UIKeyInput {

    @IBOutlet var delegate:CodeEntryFieldDelegate!
    @IBOutlet var contentView: UIView!
    @IBInspectable let codeLength:Int = 6
    @IBInspectable let placeholder:String = "-"
    @IBOutlet var codeLabel:UILabel!
    var codeEntry:String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit(){
        Bundle.main.loadNibNamed("CodeEntryField", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        
        if #available(iOS 12.0, *) {
            textContentType = .oneTimeCode
        }
    }
    
    override func draw(_ rect: CGRect) {
        var code = codeEntry
        let add = codeLength - code.count
        if add > 0{
            let pad = String(repeating: placeholder, count: add)
            code.append(pad)
        }
        codeLabel.text = code
    }
    
    // MARK: UIText Input Traits
    
    var keyboardType: UIKeyboardType = .numberPad
    var textContentType: UITextContentType! = nil
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.becomeFirstResponder()
        let menu = UIMenuController.shared
        menu.setTargetRect(frame, in: self)
        menu.setMenuVisible(true, animated: true)
    }
    
    // MARK: - UI Key Input
    
    var hasText: Bool{
        return !codeEntry.isEmpty
    }
    
    func insertText(_ text: String) {
        if codeEntry.count >= codeLength{
            return
        }
        codeEntry.append(text)
        setNeedsDisplay()
        notifyEntryCompletion()
    }
    
    func deleteBackward() {
        if self.codeEntry.isEmpty{
            return
        }
        codeEntry.removeLast()
        setNeedsDisplay()
        self.notifyEntryCompletion()
    }
    
    func clearCodeEntry(){
        codeEntry.removeAll()
        setNeedsDisplay()
        notifyEntryCompletion()
    }
    
    func notifyEntryCompletion(){
        if UIMenuController.shared.isMenuVisible{
            UIMenuController.shared.setMenuVisible(false, animated: true)
        }
        if codeEntry.count >= codeLength{
            print("Entry is complete!")
            delegate.codeEntryComplete(code: codeEntry)
        }else{
            print("Entry is incomplete!")
            delegate.codeEntryIncomplete()
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)){
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    override func paste(_ sender: Any?) {
        if let copiedCode = UIPasteboard.general.string, CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: copiedCode)){
            clearCodeEntry()
            insertText(copiedCode)
        }
    }

}

extension CodeEntryField: UITextInput{
    var selectedTextRange: UITextRange? {
        get {
            return nil
        }
        set(selectedTextRange) {
            //
        }
    }
    
    var markedTextRange: UITextRange? {
        return nil
    }
    
    var markedTextStyle: [NSAttributedString.Key : Any]? {
        get {
            return nil
        }
        set(markedTextStyle) {
            //
        }
    }
    
    func setMarkedText(_ markedText: String?, selectedRange: NSRange) {
        //
    }
    
    func unmarkText() {
        //
    }
    
    var beginningOfDocument: UITextPosition {
        return UITextPosition()
    }
    
    var endOfDocument: UITextPosition {
        return UITextPosition()
    }
    
    func textRange(from fromPosition: UITextPosition, to toPosition: UITextPosition) -> UITextRange? {
        return nil
    }
    
    func position(from position: UITextPosition, offset: Int) -> UITextPosition? {
        return nil
    }
    
    func position(from position: UITextPosition, in direction: UITextLayoutDirection, offset: Int) -> UITextPosition? {
        return nil
    }
    
    func compare(_ position: UITextPosition, to other: UITextPosition) -> ComparisonResult {
        return ComparisonResult.orderedDescending
    }
    
    func offset(from: UITextPosition, to toPosition: UITextPosition) -> Int {
        return 0
    }
    
    var inputDelegate: UITextInputDelegate? {
        get {
            return nil
        }
        set(inputDelegate) {
            //
        }
    }
    
    var tokenizer: UITextInputTokenizer {
        return UITextInputStringTokenizer(textInput: self)
    }
    
    func position(within range: UITextRange, farthestIn direction: UITextLayoutDirection) -> UITextPosition? {
        return nil
    }
    
    func characterRange(byExtending position: UITextPosition, in direction: UITextLayoutDirection) -> UITextRange? {
        return nil
    }
    
    func baseWritingDirection(for position: UITextPosition, in direction: UITextStorageDirection) -> UITextWritingDirection {
        return UITextWritingDirection.leftToRight
    }
    
    func setBaseWritingDirection(_ writingDirection: UITextWritingDirection, for range: UITextRange) {
        //
    }
    
    func firstRect(for range: UITextRange) -> CGRect {
        return CGRect.zero
    }
    
    func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
    
    func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return [UITextSelectionRect]()
    }
    
    func closestPosition(to point: CGPoint) -> UITextPosition? {
        return nil
    }
    
    func closestPosition(to point: CGPoint, within range: UITextRange) -> UITextPosition? {
        return nil
    }
    
    func characterRange(at point: CGPoint) -> UITextRange? {
        return nil
    }
    
    func text(in range: UITextRange) -> String? {
        return nil
    }
    
    func replace(_ range: UITextRange, withText text: String) {
        //
    }
    
    func shouldChangeText(in range: UITextRange, replacementText text: String) -> Bool {
        return true
    }
    
}
