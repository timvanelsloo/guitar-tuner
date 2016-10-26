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

import AudioKit
import UIKit

class ViewController: UIViewController, TunerDelegate {
    let tuner       = Tuner()
    let displayView = DisplayView()
    let knobView    = KnobView(frame: CGRect(x: 0, y: 0, width: 245, height: 245))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* Update the background color. */
        self.view.backgroundColor = UIColor.black;

        /* Setup the display view. */
        displayView.frame = CGRect(
            origin: CGPoint(x: round(self.view.bounds.width - 141)  / 2,
                            y: round(self.view.bounds.height - 141) / 2),
            size:   CGSize(width: 141, height: 141)
        )
        self.view.addSubview(displayView)

        /* Setup the knob view. */
        knobView.frame = CGRect(
            origin: CGPoint(x: round(self.view.bounds.width - 245) / 2,
                            y: round(self.view.bounds.height - 245) / 2),
            size:   CGSize(width: 245, height: 245)
        )
        self.view.addSubview(knobView)

        /* Start the tuner. */
        tuner.delegate = self
        tuner.startMonitoring()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    func tunerDidMeasurePitch(_ pitch: Pitch, withDistance distance: Double,
                              amplitude: Double) {
        /* Scale the amplitude to make it look more dramatic. */
        displayView.amplitude = min(1.0, amplitude * 25.0)
        displayView.frequency = pitch.frequency

        if amplitude < 0.01 {
            return
        }

        knobView.pitch = pitch

        /* Calculate the difference between the nearest pitch and the second
         * nearest pitch to express the distance in a percentage. */
        let previous   = pitch - 1
        let next       = pitch + 1
        let difference = distance < 0 ?
                         (pitch.frequency - previous.frequency) :
                         (next.frequency  - pitch.frequency)

        knobView.distance = distance / difference / 2.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

