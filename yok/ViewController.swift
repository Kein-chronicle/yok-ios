//
//  ViewController.swift
//  yok
//
//  Created by Kein-chronicle on 2020/07/03.
//  Copyright © 2020 kimjinwan. All rights reserved.
//

import UIKit
import SnapKit

var rootUrl = "https://yok.kimjinwan.com/api/yok"

class ViewController: UIViewController {
    
    var first = true
    var text = ""
    var textView = UILabel()
    var count = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        ApiClass.apiColler("\(rootUrl)/list", [:], .post, "listForFirstView", "listFirFirstViewFail")
        startAnimate()
        
        let didRotate: (Notification) -> Void = { notification in
            switch UIDevice.current.orientation {
            case .landscapeLeft, .landscapeRight:
                print("landscape")
            case .portrait, .portraitUpsideDown:
                print("Portrait")
            default:
                print("other")
            }
            print("end rotate")
            self.setView()
        }
        
        let firstGet: (Notification) -> Void = {notification in
            
            guard let userInfo = notification.userInfo as? [String:Any],
                let data = userInfo["data"] as? [Any]
            else {
                return
            }
            if data.count != 0 {
                let number = Int.random(in: 0 ... (data.count - 1))
                guard let yokData = data[number] as? [String:Any],
                    let yok = yokData["yok"] as? String
                else {
                        return
                }
                var _text = ""
                for _ in 0 ..< 10 {
                    _text += "\(yok)              "
                }
                self.text = yok
                self.textView.text = _text
                self.setView()
            }
        }
        
        let selectInList: (Notification) -> Void = {notification in
            
            guard let userInfo = notification.userInfo as? [String:Any],
                let yok = userInfo["yok"] as? String
            else {
                return
            }
            var _text = ""
            for _ in 0 ..< 10 {
                _text += "\(yok)              "
            }
            self.text = yok
            self.textView.text = _text
            self.setView()
        }
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("listForFirstView"), object: nil, queue: .main, using: firstGet)
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("selectTarget"), object: nil, queue: .main, using: selectInList)
        
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification,
        object: nil,
        queue: .main,
        using: didRotate)
    }
    
    
    
    func setView () {
        for view in view.subviews {
            view.removeFromSuperview()
        }
        
        let fontSize:CGFloat = 250
        let height = view.frame.size.height
        var width:CGFloat = view.frame.size.width * 50
        print(width)
        if width > 30000 {
            width = 25000
        }
        textView.font = UIFont.systemFont(ofSize: fontSize)
        textView.frame = CGRect(x: view.frame.size.width, y: 0, width: width, height: height)
        view.addSubview(textView)
        
        let bottom = UIButton(type: .system)
        bottom.tintColor = .white
        bottom.addTarget(self, action: #selector(bottomTouch), for: .touchUpInside)
        bottom.setTitle(text, for: .normal)
        bottom.titleLabel?.numberOfLines = 0
        bottom.layer.masksToBounds = true
        bottom.layer.cornerRadius = 10
        bottom.backgroundColor = .gray
        view.addSubview(bottom)
        bottom.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.height.equalTo(60)
            make.bottom.equalTo(view).offset(-20)
            
        }
        
    }
    
    @objc func bottomTouch() {
        print("touch")
        present(ListViewController(), animated: true, completion: nil)
    }
    
    func startAnimate() {
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            if self.text != "" {
                self.count += 1
                if self.count == 600 {
                    self.count = 0
                    self.textView.frame.origin.x = 0
                }
                self.textView.frame.origin.x = self.textView.frame.origin.x - 25
            }
        }
    }
    
    


}

