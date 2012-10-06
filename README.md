# Overview

This is a simple tool written in Ruby 1.8 that will allow you to add a delay (positive or negative) to a Substation Alpha (ASS/SSA) subtitle file.  At present, this is the only format supported.

# USAGE

Set the script as executable before first use.

    ./suboffset.rb inputfile.ass outputfile.ass delay

Where _delay_ is expressed in seconds as a signed decimal, e.g., 0.21 or -1.23

Place the script in `~/bin` for ease of use if desired.
