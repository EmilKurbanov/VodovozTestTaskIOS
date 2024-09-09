//
//  ModelVodovoz.swift
//  Vodovoz
//
//  Created by emil kurbanov on 13.08.2024.
//

import Foundation
import Foundation


struct MorePhoto: Codable {
    let value: [String]

    enum CodingKeys: String, CodingKey {
        case value = "VALUE"
    }
}


struct ExtendedPrice: Codable {
    let price: Double
    let oldPrice: Double?
    let quantityFrom: Int?
    let quantityTo: Int?

    enum CodingKeys: String, CodingKey {
        case price = "PRICE"
        case oldPrice = "OLD_PRICE"
        case quantityFrom = "QUANTITY_FROM"
        case quantityTo = "QUANTITY_TO"
    }
}


struct Product: Codable {
    let id: String
    let name: String?
    let detailPicture: String
    let price: Double
    let rating: Double
    let catalogQuantity: Int
    let extendedPrice: [ExtendedPrice]?
    let morePhoto: MorePhoto?
    let coutComments: String?

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case name = "NAME"
        case detailPicture = "DETAIL_PICTURE"
        case price = "PROPERTY_TSENA_ZA_EDINITSU_TOVARA_VALUE"
        case rating = "PROPERTY_RATING_VALUE"
        case catalogQuantity = "CATALOG_QUANTITY"
        case extendedPrice = "EXTENDED_PRICE"
        case morePhoto = "MORE_PHOTO"
        case coutComments = "COUTCOMMENTS"
    }
}


struct Category: Codable {
    let id: Int
    let name: String
    let data: [Product]

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case name = "NAME"
        case data = "data"
    }
}


struct APIResponse: Codable {
    let status: String
    let message: String
    let categories: [Category]

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
        case categories = "TOVARY"
    }
}
