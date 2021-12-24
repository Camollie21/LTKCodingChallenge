//
//  LTKDetailViewController.swift
//  SampleApp
//
//  Created by Cameron Ollivierre on 12/22/21.
//

import UIKit
import WebKit

class LTKDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WKUIDelegate{

    @IBOutlet weak var heroImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!

    
    let network: LTKViewModel = LTKViewModel()
    
    var ltks: Ltks? {
      didSet {
        setupView()
      }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.ltks = nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let products = ltks?.products {
            return products.count
        } else {
            return 0
        }
   }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
        
        cell.productImage?.image = UIImage(named: "placeholder")
        guard let product = ltks?.products?[indexPath.row] else {
            return cell
        }
        //Move To cell configure method in cell class
        let path = product.image_url
            /*we use token to store the uuid linked to the dataTask request, this way we can cancel unneeded
             inflight request as the cells update with fresh search results */
            let token = network.loadImage(imageId: path, completion: { (image) in
                guard let image = image else { return }
                DispatchQueue.main.async {
                    cell.productImage?.image = image
                }
            })
            /*On reuse being called we cancel the pending request. Since the cell is preparing
            to update with new data the pending image is no longer needed */
            cell.onReuse = {
                if let token = token {
                    self.network.cancelLoad(token)
                }
            }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let product = ltks?.products?[indexPath.row] else {
            return
        }
        guard  let url = URL(string:product.hyperlink) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func setupView() {
        if let profile = ltks?.profile {
                let path = profile.avatar_url
                    _ = network.loadImage(imageId: path, completion: { (image) in
                        guard let image = image else { return }
                        DispatchQueue.main.async {
                            self.profileImage?.image = image
                        }
                    })
            }
        
        if let ltks = ltks {
            let path = ltks.hero_image
                _ = network.loadImage(imageId: path, completion: { (image) in
                    guard let image = image else { return }
                    DispatchQueue.main.async {
                        self.heroImage?.image = image
                    }
                })
        }
        }
}
