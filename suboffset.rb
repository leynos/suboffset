#!/usr/bin/env ruby

usage = "USAGE: suboffset inputfile.ass outputfile.ass delay
Where delay is expressed in seconds as a signed decimal, e.g., 0.21 or -1.23"

unless ARGV.length == 3 then
    print usage + "\n"
    exit 1
end

infilename = ARGV[0]
outfilename = ARGV[1]
delay = ARGV[2].to_f

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
    print "An error occurred: " + e
    exit 1
end
