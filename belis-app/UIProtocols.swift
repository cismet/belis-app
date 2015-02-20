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
    func getIconName() -> String
    func getDetailButtonImageName() -> String
    func getDetailViewID() -> String
    func canShowDetailInformation() -> Bool
}

protocol CellInformationProviderProtocol {
    func getMainTitle() -> String
    func getSubTitle() -> String
    func getTertiaryInfo() -> String
    func getQuaternaryInfo() -> String
}