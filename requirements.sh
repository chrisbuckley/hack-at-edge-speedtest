#!/bin/bash

countdown()
	for i in 5 4 3 2 1; do 
		echo "Installing in $i"
		sleep 1
	done

echo "Installing python 2"

countdown

brew install python2

echo "Installing GNU plot"

countdown

brew install gnuplot

echo "Installing libmagic"

countdown

brew install libmagic

