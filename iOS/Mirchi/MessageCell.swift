//
//  TextCell.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 16/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import DropletIF

protocol MessageCellDelegate : class{
    func didTapProfile()
}

class MessageCell: UICollectionViewCell {
    
    weak var delegate:MessageCellDelegate?
    @IBOutlet weak var cellWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageBubble: UIView!
    @IBOutlet weak var timestampLabel:UILabel!
    
    @IBOutlet weak var timestampTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var timestampHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messageBubbleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageBubbleTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageBubbleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageBubbleBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentBottomConstraint: NSLayoutConstraint!
    
    class func instanceFromNib() -> MessageCell {
        return UINib(nibName: String(describing: self), bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MessageCell
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setCellWidth(width:CGFloat){
        cellWidthConstraint.constant = width
        updateConstraintsIfNeeded()
    }
    
    func configureCell(message:Message, user:User){
        
    }
    
    func updateTimestampLabelWith(date:Date){
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        timestampLabel.text = formatter.string(from: date)
    }
    
    func contentSpacing() -> CGSize{
        let width = messageBubbleLeadingConstraint.constant + contentLeadingConstraint.constant + contentTrailingConstraint.constant + messageBubbleTrailingConstraint.constant
        let height = timestampTopConstraint.constant + timestampHeightConstraint.constant + messageBubbleTopConstraint.constant + contentTopConstraint.constant + contentBottomConstraint.constant + messageBubbleBottomConstraint.constant
        return CGSize(width: width, height: height)
    }
    
    func calculateCellSize(message:Message, itemSize:CGSize) -> CGSize{
        return CGSize.zero
    }
    
}
