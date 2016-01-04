//
//  ViewController.swift
//  RichText
//
//  Created by luojie on 15/12/28.
//  Copyright © 2015年 LuoJie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

//    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var selectedWordLabel: UILabel!
    @IBOutlet weak var selectedWordStepper: UIStepper!
    @IBOutlet weak var textView: UITextView!
    
    var wordList: [String] {
        let result = textView.attributedText!.string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        return result
    }
    
    var selectedWord: String {
        return wordList[Int(selectedWordStepper.value)]
    }
    
    @IBAction func updateSelectedWord() {
        selectedWordStepper.maximumValue = Double(wordList.endIndex - 1)
        selectedWordLabel.text = selectedWord
        
        addTextViewAttributes([NSBackgroundColorAttributeName: UIColor.whiteColor()],
            range: NSMakeRange(0, textView.attributedText!.length))
        addSelectedWordAttributes([NSBackgroundColorAttributeName: UIColor.yellowColor()])
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSelectedWord()
        
        if let rtf = NSBundle.mainBundle().URLForResource("rtfdoc", withExtension: "rtf", subdirectory: nil, localization: nil) {
            let data = NSData(contentsOfURL: rtf)!
            let attributedString =  try! NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType], documentAttributes: nil)
            textView.attributedText = attributedString
        }
        
    }
    
    func addTextViewAttributes(attributes: [String : AnyObject], range: NSRange) {
        if range.length != NSNotFound {
            let mat = textView.attributedText?.mutableCopy() as? NSMutableAttributedString
            mat?.addAttributes(attributes, range: range)
            textView.attributedText = mat
        }
    }
    
    func addSelectedWordAttributes(attributes: [String : AnyObject]) {
        let range = (textView.attributedText!.string as NSString).rangeOfString(selectedWord)
        addTextViewAttributes(attributes, range: range)
    }

    func addImageToTextView(type type: NSMutableAttributedString.AddImageAttachmentType) {
        let mat = textView.attributedText?.mutableCopy() as? NSMutableAttributedString
        mat?.addImage(peppersImage, withWidth: textView.bounds.width, type: type)
        textView.attributedText = mat
    }
    
    var peppersImage: UIImage {
        return UIImage(named: "peppers")!
    }
    
    @IBAction func changeColor(sender: UIButton) {
        addSelectedWordAttributes([NSForegroundColorAttributeName: sender.backgroundColor!])
    }
    
    @IBAction func changeFont(sender: UIButton) {
        var fontSize = UIFont.systemFontSize()
        let range = (textView.attributedText!.string as NSString).rangeOfString(selectedWord)
        if range.location != NSNotFound {
            let attributes = textView.attributedText?.attributesAtIndex(range.location, effectiveRange: nil)
            let currentFont = attributes?[NSFontAttributeName]
            if let size = currentFont?.pointSize { fontSize = size }
        }
        
        let font = sender.titleLabel!.font.fontWithSize(fontSize)
        addSelectedWordAttributes([NSFontAttributeName: font])
    }
    
    @IBAction func underline() {
        addSelectedWordAttributes([NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue])
    }
    
    @IBAction func ununderline() {
        addSelectedWordAttributes([NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleNone.rawValue])
    }
    
    @IBAction func outline() {
        addSelectedWordAttributes([NSStrokeWidthAttributeName: 5])
    }
    
    @IBAction func unoutline() {
        addSelectedWordAttributes([NSStrokeWidthAttributeName: 0])
    }
    
    @IBAction func insertImage() {
        addImageToTextView(type: .InsertBefore(selectedWord))
    }
    
    @IBAction func appendImage() {
        addImageToTextView(type: .AppendAfter(selectedWord))
    }
    
    @IBAction func replaceWithImage() {
        addImageToTextView(type: .Replace(selectedWord))
    }
    
}




extension NSMutableAttributedString {
    enum AddImageAttachmentType {
        case InsertBefore(String)
        case AppendAfter(String)
        case Replace(String)
        
        var targetString: String {
            switch self {
            case InsertBefore(let string):
                return string
            case AppendAfter(let string):
                return string
            case Replace(let string):
                return string
            }
        }
    }
    
    func addImage(image: UIImage, withWidth width: CGFloat, type: AddImageAttachmentType) -> Bool {
        let range = (string as NSString).rangeOfString(type.targetString)
        if range.location != NSNotFound {
            let scaledImage = image.scaleToWidth(width)
            let imageAttachment = NSTextAttachment(image: scaledImage)
            let imageAttributedString = NSAttributedString(attachment: imageAttachment)
            switch type {
            case .InsertBefore(_):
                insertAttributedString(imageAttributedString, atIndex: range.location)
            case .AppendAfter(_):
                insertAttributedString(imageAttributedString, atIndex: range.location + range.length)
            case .Replace(_):
                replaceCharactersInRange(range, withAttributedString: imageAttributedString)
            }
            return true
        }
        return false
    }
}

extension NSTextAttachment {
    convenience init(image: UIImage) {
        self.init()
        self.image = image
    }
}

extension UIImage {
    func scaleToWidth(width: CGFloat) -> UIImage {
        let data = UIImageJPEGRepresentation(self, 1.0)!
        let scale = size.width / width
        return UIImage(data: data, scale: scale)!
    }
}


