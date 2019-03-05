//
//  SettingsVC.swift
//  Drawing App
//
//  Created by roycetanjiashing on 18/12/16.
//  Copyright © 2016 examplecompany. All rights reserved.
//

import UIKit

protocol SettingsVCDelegate:class {
    func settingsViewControllerDidFinish(_ settingsVC:SettingsVC)
}

class SettingsVC: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var brushSizeLabel: UILabel!
    @IBOutlet var opacityLabel: UILabel!
    @IBOutlet var redLabel: UILabel!
    @IBOutlet var greenLabel: UILabel!
    @IBOutlet var blueLabel: UILabel!
    
    @IBOutlet var brushSizeSlider: UISlider!
    @IBOutlet var opacitySlider: UISlider!
    @IBOutlet var redSlider: UISlider!
    @IBOutlet var greenSlider: UISlider!
    @IBOutlet var blueSlider: UISlider!
    
    var brushSize:CGFloat = 0.0
    var opacity:CGFloat = 0.0
    var red:CGFloat = 0.0
    var green:CGFloat = 0.0
    var blue:CGFloat = 0.0
    
    var delegate:SettingsVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        drawPreview(red: red, green: green, blue: blue, opacity:opacity)
        
        brushSizeSlider.value = Float(brushSize)
        brushSizeLabel.text = String(Int(brushSize))
        
        opacitySlider.value = Float(opacity)
        opacityLabel.text = String(Int(opacity))
        
        redSlider.value = Float(red)
        redLabel.text = String(Int(redSlider.value * 255))
        
        greenSlider.value = Float(green)
        greenLabel.text = String(Int(greenSlider.value * 255))
        
        blueSlider.value = Float(red)
        blueLabel.text = String(Int(blueSlider.value * 255))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(_ sender: Any) {
        if delegate != nil {
            delegate?.settingsViewControllerDidFinish(self)
        }
        
        dismiss(animated: true, completion: nil)
    }
    @IBAction func brushSizeChanged(_ sender: Any) {
        brushSize = CGFloat((sender as! UISlider).value)
        drawPreview(red: red, green: green, blue: blue, opacity:opacity)
        brushSizeLabel.text = String(Int(brushSize))
    }
    @IBAction func opacityChanged(_ sender: Any) {
        opacity = CGFloat((sender as! UISlider).value)
        drawPreview(red: red, green: green, blue: blue, opacity:opacity)
        opacityLabel.text = String(Int(opacity))
    }
    @IBAction func redSliderChanged(_ sender: Any) {
        
        let slider = sender as! UISlider
        red = CGFloat(slider.value)
        drawPreview(red: red, green: green, blue: blue, opacity:opacity)
        redLabel.text = "\(Int(slider.value * 255))"
        
    }
    @IBAction func greenSliderChanged(_ sender: Any) {
        let slider = sender as! UISlider
        green = CGFloat(slider.value)
        drawPreview(red: red, green: green, blue: blue, opacity:opacity)
        greenLabel.text = "\(Int(slider.value * 255))"
    }
    @IBAction func blueSliderChanged(_ sender: Any) {
        let slider = sender as! UISlider
        blue = CGFloat(slider.value)
        drawPreview(red: red, green: green, blue: blue, opacity:opacity)
        blueLabel.text = "\(Int(slider.value * 255))"
    }
    
    func drawPreview (red:CGFloat,green:CGFloat,blue:CGFloat, opacity:CGFloat) {
        imageView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: opacity)
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
