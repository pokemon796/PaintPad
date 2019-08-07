//
//  PhotoEditingViewController.swift
//  PaintPad Editor
//
//  Created by Ozan Mirza on 7/19/19.
//  Copyright © 2019 examplecompany. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import MobileCoreServices
import CoreMedia

class PhotoEditingViewController: UIViewController, PHContentEditingController {

    var input: PHContentEditingInput?
    
    @IBOutlet weak var loadingView: UIVisualEffectView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var toolIcon: UIButton!
    @IBOutlet weak var colors: UIStackView!
    @IBOutlet weak var tools: UIStackView!
    @IBOutlet weak var colors_bg: UIVisualEffectView!
    
    var lastPoint = CGPoint.zero
    var swiped = false
    var isInMenu = false
    
    var currentColor:UIButton!
    var red:CGFloat = 0.0
    var green:CGFloat = 0.0
    var blue:CGFloat = 0.0
    var alpha:CGFloat = 1.0
    
    var tool:UIImageView!
    var isDrawing = true
    var temp:CGFloat = 5
    var brushSize:CGFloat = 5
    var selectedImage:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tool = UIImageView()
        tool.frame = CGRect(x: self.view.bounds.size.width, y: self.view.bounds.size.height, width: 38, height: 38)
        tool.image = #imageLiteral(resourceName: "paintBrush")
        self.view.addSubview(tool)
        
        for i in 0..<colors.subviews.count {
            colors.subviews[i].layer.cornerRadius = colors.subviews[i].frame.size.height / 2
            colors.subviews[i].layer.masksToBounds = true
        }
        
        currentColor = colors.subviews[0] as? UIButton
        
        changeColor(to: 0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isInMenu {
            swiped = false
            if let touch = touches.first {
                lastPoint = touch.location(in: self.view)
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.view.subviews.last!.alpha = 0
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.view.subviews.last!.removeFromSuperview()
                self.isInMenu = false
            }
        }
    }
    
