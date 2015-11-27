//
//  UIProtocols.swift
//  belis-app
//
//  Created by Thorsten Hell on 11/02/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation
import MGSwipeTableCell

// MARK: - CallOutInformationProviderProtocol
protocol CallOutInformationProviderProtocol {
    func getCalloutTitle() -> String
    func getGlyphIconName() -> String
    func getDetailViewID() -> String
    func canShowDetailInformation() -> Bool
}
// MARK: - CellInformationProviderProtocol
protocol CellInformationProviderProtocol {
    func getMainTitle() -> String
    func getSubTitle() -> String
    func getTertiaryInfo() -> String
    func getQuaternaryInfo() -> String
}
// MARK: - NoCellInformation
class NoCellInformation : CellInformationProviderProtocol {
    // CellInformationProviderProtocol
    
    func getMainTitle() -> String{
        return "should not happen"
    }
    func getSubTitle() -> String{
        return "should not happen"
    }
    func getTertiaryInfo() -> String{
        return "should not happen"
    }
    func getQuaternaryInfo() -> String{
        return "should not happen"
    }
}
// MARK: - CellData
@objc protocol CellData {
    func getCellReuseIdentifier() -> String
}
// MARK: - CellDataProvider
@objc protocol CellDataProvider {
    func getAllData() -> [String: [CellData]]
    func getDataSectionKeys() -> [String]
    func getTitle() -> String
    func getDetailGlyphIconString() -> String
}

// MARK: - CellDataUI
@objc protocol CellDataUI {
    func fillFromCellData(cellData :CellData)
    func getPreferredCellHeight() -> CGFloat
}
// MARK: - SimpleCellActionProvider
@objc protocol SimpleCellActionProvider {
    func action(_: UIViewController)
}
// MARK: - ActionProvider
@objc protocol ActionProvider {
    func getAllActions() -> [BaseEntityAction]
}
// MARK: -  ObjectActionProvider
@objc protocol ObjectActionProvider {
    func getAllObjectActions() -> [ObjectAction]
}

// MARK: - LeftSwipeActionProvider
protocol LeftSwipeActionProvider {
    func getLeftSwipeActions()->[MGSwipeButton]
}
// MARK: - RightSwipeActionProvider
protocol RightSwipeActionProvider {
    func getRightSwipeActions()->[MGSwipeButton]
}

// MARK: - Refreshable
protocol Refreshable {
    func refresh()
}

