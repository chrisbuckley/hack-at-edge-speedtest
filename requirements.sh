#!/bin/bash

countdown()
	for i in 5 4 3 2 1; do 
		echo "Installing in $i"
		sleep 1
	done

echo "Installing GNU plot"

countdown

brew install gnuplot

echo "Installing libmagic"

countdown

brew install libmagic

