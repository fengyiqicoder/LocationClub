//
//  MarsTableView.swift
//  igloo
//
//  Created by 冯奕琦 on 2019/1/21.
//  Copyright © 2019 冯奕琦. All rights reserved.
//

import UIKit

class MarsTableView: UITableView,UITableViewDelegate,UITableViewDataSource {
    
    var viewControllerDelegate:MyLocationDelegate!
    //MARK:使用[(Rank2,Rank3)]作为数据源,进行init
    
    var locationDataArray:[(rank2:LocationInfoRank2,rank3:LocationInfoRank3)]!
    func setDataIn(locationDataArray:[(rank2:LocationInfoRank2,rank3:LocationInfoRank3)]){
        //进行数据的装入
        self.locationDataArray = locationDataArray
        //delegate的装入
        self.delegate = self
        self.dataSource = self
        //刷新
        self.reloadData()
    }
    
    //MARK:高度问题,与屏幕宽度成比例
    
    var locationCellHeight:CGFloat {
        let weight = self.frame.width
        return weight/Constants.locationCellRadio
    }
    
    
    //MARK: TableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationDataArray.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return locationCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        //Segue到下个VC
        viewControllerDelegate.didSelectCell(index: indexPath.row)
    }
    
   
    //MARK: DataSource
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {//于确认删除的方法
        locationDataArray.remove(at: indexPath.row)//要先删除dataSource 更新前后的行数必须要相等
        viewControllerDelegate.deleteLocation(index: indexPath.row, reload: false)
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing{//禁用左滑到底删除
            return UITableViewCell.EditingStyle.delete
        }else{
            return UITableViewCell.EditingStyle.none
        }
    }
    
    var savePhotos:Bool?
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") as! LocationCell
        let data = locationDataArray[indexPath.row]
        //获取image
        var image:UIImage = #imageLiteral(resourceName: "defualtMapImage")//默认Image
        let imageURL = data.rank2.locationInfoImageURL
        print("MarsTableView NewLocationCell")
        print("ImageURL")
        print(imageURL)
        if imageURL == "nil"{//查看有没有旧的
            if let oldImage = MapSnapShotter.getExistMapImage(latitude: data.rank3.locationLatitudeKey, longitude: data.rank3.locationLongitudeKey){
                image = oldImage   
            }else{
                //获取地图截图
                MapSnapShotter.getMapImageForCell(latitude: data.rank3.locationLatitudeKey,
                                                  longitude: data.rank3.locationLongitudeKey) { (mapImage) in
                                                    
                                                    image = mapImage
                                                    //重新装入数据
                                                    cell.locationInfoImage.image = mapImage
                }
            }
        }else{
            //从Network获取
            Network.getImage(at: imageURL,savePhotos: savePhotos, landingAction: { (newImage) in
                image = newImage
                //重新装入数据
                cell.locationInfoImage.image = newImage
            })
        }
        //loadtheData
        cell.set(data: data.rank2, image: image)
        cell.index = indexPath.row
        return cell
    }
    //test
    
}


