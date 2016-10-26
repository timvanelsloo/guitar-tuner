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

import Foundation

class Pitch: CustomStringConvertible {
    /**
     * The note is one of C, C#, D, Em, E, F, F#, G, Am, A, Bm, B.
     */
    let note: Note

    /**
     * The octave is a whole integer between 0 and 9.
     */
    let octave: Int

    /**
     * The frequency is a floating point integer according to the International
     * Scientific Pitch Notation table.
     */
    let frequency: Double

    fileprivate init(note: Note, octave: Int) {
        self.note      = note
        self.octave    = octave
        self.frequency = note.frequency * pow(2, Double(octave) - 4)
    }

    /**
     * This array contains all pitches for all notes in the 2nd to 6th octaves.
     * First, the octaves are mapped to arrays of pitches for each note within
     * each octave.
     */
    static let all = Array((2 ... 6).map { octave -> [Pitch] in
        Note.all.map { note -> Pitch in
            Pitch(note: note, octave: octave)
        }
    }.joined())

    /**
     * This function returns the nearest pitch to the given frequency in Hz.
     */
    class func nearest(_ frequency: Double) -> Pitch {
        /* Map all pitches to tuples of the pitch and the distance between the
         * frequency for that pitch and the given frequency. */
        var results = all.map { pitch -> (pitch: Pitch, distance: Double) in
            (pitch: pitch, distance: abs(pitch.frequency - frequency))
        }

        /* Sort array based on distance. */
        results.sort { $0.distance < $1.distance }

        /* Return the first result (i.e. nearest pitch). */
        return results.first!.pitch
    }

    /**
     * This property is used in the User Interface to show the "name" of this
     * pitch.
     */
    var description: String {
        return "\(note)\(octave)"
    }
}

/**
 * We override the equality operator so we can use `indexOf` on the static array
 * of all pitches. Using the `description` property isn't the most idiomatic way
 * to do this but it does the job.
 */
func ==(a: Pitch, b: Pitch) -> Bool {
    return a.description == b.description
}

/**
 * We override the add operator so we can get to the next (or previous) pitches
 * simply by adding or subtracting an int to or from the pitch.
 */
func +(pitch: Pitch, offset: Int) -> Pitch {
    let all   = Pitch.all
    let index = all.index(where: { $0 == pitch })! + offset

    return all[(index % all.count + all.count) % all.count]
}

/**
 * Lastly, we need to override the - operator too but we can simply call +
 * with a negative offset.
 */
func -(pitch: Pitch, offset: Int) -> Pitch { return pitch + (-offset) }
