//
//  Extensions.swift
//  Photos
//
//  Created by Vladislav Filyakov on 1/8/20.
//  Copyright © 2020 Vlad Filyakov. All rights reserved.
//

import UIKit

extension CaseIterable where Self: Equatable {
    var index: Int { return Self.allCases.firstIndex(of: self) as? Int ?? -1 }
}

extension UIScreen {
    func roundDownToDevicePixels(_ value: CGFloat) -> CGFloat {
        return floor(value * scale) / scale
    }
}
