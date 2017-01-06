//
//  ViewController.swift
//  MovieView
//
//  Created by Tao Wang on 1/5/17.
//  Copyright © 2017 Tao Wang. All rights reserved.
//

import UIKit
import MBProgressHUD
import AFNetworking
class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collection: UICollectionView!
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    override func viewDidLoad() {
        super.viewDidLoad()
        collection.dataSource=self
        collection.delegate=self
        searchBar.delegate=self
        searchBar.showsCancelButton=true
        self.title="Moive Viewer"
        let refreshControl=UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MoviesViewController.refreshControlAction(refreshControl:)), for: .valueChanged)
        collection.addSubview(refreshControl)
        
        
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        MBProgressHUD.showAdded(to: self.view, animated:true)
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest,completionHandler: { (dataOrNil, response, error) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            if let data = dataOrNil {
                
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    print("response: \(responseDictionary)")
                    self.movies=responseDictionary["results"] as! [NSDictionary]
                    self.filteredMovies=self.movies
                    self.collection.reloadData()
                }
            }
        })
        task.resume()


        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let filteredMovies=filteredMovies{
            return filteredMovies.count
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collection.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
        let movie=filteredMovies![indexPath.row]
        let posterPath=movie["poster_path"] as! String
        let title=movie["title"] as! String
        cell.colorLable.text=title
        let Url="https://image.tmdb.org/t/p/w500"+posterPath
        let imageUrl=URL(string: Url)
        cell.moivePost.setImageWith(imageUrl!)
        print("row \(indexPath.row)")
        return cell
        
    }
    
    
    func refreshControlAction(refreshControl: UIRefreshControl){
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        MBProgressHUD.showAdded(to: self.view, animated:true)
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest,completionHandler: { (dataOrNil, response, error) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            if let data = dataOrNil {
                
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    self.movies=responseDictionary["results"] as! [NSDictionary]
                    self.filteredMovies=self.movies
                    self.collection.reloadData()
                    refreshControl.endRefreshing();
                }
            }
        })
        task.resume()
        
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let movies=movies{
            filteredMovies=movies.filter {((($0["title"] as AnyObject) as! String).range(of: searchText,options: .caseInsensitive) != nil)}
        }
        if(searchText==""){
            self.filteredMovies=self.movies
        }
        self.collection.reloadData()
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton=true;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton=false
        searchBar.text=""
        searchBar.resignFirstResponder()
        self.filteredMovies=self.movies
        self.collection.reloadData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
