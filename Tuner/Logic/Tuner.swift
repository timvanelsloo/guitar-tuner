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
import Foundation

protocol TunerDelegate {
    /**
     * The tuner calls this delegate function when it detects a new pitch. The
     * Pitch object is the nearest note (A-G) in the nearest octave. The
     * distance is between the actual tracked frequency and the nearest note.
     * Finally, the amplitude is the volume (note: of all frequencies).
     */
    func tunerDidMeasurePitch(_ pitch: Pitch, withDistance distance: Double,
                              amplitude: Double)
}

class Tuner: NSObject {
    var delegate: TunerDelegate?

    /* Private instance variables. */
    fileprivate var timer:      Timer?
    fileprivate let microphone: AKMicrophone
    fileprivate let analyzer:   AKAudioAnalyzer

    override init() {
        /* Start application-wide microphone recording. */
        AKManager.shared().enableAudioInput()

        /* Add the built-in microphone. */
        microphone = AKMicrophone()
        AKOrchestra.add(microphone)

        /* Add an analyzer and store it in an instance variable. */
        analyzer = AKAudioAnalyzer(input: microphone.output)
        AKOrchestra.add(analyzer)
    }

    func startMonitoring() {
        /* Start the microphone and analyzer. */
        analyzer.play()
        microphone.play()

        /* Initialize and schedule a new run loop timer. */
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                                       selector: #selector(Tuner.tick),
                                                       userInfo: nil,
                                                       repeats: true)
    }

    func stopMonitoring() {
        analyzer.stop()
        microphone.stop()
        timer?.invalidate()
    }

    func tick() {
        /* Read frequency and amplitude from the analyzer. */
        let frequency = Double(analyzer.trackedFrequency.floatValue)
        let amplitude = Double(analyzer.trackedAmplitude.floatValue)

        /* Find nearest pitch. */
        let pitch = Pitch.nearest(frequency)

        /* Calculate the distance. */
        let distance = frequency - pitch.frequency

        /* Call the delegate. */
        self.delegate?.tunerDidMeasurePitch(pitch, withDistance: distance,
                                            amplitude: amplitude)
    }
}
