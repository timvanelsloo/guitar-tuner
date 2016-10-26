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

class AudioPlot: AKAudioPlot {
    var frequency:     Double = 1.0
    var nextFrequency: Double = 1.0

    var amplitude:     Double = 0.0
    var nextAmplitude: Double = 0.0

    var amplifier:     Double = 1.0

    var time:          Double = 0.0

    override func buffer(withCsound cs: CsoundObj) -> Data {
        let length    = Int(AKSettings.shared().numberOfChannels) *
                        Int(AKSettings.shared().samplesPerControlPeriod) * 4
        let num       = length / 4
//        var floats    = UnsafeMutableRawPointer(malloc(length))
        var floats    = UnsafeMutableRawPointer.allocate(bytes: num-1, alignedTo: 1)
        floats.initializeMemory(as: Float.self, count: num-1, to: 1)
//        floats.initializeMemory(as: Float.self, at: length, count:length, to: 1)

        /* The phase and amplitude are different for each line to get a nice
         * gimmick. */
        let phase     = (self.amplifier + 0.8) / 1.8

        for i in 0 ... num - 1 {
            /* The amplitude is placed within the for-loop because it can fade
             * to a slightly different value during one plot refresh. */
            let amplitude = self.amplifier * self.amplitude

            /* It is incredibly important that `time` and `phase` aren't
             * multiplied with the frequency or else it will bump at each
             * frequency change. */
            var t = (time + Double(i) / Double(num) * self.frequency + phase)

//            floats[i] = Float(sin(t * 2 * 3.14))
            var v = Float(sin(t * 2 * 3.14))
            floats.storeBytes(of: v, toByteOffset: i, as: Float.self)
//            floats.storeBytes(of: v, as: Float.self)
            
            /* It is multiplied with a "regular" 0.5 Hz sine to get both ends
             * to fade out nicely. It's sort of a simplistic window function. */
            t = Double(i) / Double(num)
//            floats[i] *= Float(sin(t * 1 * 3.14) * amplitude)
            v *= Float(sin(t * 1 * 3.14) * amplitude)
            floats.storeBytes(of: v, toByteOffset: i, as: Float.self)
//            floats.storeBytes(of: v, as: Float.self)
            //            floats[i] *= 1 - pow(1 - Float(i) / Float(num), 2.0)
            v *= 1 - pow(1 - Float(i) / Float(num), 2.0)
            floats.storeBytes(of: v, toByteOffset: i, as: Float.self)
//            floats.storeBytes(of: v, as: Float.self)
            time += self.frequency / 44100 / 2

            /* Fade smoothly to the next frequency and amplitude. */
            self.frequency += (nextFrequency - self.frequency) / 44100.0 / 4.0
            self.amplitude += (nextAmplitude - self.amplitude) / 44100.0 / 2.0
        }

        /* We keep the time between 0 and 1 to make sure it never overflows /
         * loses the necessary precision. */
        time = fmod(time, 1.0)

        return Data(bytesNoCopy: &floats, count: length, deallocator: .free)
    }
}

class PlotView: UIView {
    var amplitude: Double = 0.0 {
        didSet {
            for plot in plots {
                plot.nextAmplitude = amplitude
            }
        }
    }

    var frequency: Double = 0.0 {
        didSet {
            for plot in plots {
                plot.nextFrequency = frequency / 80.0
            }
        }
    }

    fileprivate let plots = (0 ... 4).map { _ in AudioPlot() }

    override init(frame: CGRect) {
        super.init(frame: frame)

        /* Setup the all plots. */
        for i in 0 ... 4 {
            plots[i].autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
            plots[i].backgroundColor  = UIColor.clear;
            plots[i].lineColor        = UIColor.white;
            plots[i].lineWidth        = 1.0
            plots[i].frequency        = 0.0
            plots[i].amplifier        = abs(1.0 - Double(i) * 0.4) * (i % 2 == 0 ? 1.0 : -1.0)
            plots[i].alpha            = 1.0 - CGFloat(i) * 0.2
            self.addSubview(plots[i])
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
