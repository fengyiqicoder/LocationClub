//
//  AddNewLocationViewController.swift
//  igloo
//
//  Created by 冯奕琦 on 2019/1/31.
//  Copyright © 2019 冯奕琦. All rights reserved.
//

import UIKit
import MapKit

class AddNewLocationViewController: UIViewController,UITextFieldDelegate {

    //MARK:IBOutlet
    @IBOutlet weak var locationNameTextFeild: UITextField!
    @IBOutlet weak var locationDescribeTextFeild: UITextField!
    @IBOutlet weak var iconKindStringTextField: UITextField!
    
    //icons
    @IBOutlet weak var iconImageButton1:UIButton!
    @IBOutlet weak var iconImageButton2:UIButton!
    @IBOutlet weak var iconImageButton3:UIButton!
    @IBOutlet weak var iconImageButton4:UIButton!
    @IBOutlet weak var iconImageButton5:UIButton!
    @IBOutlet weak var iconImageButton6:UIButton!
    @IBOutlet weak var iconImageButton7:UIButton!
    @IBOutlet weak var iconImageButton8:UIButton!
    @IBOutlet weak var iconImageButton9:UIButton!
    @IBOutlet weak var iconImageButton10:UIButton!
    @IBOutlet weak var iconImageButton11:UIButton!
    @IBOutlet weak var iconImageButton12:UIButton!
    @IBOutlet weak var iconImageButton13:UIButton!
    @IBOutlet weak var iconImageButton14:UIButton!
    var iconImageButtonArray:[UIButton]{
        return [iconImageButton1,iconImageButton2,iconImageButton3,iconImageButton4,iconImageButton5,iconImageButton6,iconImageButton7,iconImageButton8,iconImageButton9,iconImageButton10,iconImageButton11,iconImageButton12,iconImageButton13,iconImageButton14]
    }
    //其他
    @IBOutlet weak var mapLocationImageLocationInfoStringLabel: UITextField!
    @IBOutlet weak var mapLocationImageVIew: UIImageView!
    @IBOutlet weak var mapLocationImageButton: UIButton!
    @IBOutlet weak var isPublicSwitch: UISwitch!
    @IBOutlet weak var iconLocationImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationNameTextFeild.delegate = self
        locationDescribeTextFeild.delegate = self
        //判断是否需要加入旧数据
        if let data = self.oldLocationData {
            locationNameTextFeild.text = data.locationName
            locationDescribeTextFeild.text = data.locationDescription
            //设置Location图标
            let kindImage = Constants.getIconStruct(name: data.iconKindString)!.image
            for button in iconImageButtonArray{
                if button.image(for: .normal) == kindImage {
                    selectIcon(sender:button )
                }
            }
            //设置地理位置
            let coordinate = CLLocationCoordinate2D(latitude: data.locationLatitudeKey, longitude: data.locationLongitudeKey)
            currenLocatinInfoString = data.locationInfoWord
            currenLocation2D = coordinate
            showing(location: coordinate)
            //设置是否公开
            isPublicSwitch.isOn = data.isPublic
        }
    }
    
    //MARK: Properties
    
    var currentIconString:String = "Defualt"
    var currenLocatinInfoString:String = "" {
        didSet{
            mapLocationImageLocationInfoStringLabel.text = currenLocatinInfoString
        }
    }
    var currenLocation2D:CLLocationCoordinate2D?
    
    @IBAction func selectIcon(sender:UIButton){
        for button in iconImageButtonArray {
            button.isSelected = false
        }
        //选择这个sender
        sender.isSelected = true
        //更改与它关联的UI控件
        let image = sender.image(for: .normal)!
        let iconData = Constants.getIconStruct(image:image)!
        currentIconString = iconData.kind
        iconKindStringTextField.text = iconData.kindInChinese
    }
    
    //MARK: Segue
    
    var oldLocationData:LocationInfoLocal?
    func setDataInForEdit(data:LocationInfoLocal)  {
        oldLocationData = data
    }
    
    @IBAction func segueToChoseLocationVC() {
        performSegue(withIdentifier: "segueToChoseLocationImage", sender: nil)
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        if let presentingVC = self.presentingViewController {
            print(presentingVC)
            if self.oldLocationData != nil {
                performSegue(withIdentifier: "unwindToGreat", sender: nil)
            }else{
                performSegue(withIdentifier: "unwindToMyLocation", sender: nil)
            }
        }
    }
    
    
    @IBAction func unwindFromLocationChosen(segue:UIStoryboardSegue){
        //装入地理位置
        if let location = self.currenLocation2D{
            showing(location: location)
        }
    }
    
    func showing(location:CLLocationCoordinate2D) {
        //imageView装修一下
        mapLocationImageVIew.layer.cornerRadius = 11
        mapLocationImageVIew.layer.borderColor = #colorLiteral(red: 0.02745098039, green: 0.462745098, blue: 0.4705882353, alpha: 1)
        mapLocationImageVIew.layer.borderWidth = 2
        mapLocationImageVIew.layer.masksToBounds = true
        MapSnapShotter.getMapImageForCell(latitude: location.latitude, longitude: location.longitude) { (image) in
            self.mapLocationImageVIew.image = image
            self.iconLocationImage.isHidden = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //判断是否有locationData
        if let locationData = self.locationDataToAdd{
            if let upVC = segue.destination as? MainTabBarController{
                //把数据传递给MainTabBarVC
                upVC.newLocationData = locationData
            }
        }
    }
    
    //MARK: func
    //完成之后生成一个LocationInfoLocal并且上传
    
    var locationDataToAdd:LocationInfoLocal?
    
    @IBAction func done()  {//新的或者修改一个LocationData
        //生成新的locationData
        if let name = locationNameTextFeild.text , let description = locationDescribeTextFeild.text ,
            let location = self.currenLocation2D,name != "",description != ""{
            //创建新的locationInfoLocal
            let locationID = String(location.latitude)+"_"+String(location.longitude)+"_"+Date.changeDateToString(date: Date())
            let data = LocationInfoLocal(locationID: locationID, locationName: name, iconKindString: self.currentIconString, locationDescription: description, locationLatitudeKey: location.latitude, locationLongitudeKey: location.longitude, isPublic: isPublicSwitch.isOn, locationLikedAmount: 0, locationInfoWord: self.currenLocatinInfoString, locationInfoImageURL: "nil", VisitedNoteID: [], noteIDs: [])
            //装入self
            self.locationDataToAdd = data
            performSegue(withIdentifier: "unwindToMyLocation", sender: nil)
        }else{
            showErrorSheet()
        }
        
    }
    
    func showErrorSheet() {
        let alertVC = UIAlertController(title: "地点信息不完成", message: nil, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "好的", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }


    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}