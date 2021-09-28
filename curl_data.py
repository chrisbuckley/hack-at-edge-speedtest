#!/usr/bin/env python

import os, sys


def readCurlData(fname):
    lines = []
    with open(fname) as f:
        for line in f:
            lines.append(line.split())
    return lines[3:]


def convertUnits(lines):
    converted = []
    for line in lines:
        if len(line) == 12 and not "--" in line[9]:
            # curl reports speed in bytes per second
            if 'k' in line[11]:
                line[11] = str(float(line[11].replace('k','')) * 8 * 1024)
            elif 'M' in line[11]:
                line[11] = str(float(line[11].replace('M','')) * 8 * 1048576)
            elif 'G' in line[11]:
                line[11] = str(float(line[11].replace('G','')) * 8 * 1073741824)
            converted.append([line[9], line[11]])
    return converted


def writeGnuplotData(fname, lines):
    fname = fname + ".gnuplot.data"
    with open(fname, 'w') as f:
        for line in lines:
            f.write(','.join(line) + '\n')


def plot(fname):
    gp_fname = fname + ".gp"
    gpdata_fname = fname + ".gnuplot.data"
    png_fname = fname + ".png"

    f = open(gp_fname, "w")
    f.write('set output "%s"\n' % png_fname)
    f.write('set datafile separator ","\n')
    f.write('set terminal png size 1400,800\n')
    f.write('set title "Download Speed"\n')
    f.write('set ylabel "Speed (Mbits/s)"\n')
    f.write('set xlabel "Time (seconds)"\n')
    f.write('set xdata time\n')
    f.write('set timefmt "%H:%M:%S"\n')
    f.write('set key outside\n')
    f.write('set grid\n')
    f.write('plot \\\n')
    f.write('"%s" using 1:($2/1e6) with lines lw 1 lt 1 lc 1 title "speed"\n' % gpdata_fname)
    f.close()

    os.system("gnuplot %s" % gp_fname)


if len(sys.argv) < 2:
    print "Usage: %s [curl_data_filename]" % sys.argv[0]
    exit(1)
else:
    lines = readCurlData(sys.argv[1])
    lines = convertUnits(lines)
    writeGnuplotData(sys.argv[1], lines)
    plot(sys.argv[1])
