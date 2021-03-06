#!/usr/bin/env ruby

# Copyright © 2011, David McIntosh <dmcintosh@df12.net>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# A tool to add a delay to a Substation Alpha (ASS/SSA) subtitle file 

USAGE = "suboffset.rb inputfile.ass outputfile.ass delay
Where delay is expressed in seconds as a signed decimal, e.g., 0.21 or -1.23"

unless ARGV.length == 3 then
    print "USAGE: " + USAGE + "\n"
    exit 1
end

infilename = ARGV[0]
outfilename = ARGV[1]
delay = ARGV[2].to_f

if File.exists? infilename and File.exists? outfilename and 
    File.identical? infilename, outfilename then
    print "Input and output cannot be the same file\n"
    exit 1
end

# Add a given delay to a SSA time string
def offsettime(time, delay)
    parts = time.split(":")
    hours = parts[0].to_f
    minutes = parts[1].to_f + hours * 60
    seconds = parts[2].to_f + minutes * 60
    seconds += delay
    return "%d:%02d:%05.2f" % [(seconds/60/60), ((seconds/60)%60), (seconds%60)]
end

# Add a given delay to a SSA event's start and end times
def offsetevent(type, payload, delay)
    parts = payload.split(",", 10)
    parts[1] = offsettime parts[1], delay
    parts[2] = offsettime parts[2], delay
    return type + ": " + parts.join(",") + "\n"
end

begin
    infile = File.open(infilename, 'r')
    outfile = File.open(outfilename, 'w')

    infile.each_line do |line|
        type = line.split(": ")[0]
        match = line.match(/\:\s(.*)/)
        payload = if match then match[1] else "" end
        case type
            when "Dialogue", "Picture", "Sound", "Movie", "Command"
                offsetline = offsetevent type, payload, delay
            else
                offsetline = line
        end

        outfile.write offsetline
    end
rescue Exception=>e
    print "An error occurred: " + e + "\n"
    exit 1
end
