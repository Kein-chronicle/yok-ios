//
//  RecommendView.swift
//  yok
//
//  Created by Kein-chronicle on 2020/07/05.
//  Copyright © 2020 kimjinwan. All rights reserved.
//


import UIKit
import SnapKit


class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var list:[Any] = []
    var _tableView = UITableView()
    var tableViewCell = "tableviewcell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let top:UIView = {
            let wrap = UIView()
            
            let xBtn = UIButton(type: .system)
            xBtn.setImage(UIImage(systemName: "arrow.left"), for: .normal)
            xBtn.addTarget(self, action: #selector(xBtn_onClick), for: .touchUpInside)
            wrap.addSubview(xBtn)
            xBtn.snp.makeConstraints { (make) in
                make.left.top.bottom.equalTo(wrap)
                make.width.equalTo(60)
            }
            
            let title = UILabel()
            title.text = "Recommend"
            title.textAlignment = .center
            wrap.addSubview(title)
            title.snp.makeConstraints { (make) in
                make.top.bottom.equalTo(wrap)
                make.left.equalTo(xBtn.snp.right)
                make.right.equalTo(wrap).offset(-60)
            }
            
            
            return wrap
        }()
        view.addSubview(top)
        top.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(view)
            make.height.equalTo(50)
        }
        
        _tableView.register(UITableViewCell.self, forCellReuseIdentifier: tableViewCell)
        _tableView.delegate = self
        _tableView.dataSource = self
        view.addSubview(_tableView)
        _tableView.snp.makeConstraints { (make) in
            make.top.equalTo(top.snp.bottom)
            make.left.right.bottom.equalTo(view)
        }
        
        
        let firstGet: (Notification) -> Void = {notification in
            
            guard let userInfo = notification.userInfo as? [String:Any],
                let data = userInfo["data"] as? [Any]
            else {
                return
            }
            if data.count != 0 {
                self.list = data
                
                DispatchQueue.main.async {
                    self._tableView.reloadData()
                }
            }
        }
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("listForRecommend"), object: nil, queue: .main, using: firstGet)
        
        
        
        let applyEnd: (Notification) -> Void = {notification in
            ApiClass.apiColler("\(rootUrl)/list", [:], .post, "listForRecommend", "listForRecommendFail")
            self.endYokApply()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("applyYok"), object: nil, queue: .main, using: applyEnd)
        
    }
    
    func endYokApply() {

        let alert = UIAlertController(title: "추천완료", message: "추천은 검수 이후 추천 욕으로 등록됩니다.", preferredStyle: .alert)
        
        let actionC = UIAlertAction(title: "확인", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(actionC)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("call data")
        
        ApiClass.apiColler("\(rootUrl)/list", [:], .post, "listForRecommend", "listForRecommendFail")
    }
    
    @objc func xBtn_onClick() {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = _tableView.dequeueReusableCell(withIdentifier: tableViewCell, for: indexPath)
        
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        
        if indexPath.row == 0 {
            
            let button = UIButton(type: .system)
            button.addTarget(self, action: #selector(addCard), for: .touchUpInside)
            button.setImage(UIImage(systemName: "plus"), for: .normal)
            
            cell.contentView.addSubview(button)
            
            button.snp.makeConstraints { (make) in
                make.top.bottom.left.right.equalTo(cell.contentView)
            }
            
            return cell
        }
        

        guard let yokData = list[indexPath.row - 1] as? [String:Any],
            let yok = yokData["yok"] as? String
        else {
                return cell
        }
        
        let label = UILabel()
        label.text = yok
        label.textAlignment = .center
        label.numberOfLines = 0
        cell.contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(cell.contentView)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectTalbeCell(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectTalbeCell(index: indexPath.row)
    }
    
    func selectTalbeCell(index: Int) {
        if index == 0 {
            addCard()
            return
        }
        
        guard let yokData = list[index - 1] as? [String:Any],
            let _id = yokData["_id"] as? String,
            let yok = yokData["yok"] as? String
        else {
                return
        }
        ApiClass.apiColler("\(rootUrl)/select", ["_id":_id], .post, "endSelecte", "endSelectef")
        
        dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name("selectTarget"), object: nil, userInfo: ["yok":yok])
        }
    }
    
    
    @objc func addCard() {
        let alert = UIAlertController(title: "Create Card!", message: "Input card's name field", preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "욕"
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { [weak alert] (_) in
        
        }))

        alert.addAction(UIAlertAction(title: "추천", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if let name = textField!.text {

                ApiClass.apiColler("\(rootUrl)/apply", ["yok":name], .post, "applyYok", "applyYokFail")
            }
            
        }))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
}
