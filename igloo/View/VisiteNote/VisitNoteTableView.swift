//
//  VisitNoteTableView.swift
//  igloo
//
//  Created by 冯奕琦 on 2019/1/26.
//  Copyright © 2019 冯奕琦. All rights reserved.
//

import UIKit

class VisitNoteTableView: UITableView,UITableViewDelegate,UITableViewDataSource {
    
    var saveImages:Bool?
    var showAddNewNoteCell:Bool!
    var visitNoteArray:[VisitedNote]!
    var visitNoteIDArray:[String]!
    var deleteVisitNoteDelegate:DeleteVisiteNoteDelegate!
    func setDataIn(data:[VisitedNote],ids:[String])  {
        //配置全部
        self.delegate = self
        self.dataSource = self
        self.separatorColor = UIColor.white
        visitNoteArray = data
        visitNoteIDArray = ids
        reloadData()
        if showAddNewNoteCell {
            //配置长摁获取器
            self.longPressRecoginzer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
            self.longPressRecoginzer.minimumPressDuration = 0.25
            self.addGestureRecognizer(longPressRecoginzer)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return visitNoteArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if row == 0 {
            //配置第一行的Cell
            let cellId = showAddNewNoteCell ? "addVisitNoteCell" : "gapCell"
            let staticCell = tableView.dequeueReusableCell(withIdentifier: cellId)!
            return staticCell
        }else{
            let visitNoteCell = tableView.dequeueReusableCell(withIdentifier: "VisitNoteCell") as! VisitNoteCell
            //正在生成Cell
            let order = row-1
            visitNoteCell.saveImages = self.saveImages
            visitNoteCell.setData(data: visitNoteArray[order])
//            print("VisitNoteTableView")
//            print("SaveImages")
//            print(self.saveImages)
            visitNoteCell.id = visitNoteIDArray[order]
            return visitNoteCell
        }
    }
    
    //删除VisitNote的代码
    
    var longPressRecoginzer:UILongPressGestureRecognizer!
    
    var firstTimeChange:Bool = true
    @objc func longPress(sender:UILongPressGestureRecognizer){
        
        if sender.state == .changed , firstTimeChange{
            firstTimeChange = false
            //找到这个点
            let point = sender.location(in: self)
            print("VisitNoteTableView")
            print(point)
            //找到这个点对应的Cell
            if let cell = findVisitNoteCell(location: point){
                cellShouldDelete = cell
//                print(cell)
                cell.becomeFirstResponder()
                //根据这个Cell添加对应的气泡删除方法
                setMenuController()
                let menu = UIMenuController.shared
                menu.arrowDirection = .default
                menu.setTargetRect(cell.frame, in: self)
                menu.setMenuVisible(true, animated: true)
            }
        }
        
        if sender.state == .ended{
            firstTimeChange = true
        }
    }
    
    func setMenuController() {
        let delete = UIMenuItem(title: "删除", action: #selector(deleteCell))
        UIMenuController.shared.menuItems = [delete]
    }
    
    var cellShouldDelete:VisitNoteCell?
    @objc func deleteCell() {
        if let cell = cellShouldDelete {
            //Model删除
            deleteVisitNoteDelegate.deleteVisiteNote(id:cell.id, UIActionBlock: {
                //删除data
                let index = self.indexPath(for: cell)!.row-1
                self.visitNoteArray.remove(at: index)
                self.visitNoteIDArray.remove(at: index)
                //View删除
                self.deleteRows(at: [self.indexPath(for: cell)!], with: UITableView.RowAnimation.left)
            })
        }
        cellShouldDelete = nil
    }
    
    func findVisitNoteCell(location:CGPoint)->VisitNoteCell?{
        for cell in self.visibleCells {
            if cell.frame.contains(location) {
                if let visitNoteCell = cell as? VisitNoteCell{
                    return visitNoteCell
                }
            }
        }
        return nil
    }

}
