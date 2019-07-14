//
//  CardHolderView.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 28/01/2018.
//  Copyright © 2018 Raj Kadiyala. All rights reserved.
//

import UIKit
import Koloda

class CardHolderView: KolodaView {
    
    let defaultBackgroundCardsTopMargin: CGFloat = 4.0
    let defaultBackgroundCardsScalePercent: CGFloat = 0.95
    let defaultBackgroundCardsLeftMargin: CGFloat = 8.0
    //override var d: Int = 2
    
    override func frameForCard(at index: Int) -> CGRect {
        let bottomOffset: CGFloat = 0
        let topOffset = defaultBackgroundCardsTopMargin * CGFloat(countOfVisibleCards - 1)
        let scalePercent = defaultBackgroundCardsScalePercent
        let width = self.frame.width * pow(scalePercent, CGFloat(index))
        let xOffset = (self.frame.width - width) / 2
        let height = (self.frame.height - bottomOffset - topOffset) * pow(scalePercent, CGFloat(index))
        let multiplier: CGFloat = 0.0 //index > 0 ? 1.0 : 0.0
        let prevCardFrame = index > 0 ? frameForCard(at: max(index - 1, 0)) : .zero
        let yOffset = (prevCardFrame.height - height + prevCardFrame.origin.y + defaultBackgroundCardsTopMargin) * multiplier
        let frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
        
        return frame
    }

}
