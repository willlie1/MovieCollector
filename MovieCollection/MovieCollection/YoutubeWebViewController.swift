//
//  YoutubeWebViewController.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 22-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import UIKit

class YoutubeWebViewController: UIViewController {

    var videoKey : String?
    
    @IBOutlet weak var youtubeWebView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let videoKey = videoKey {
            let url = NSURL(string: "https://www.youtube.com/embed/\(videoKey)")
            self.youtubeWebView.loadRequest(NSURLRequest(url: url as! URL) as URLRequest)
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        youtubeWebView.stopLoading()
        self.youtubeWebView.loadHTMLString("", baseURL: nil)
    }
}
