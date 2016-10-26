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

/**
 * Accidentals increase the pitch of a note. Note that e.g. A♯ and B♭ are
 * essentially the same frequency but have a different meaning based on context.
 */
enum Accidental: String {
    case Sharp = "♯"
    case Flat  = "♭"
}

enum Note: CustomStringConvertible {
    case c(_: Accidental?)
    case d(_: Accidental?)
    case e(_: Accidental?)
    case f(_: Accidental?)
    case g(_: Accidental?)
    case a(_: Accidental?)
    case b(_: Accidental?)

    /**
     * This array contains all notes.
     */
    static let all: [Note] = [
            c(nil),   c(.Sharp),
            d(nil),
            e(.Flat), e(nil),
            f(nil),   f(.Sharp),
            g(nil),
            a(.Flat), a(nil),
            b(.Flat), b(nil)
     ]

    /**
     * This function returns the frequency of this note in the 4th octave.
     */
    var frequency: Double {
        let index = Note.all.index(where: { $0 == self   })! -
                    Note.all.index(where: { $0 == Note.a(nil) })!

        return 440 * pow(2, Double(index) / 12.0)
    }

    /**
     * This property is used in the User Interface to show the name of this
     * note.
     */
    var description: String {
        let concat = { (letter: String, accidental: Accidental?) in
            return letter + (accidental != nil ? accidental!.rawValue : "")
        }

        switch self {
            case let .c(a): return concat("C", a)
            case let .d(a): return concat("D", a)
            case let .e(a): return concat("E", a)
            case let .f(a): return concat("F", a)
            case let .g(a): return concat("G", a)
            case let .a(a): return concat("A", a)
            case let .b(a): return concat("B", a)
        }
    }
}

/**
 * We override the equality operator so we can use `indexOf` on the static array
 * of all notes. Using the `description` property isn't the most idiomatic way
 * to do this but it does the job.
 */
func ==(a: Note, b: Note) -> Bool {
    return a.description == b.description
}
