//
//  ViewController.swift
//  yok
//
//  Created by Kein-chronicle on 2020/07/03.
//  Copyright © 2020 kimjinwan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var text = "test testeststst testsets"
    var textView = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setView()
    }
    
    func setView () {
        var fontSize:CGFloat = 250
        let height = view.frame.size.height
        var width:CGFloat = CGFloat(text.count) * 180
        if height > 3000 {
            fontSize = 500
            width = CGFloat(text.count) * 380
        }
        if view.frame.size.width > width {
            width = view.frame.size.width
        }
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: fontSize)
        textView.frame = CGRect(x: view.frame.size.width, y: 0, width: width, height: height)
        view.addSubview(textView)
        startAnimate()
    }
    
    func startAnimate() {
        UIView.animate(withDuration: Double(text.count) * 0.2, animations: {
            self.textView.frame.origin.x = -self.textView.frame.size.width
        }) { (complete) in
            if complete {
                self.textView.frame.origin.x = self.view.frame.size.width
                self.startAnimate()
            }
        }
    }


}

