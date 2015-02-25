//
//  UIProtocols.swift
//  belis-app
//
//  Created by Thorsten Hell on 11/02/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation

protocol CallOutInformationProviderProtocol {
    func getTitle() -> String
    func getGlyphIconName() -> String
    func getDetailViewID() -> String
    func canShowDetailInformation() -> Bool
}

protocol CellInformationProviderProtocol {
    func getMainTitle() -> String
    func getSubTitle() -> String
    func getTertiaryInfo() -> String
    func getQuaternaryInfo() -> String
}

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