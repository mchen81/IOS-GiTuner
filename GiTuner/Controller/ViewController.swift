//
//  ViewController.swift
//  GiTuner
//
//  Created by 陳孟澤 on 2020/6/2.
//  Copyright © 2020 Jerry Chen. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {
    
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var offsetLabel: UILabel!
    @IBOutlet weak var notesView: UIPickerView!
    
    
    @IBOutlet weak var left1: UIImageView!
    @IBOutlet weak var left2: UIImageView!
    @IBOutlet weak var middle: UIImageView!
    @IBOutlet weak var right2: UIImageView!
    @IBOutlet weak var right1: UIImageView!
    
    let audioTracker = AudioTracker()
    var rotationAngle : CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        AKSettings.audioInputEnabled = true
        initPickerViewDelegation()
        rotatePickerView(pickerView: notesView)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AudioKit.output = audioTracker.silence
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        
        Timer.scheduledTimer(timeInterval: 0.2,
                             target: self,
                             selector: #selector(ViewController.updateUI),
                             userInfo: nil,
                             repeats: true)
    }
    
    @objc func updateUI() {
        
        let (rowNumber, frequency, offset) = self.audioTracker.getFrequncyInfo()
        if rowNumber != nil {
            let offset10 = Int(offset * 10)
            
            frequencyLabel.text = String(format: "%.2f", frequency)
            offsetLabel.text = "\(offset > 0 ? "+" : "")\(offset10)"
            notesView.selectRow(rowNumber!, inComponent: 0, animated: true)
            
            middle.alpha = 1
            if(offset10 > 20){
                setImages(0,0,1,1,1)
            }else if(offset10 > 8){
                setImages(0,0,1,1,1)
            }else if(offset10 < -20){
                setImages(1,1,1,0,0)
            }else if(offset10 < -8){
                setImages(0,1,1,0,0)
            }else {
                setImages(0, 0, 1, 0, 0)
            }
            
        }
    }
    
    func setImages(_ l1: CGFloat, _ l2: CGFloat, _ mid: CGFloat, _ r2: CGFloat, _ r1: CGFloat){
        DispatchQueue.main.async {
            self.left1.alpha = l1
            self.left2.alpha = l2
            self.middle.alpha = mid
            self.right2.alpha = r2
            self.right1.alpha = r1
        }
         
    }

}

//MARK: - Picker View
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func initPickerViewDelegation(){
        rotationAngle = -90 * (.pi / 180 )
        notesView.delegate = self
        notesView.dataSource = self
        // notesView.selectRow(items.count / 2, inComponent:0 , animated: false)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // remove picker view board line
        notesView.subviews.forEach({
            $0.isHidden = $0.frame.height < 1.0
        })
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return audioTracker.octaves.count * audioTracker.notes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return CGFloat(100.0)
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return CGFloat(100.0)
    }
    
    func rotatePickerView(pickerView : UIPickerView) {
        let y = pickerView.frame.origin.y
        let x = pickerView.frame.origin.x

        pickerView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        pickerView.frame = CGRect(x: x, y: y, width: pickerView.frame.height , height: pickerView.frame.width)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label = UILabel()
        label.font = UIFont(name: "System", size: 40)
        label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
        label.transform = CGAffineTransform(rotationAngle: 90 * (.pi / 180 ))
        
        let (note, octave) = audioTracker.convertRowToNote(row)
        
        label.text = "\(note) \(octave)"
        return label
    }
    
}

