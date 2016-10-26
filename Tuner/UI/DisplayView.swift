/*
 * Copyright (c) 2016 Tim van Elsloo
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import UIKit

class DisplayView: UIView {
    fileprivate let gradientLayer = CAGradientLayer()
    fileprivate let plotView =      PlotView()
    
    var amplitude: Double = 0.0 {
        didSet {
            plotView.amplitude = amplitude
        }
    }
    
    var frequency: Double = 0.0 {
        didSet {
            plotView.frequency = frequency
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        plotView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        plotView.frame = self.bounds
        self.addSubview(plotView)
        
        gradientLayer.colors     = [ UIColor.clear.cgColor,
                                     UIColor.black.cgColor,
                                     UIColor.clear.cgColor ]
        gradientLayer.startPoint = CGPoint.zero
        gradientLayer.endPoint   = CGPoint(x: 1.0, y: 0.0)
        self.layer.mask = gradientLayer
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path      = UIBezierPath(ovalIn: self.bounds).cgPath
        gradientLayer.frame = self.bounds
        gradientLayer.mask  = maskLayer
    }
}