    func drawLines(fromPoint:CGPoint,toPoint:CGPoint) {
        UIGraphicsBeginImageContext(self.view.frame.size)
        imageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        let context = UIGraphicsGetCurrentContext()
        
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        tool.center = toPoint
        
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(brushSize)
        context?.setStrokeColor(UIColor(red: red, green: green, blue: blue, alpha: alpha).cgColor)
        
        context?.strokePath()
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        
        if let touch = touches.first {
            let currentPoint = touch.location(in: self.view)
            drawLines(fromPoint: lastPoint, toPoint: currentPoint)
            
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            drawLines(fromPoint: lastPoint, toPoint: lastPoint)
        }
    }
    @IBAction func reset(_ sender: AnyObject) {
        self.imageView.image = nil
    }
    @IBAction func save(_ sender: AnyObject) {
        isInMenu = true
        let bg = UIVisualEffectView(frame: self.view.bounds)
        bg.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        bg.alpha = 0
        self.view.addSubview(bg)
        let bg_sub = UILabel(frame: CGRect(x: 16, y: bg.frame.size.height, width: 300, height: 300))
        bg_sub.font = UIFont.systemFont(ofSize: 25)
        bg_sub.textColor = UIColor.white
        bg_sub.textAlignment = .center
        bg_sub.text = "This feature is unavailable in photo editing mode."
        bg_sub.numberOfLines = 2
        bg_sub.center.x = bg.center.x
        bg_sub.layer.cornerRadius = 25
        bg_sub.layer.masksToBounds = true
        bg_sub.backgroundColor = UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1)
        bg.contentView.addSubview(bg_sub)
        UIView.animate(withDuration: 0.5) {
            bg.alpha = 1
            bg_sub.center = bg.center
        }
    }
    
    func changeColor(to section: Int) {
        var count = 0
        colors.subviews.forEach { color in
            if count == section {
                UIView.animate(withDuration: 0.5, animations: {
                    color.layer.borderColor = UIColor.lightGray.cgColor
                    color.layer.borderWidth = 5
                })
            } else {
                UIView.animate(withDuration: 0.5, animations: {
                    color.layer.borderWidth = 0
                })
            }
            count += 1
        }
    }
    
    @IBAction func erase(_ sender: AnyObject) {
        if (isDrawing) {
            (red,green,blue) = (1,1,1)
            tool.image = #imageLiteral(resourceName: "EraserIcon")
            toolIcon.setImage(#imageLiteral(resourceName: "paintBrush"), for: .normal)
            self.temp = self.brushSize
            self.brushSize = 20
        } else {
            (red,green,blue) = (0,0,0)
            tool.image = #imageLiteral(resourceName: "paintBrush")
            toolIcon.setImage(#imageLiteral(resourceName: "EraserIcon"), for: .normal)
            self.brushSize = self.temp
        }
        
        isDrawing = !isDrawing
    }
    
    @IBAction func settings(_ sender: AnyObject) {}
    
    @IBAction func colorsPicked(_ sender: AnyObject) {
        changeColor(to: sender.tag)
        
        if sender.tag == 0 {
            (red,green,blue) = (1,0,0)
        } else if sender.tag == 1 {
            (red,green,blue) = (0,1,0)
        } else if sender.tag == 2 {
            (red,green,blue) = (0,0,1)
        } else if sender.tag == 3 {
            (red,green,blue) = (1,0,1)
        } else if sender.tag == 4 {
            (red,green,blue) = (1,1,0)
        } else if sender.tag == 5 {
            (red,green,blue) = (0,1,1)
        } else if sender.tag == 6 {
            (red,green,blue) = (1,1,1)
        } else if sender.tag == 7 {
            (red,green,blue) = (0,0,0)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        let settingsVC = segue.destination as! SettingsVC
        settingsVC.delegate = self
        settingsVC.red = red
        settingsVC.green = green
        settingsVC.blue = blue
        settingsVC.opacity = alpha
        settingsVC.brushSize = brushSize
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.colorsPicked(self.currentColor)
            print("The thigs got ran?")
        }
    }
    
    // MARK: - PHContentEditingController
    
    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
        // Inspect the adjustmentData to determine whether your extension can work with past edits.
        // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
        return false
    }
    
    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
        // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
        // If you returned true from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
        // If you returned false, the contentEditingInput has past edits "baked in".
        input = contentEditingInput
        imageView.image = input!.displaySizeImage
    }
    
    func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
        // Update UI to reflect that editing has finished and output is being rendered.
        loadingView.removeFromSuperview()
        self.view.addSubview(loadingView)
        // Render and provide output on a background queue.
        DispatchQueue.global().async {
            // Create editing output from the editing input.
            self.processImage(to: PHContentEditingOutput(contentEditingInput: self.input!), completionHandler: completionHandler)
        }
    }
    
    func processImage(to output: PHContentEditingOutput, completionHandler: ((PHContentEditingOutput?) -> Void)) {
        
        // Load full-size image to process from input.
        guard let url = input!.fullSizeImageURL
            else { fatalError("missing input image url") }
        guard let inputImage = CIImage(contentsOf: url)
            else { fatalError("can't load input image to apply edit") }
        
        // Define output image with Core Image edits.
        let outputImage = inputImage.oriented(forExifOrientation: input!.fullSizeImageOrientation)
        
        // Usually you want to create a CIContext early and reuse it, but
        // this extension uses one (explicitly) only on exit.
        let context = imageView.image!.ciImage! as! CIContext
        // Render the filtered image to the expected output URL.
        if #available(OSXApplicationExtension 10.12, iOSApplicationExtension 10.0, *) {
            // Use Core Image convenience method to write JPEG where supported.
            do {
                try context.writeJPEGRepresentation(of: outputImage, to: output.renderedContentURL, colorSpace: inputImage.colorSpace!)
                completionHandler(output)
            } catch let error {
                NSLog("can't write image: \(error)")
                completionHandler(nil)
            }
        } else {
            // Use CGImageDestination to write JPEG in older OS.
            guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
                else { fatalError("can't create CGImage") }
            guard let destination = CGImageDestinationCreateWithURL(output.renderedContentURL as CFURL, kUTTypeJPEG, 1, nil)
                else { fatalError("can't create CGImageDestination") }
            CGImageDestinationAddImage(destination, cgImage, nil)
            let success = CGImageDestinationFinalize(destination)
            if success {
                completionHandler(output)
            } else {
                completionHandler(nil)
            }
        }
        
    }
    
    var shouldShowCancelConfirmation: Bool {
        // Determines whether a confirmation to discard changes should be shown to the user on cancel.
        // (Typically, this should be "true" if there are any unsaved changes.)
        return true
    }
    
    func cancelContentEditing() {
        // Clean up temporary files, etc.
        // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
    }
}

