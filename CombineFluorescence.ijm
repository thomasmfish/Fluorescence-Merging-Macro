// Licensed under a BSD license, please see LICENSE file.
// Copyright (c) 2019, Diamond Light Source Ltd. All rights reserved.
// Author: Thomas Fish
// Email: thomas.fish@diamond.ac.uk
//-------------------------------------------------------------------

// Create initial dialog box:
Dialog.create("Fluorescence Stacker");
Dialog.addMessage("Please choose which channels to import")

// Brightfield options:
Dialog.addCheckbox("Brightfield", true);
Dialog.addToSameRow();
Dialog.addCheckbox("Apply threshold filter", true);
Dialog.addToSameRow();
Dialog.addCheckbox("Apply brightfield transparency", true);

// Red options:
Dialog.addCheckbox("Red", true);
Dialog.addToSameRow();
Dialog.addNumber("Min/Max:", 4);
Dialog.addToSameRow();
Dialog.addNumber("_", 50);

// Green options:
Dialog.addCheckbox("Green", true);
Dialog.addToSameRow();
Dialog.addNumber("Min/Max:", 4);
Dialog.addToSameRow();
Dialog.addNumber("_", 45);

// Cyan options:
Dialog.addCheckbox("Cyan", false);
Dialog.addToSameRow();
Dialog.addNumber("Min/Max:", 4);
Dialog.addToSameRow();
Dialog.addNumber("_", 45);

// Give an option to keep separate copies of the processed images:
Dialog.addMessage("");
Dialog.addCheckbox("Keep the separate processed images open when merging", false);

Dialog.show();

// Create a string of time-based numbers to avoid filename
// clashes when running multiple times:
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec)
timeString = "" + hour + "" + minute + "" + second

// Get dialog output:
hasBrightfield = Dialog.getCheckbox();
thresholdBrighfield = Dialog.getCheckbox();
transparentBrighfield = Dialog.getCheckbox();

hasRed = Dialog.getCheckbox();
redMin = Dialog.getNumber();
redMax = Dialog.getNumber();

hasGreen = Dialog.getCheckbox();
greenMin = Dialog.getNumber();
greenMax = Dialog.getNumber();

hasCyan = Dialog.getCheckbox();
cyanMin = Dialog.getNumber();
cyanMax = Dialog.getNumber();

keepSeparate = Dialog.getCheckbox();

// Checks at least two have been selected
if (hasBrightfield + hasRed + hasGreen + hasCyan < 2) {
	exit("A minimum of two channels must be selected");
};

if (hasBrightfield) {
	Dialog.create("BF");
	Dialog.addMessage("Please select the BRIGHTFIELD file");
	Dialog.show();
	bfPath = File.openDialog("Select Brightfield File");
	open(bfPath);
	run("8-bit");
	if (thresholdBrighfield) {
		setAutoThreshold("Huang dark");
		run("Convert to Mask");
		run("Invert");
		if (transparentBrighfield) {
			setMinAndMax(0, 510);
		};
	};
	rename("BF" + timeString);
};
if (hasRed) {
	Dialog.create("Red");
	Dialog.addMessage("Please select the RED channel file");
	Dialog.show();
	redPath = File.openDialog("Select Red Channel File");
	open(redPath);
	run("8-bit");
	setMinAndMax(redMin, redMax);
	run("Apply LUT");
	rename("Red" + timeString);
};
if (hasGreen) {
	Dialog.create("Green");
	Dialog.addMessage("Please select the GREEN channel file");
	Dialog.show();
	greenPath = File.openDialog("Select Green Channel File");
	open(greenPath);
	run("8-bit");
	setMinAndMax(greenMin, greenMax);
	run("Apply LUT");
	rename("Green" + timeString);
};
if (hasCyan) {
	Dialog.create("Cyan");
	Dialog.addMessage("Please select the CYAN channel file");
	Dialog.show();
	cyanPath = File.openDialog("Select Cyan Channel File");
	open(cyanPath);
	run("8-bit");
	setMinAndMax(cyanMin, cyanMax);
	run("Apply LUT");
	rename("Cyan" + timeString);
};

channelMergeString = "";

if (hasBrightfield) {
	channelMergeString = channelMergeString + "c4=BF" + timeString + " ";
};

if (hasRed) {
	channelMergeString = channelMergeString + "c1=Red" + timeString + " ";
};

if (hasGreen) {
	channelMergeString = channelMergeString + "c2=Green" + timeString + " ";
};

if (hasCyan) {
	channelMergeString = channelMergeString + "c5=Cyan" + timeString + " ";
};

if (keepSeparate) {
	run("Merge Channels...", channelMergeString + "create keep");
} else {
	run("Merge Channels...", channelMergeString + "create");
};
