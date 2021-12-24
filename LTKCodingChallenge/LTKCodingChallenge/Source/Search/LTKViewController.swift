//
//  LTKViewController.swift
//  SampleApp
//
//  Created by Cameron Ollivierre on 12/22/21.
//

import UIKit

class LTKViewController: UITableViewController, UITableViewDataSourcePrefetching {

    
    
    let searchController = UISearchController(searchResultsController: nil)
    let network: LTKViewModel = LTKViewModel()
    var ltks: [Ltks] = []
    var metaData: Meta?
    var requestUrl = "https://api-gateway.rewardstyle.com/api/ltk/v2/ltks/?featured=true&limit=20"
    var isFirstPage: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getProfiles()
        tableView.prefetchDataSource = self
        self.navigationItem.title = "LTK";
    }
    
    func getProfiles() {
        network.sendRequest(with: requestUrl, completion: { [weak self] (results, meta) in
            DispatchQueue.main.async {
                if let ltks = results {
                    self?.ltks += (ltks)
                    self?.isFirstPage = (ltks.count) <= 20
                }
                
                
                self?.metaData = meta
                if let meta = meta {
                    self?.requestUrl = (meta.next_url)
                }
                
                if self?.isFirstPage == true {
                    self?.tableView.reloadData()
                } else {
                    if let ltks = self?.ltks {
                        if let indexPathsToReload = self?.visibleIndexPathsToReload(intersecting: (self?.calculateIndexPathsToReload(from: ltks)) as! [IndexPath] ) {
                            self?.tableView.reloadRows(at: indexPathsToReload, with: .automatic)
                        }
                    }
                }
            }
        })
    }
    
    private func calculateIndexPathsToReload(from newLtks: [Ltks]) -> [IndexPath] {
        let startIndex = self.ltks.count - newLtks.count
      let endIndex = startIndex + newLtks.count
      return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
        segue.identifier == "LTKDetailSegue",
        let indexPath = tableView.indexPathForSelectedRow,
        let ltkDetailViewController = segue.destination as? LTKDetailViewController
        else {
            return
        }
        ltkDetailViewController.ltks = ltks[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            self.getProfiles()
        }
    }
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= ltks.count
     }

    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
      }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LTKCell", for: indexPath) as! LTKCell
        
        cell.poster?.image = UIImage(named: "placeholder")
        
        if isLoadingCell(for: indexPath) {
            cell.poster?.image = UIImage(named: "placeholder")
        } else {
            //Move To cell configure method in cell class
            let path = self.ltks[indexPath.row].hero_image 
                /*we use token to store the uuid linked to the dataTask request, this way we can cancel unneeded
                 inflight request as the cells update with fresh search results */
                let token = network.loadImage(imageId: path, completion: { (image) in
                    guard let image = image else { return }
                    DispatchQueue.main.async {
                        cell.poster?.image = image
                    }
                })
                /*On reuse being called we cancel the pending request. Since the cell is preparing
                to update with new data the pending image is no longer needed */
                cell.onReuse = {
                    if let token = token {
                        self.network.cancelLoad(token)
                    }
                }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let meta = metaData {
            return meta.total_results
        } else {
            return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 635
    }
}