extension PhotoEditingViewController:UINavigationControllerDelegate,UIImagePickerControllerDelegate,SettingsVCDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imagePicked = info[.originalImage] as? UIImage {
            // We got the user's image
            self.selectedImage = imagePicked
            self.imageView.image = selectedImage
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func settingsViewControllerDidFinish(_ settingsVC: SettingsVC) {
        self.red = settingsVC.red
        self.green = settingsVC.green
        self.blue = settingsVC.blue
        self.alpha = settingsVC.opacity
        self.brushSize = settingsVC.brushSize
    }
}

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
        opacitySlider.value = Float(opacity)
        redSlider.value = Float(red)
        greenSlider.value = Float(green)
        blueSlider.value = Float(red)
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
        opacityLabel.text = String(format: "%\(0.2)f", opacity)
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

public class SmoothCurvedLinesView: UIView {
    
    public var strokeColor = UIColor.white
    public var lineWidth: CGFloat = 10
    public var snapshotImage: UIImage?
    public var isEnabled: Bool = true
    
    private var path: UIBezierPath?
    private var temporaryPath: UIBezierPath?
    private var points = [CGPoint]()
    
    public override func draw(_ rect: CGRect) {
        snapshotImage?.draw(in: rect)
        
        strokeColor.setStroke()
        
        path?.stroke()
        temporaryPath?.stroke()
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled {
            if let touch = touches.first {
                points = [touch.location(in: self)]
            }
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled {
            guard let touch = touches.first else { return }
            let point = touch.location(in: self)
            
            points.append(point)
            
            updatePaths()
            
            setNeedsDisplay()
        }
    }
    
    private func updatePaths() {
        // update main path
        
        while points.count > 4 {
            points[3] = CGPoint(x: (points[2].x + points[4].x)/2.0, y: (points[2].y + points[4].y)/2.0)
            
            if path == nil {
                path = createPathStarting(at: points[0])
            }
            
            path?.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])
            
            points.removeFirst(3)
            
            temporaryPath = nil
        }
        
        // build temporary path up to last touch point
        
        if points.count == 2 {
            temporaryPath = createPathStarting(at: points[0])
            temporaryPath?.addLine(to: points[1])
        } else if points.count == 3 {
            temporaryPath = createPathStarting(at: points[0])
            temporaryPath?.addQuadCurve(to: points[2], controlPoint: points[1])
        } else if points.count == 4 {
            temporaryPath = createPathStarting(at: points[0])
            temporaryPath?.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled {
            finishPath()
        }
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        if isEnabled {
            finishPath()
        }
    }
    
    private func finishPath() {
        constructIncrementalImage()
        path = nil
        setNeedsDisplay()
    }
    
    private func createPathStarting(at point: CGPoint) -> UIBezierPath {
        let localPath = UIBezierPath()
        
        localPath.move(to: point)
        
        localPath.lineWidth = lineWidth
        localPath.lineCapStyle = .round
        localPath.lineJoinStyle = .round
        
        return localPath
    }
    
    private func constructIncrementalImage() {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        strokeColor.setStroke()
        snapshotImage?.draw(at: .zero)
        path?.stroke()
        temporaryPath?.stroke()
        snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    public func restartDrawingView() {
        snapshotImage = nil
        points = []
        setNeedsDisplay()
    }
    
    public func close() {
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.fromValue = self.layer.borderWidth
        animation.toValue = self.frame.size.width
        animation.duration = 1.5
        self.layer.add(animation, forKey: "borderWidth")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            self.backgroundColor = UIColor.white
        }
    }
    
    public func open() {
        let background = UIView(frame: self.bounds)
        background.backgroundColor = UIColor.black
        background.transform = CGAffineTransform(scaleX: 0, y: 0)
        self.addSubview(background)
        UIView.animate(withDuration: 0.5, animations: {
            background.transform = CGAffineTransform.identity
        }) { (finished: Bool) in
            self.backgroundColor = UIColor.clear
            self.subviews.forEach { view in view.removeFromSuperview() }
        }
    }
}
