//
//  LTKViewModel.swift
//  SampleApp
//
//  Created by Cameron Ollivierre on 12/22/21.
//

import UIKit

class LTKViewModel: NSObject {
    let utilityQueue = DispatchQueue.global(qos: .utility)
    let cache = NSCache<NSString, UIImage>()
    private var runningRequests = [UUID: URLSessionDataTask]()
    
    private var ltks: [Ltks] = []
    private var currentPage = 1
    private var total = 0
    private var isFetchInProgress = false
    
    override init() {
        super.init()
    }
    
    var totalCount: Int {
      return total
    }
    
    func ltk(at index: Int) -> Ltks {
      return ltks[index]
    }
    
    func sendRequest(with Url: String, completion: @escaping ([Ltks]?, Meta?) -> ()) {
        guard !isFetchInProgress else {
          return
        }
        isFetchInProgress = true
        utilityQueue.async {
            guard  let url = URL(string: "https://api-gateway.rewardstyle.com/api/ltk/v2/ltks/?featured=true&limit=10") else {
                return
            }
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                if let data = data {
                    self.currentPage += 1
                    self.isFetchInProgress = false
                    completion(self.parseJson(data: data), self.parseMetaData(data: data))
                }
                if let error = error {
                    print(error)
                    return
                }
            })
            task.resume()
        }
    }
    
    func parseJson(data: Data) -> [Ltks]? {
        let decoder = JSONDecoder()
        do {
            let profileList = try decoder.decode(ProfileList.self, from: data)
            let ltksList = try decoder.decode(LtksList.self, from: data)
            let proudctList = try decoder.decode(ProductList.self, from: data)
            return formatData(profileList: profileList, ltksList: ltksList, productList: proudctList)
        } catch {
            print(error)
            return nil
        }
    }
    
    func parseMetaData(data: Data) -> Meta? {
        let decoder = JSONDecoder()
        do {
            let meta = try decoder.decode(MetaList.self, from: data)
            return meta.meta
        } catch {
            print(error)
            return nil
        }
    }
    
    func formatData (profileList: ProfileList, ltksList: LtksList, productList: ProductList) -> [Ltks] {
        var formattedLtksList: [Ltks] = []
        var ltkProducts: [Product] = []
        for var ltks in ltksList.ltks {
            for profile in profileList.profiles {
                if profile.id == ltks.profile_id {
                    ltks.profile = profile
                }
            }
//                ltks.products = []
                for product in productList.products {
                    if product.ltk_id == ltks.id {
                        ltkProducts.append(product)
                    }
                }
            ltks.products = ltkProducts
            formattedLtksList.append(ltks)
            }
        return formattedLtksList
    }
    
    func loadImage(imageId: String, completion: @escaping (UIImage?) -> Void) -> UUID? {
        if let cachedImage = self.cache.object(forKey: imageId as NSString) {
            completion(cachedImage)
        } else {
            let uuid = UUID()
            
            guard let url = URL(string: imageId) else { return nil }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                
                //Once the task is complete we remove the dataTask from our list of running requests 
                defer {self.runningRequests.removeValue(forKey: uuid) }
                
                if let data = data, let image = UIImage(data: data) {
                    self.cache.setObject(image, forKey: imageId as NSString)
                    completion(image)
                }
                
                if let error = error {
                    print(error)
                    return
                }
            }
            task.resume()
            
            //Add the dataTask to our running request dictionary.
            self.runningRequests[uuid] = task
            return uuid
        }
        return nil
    }
    
    //Here we cancel stale dataTasks and remove them from our runningRequest dictionary
    func cancelLoad(_ uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
    

}
