//
//  LTKModels.swift
//  LTKCodingChallenge
//
//  Created by Cameron Ollivierre on 12/22/21.
//

import Foundation

struct Ltks: Codable {
    var hero_image:String
    var id:String
    var profile_id:String
    var profile_user_id:String
    var status:String
    var caption:String
    var profile: Profile?
    var products:[Product]?
}

struct Profile: Codable {
    var id:String
    var avatar_url:String
    var display_name:String
    var full_name:String
    var instagram_name:String
    var blog_name:String
    var blog_url:String
    var bg_image_url:String?
    var bio:String
    var rs_account_id:Int
}

struct Meta: Codable {
    var last_id:String
    var num_results:Int
    var total_results:Int
    var limit:Int
    var seed:String
    var next_url:String
}

struct Product: Codable {
    var id:String
    var ltk_id:String
    var hyperlink:String
    var image_url:String
    var product_details_id:String

}

struct ProductList: Codable {
    var products: [Product]
}

struct ProfileList: Codable {
    var profiles: [Profile]
}

struct LtksList: Codable {
    var ltks: [Ltks]
}

struct MetaList: Codable {
    var meta: Meta
}
