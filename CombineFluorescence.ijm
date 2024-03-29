// Licensed under a BSD license, please see LICENSE file.
// Copyright (c) 2019, Diamond Light Source Ltd. All rights reserved.
// Author: Thomas Fish
// Email: thomas.fish@diamond.ac.uk
//-------------------------------------------------------------------

// Create initial dialog box:
Dialog.create("Fluorescence Stacker");
Dialog.addMessage("Please choose which channels to import")

// Brightfield options:
Dialog.addCheckbox("Brightfield", false);
Dialog.addToSameRow();
Dialog.addCheckbox("Apply threshold filter", true);
Dialog.addToSameRow();
Dialog.addCheckbox("Apply brightfield transparency", true);

// Red options:
Dialog.addCheckbox("Red", false);

// FarRed options:
Dialog.addCheckbox("FarRed", false);

// Green options:
Dialog.addCheckbox("Green", false);

// Cyan options:
Dialog.addCheckbox("Cyan", false);

// Give an option to keep separate copies of the processed images:
Dialog.addMessage("");
Dialog.addCheckbox("Keep the separate processed images open when merging", false);
Dialog.addMessage("");
Dialog.addCheckbox("Z-project maximum intensity", true);

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

hasFarRed = Dialog.getCheckbox();

hasGreen = Dialog.getCheckbox();

hasCyan = Dialog.getCheckbox();

keepSeparate = Dialog.getCheckbox();

zProject = Dialog.getCheckbox();

imageNames=newArray();
widths=newArray();
heights=newArray();

// Checks at least two have been selected
if (hasBrightfield + hasRed + hasFarRed + hasGreen + hasCyan < 2) {
	exit("A minimum of two channels must be selected");
};

if (hasBrightfield) {
	Dialog.create("BF");
	Dialog.addMessage("Please select the BRIGHTFIELD file");
	Dialog.show();
	bfPath = File.openDialog("Select Brightfield File");
	open(bfPath);
	getDimensions(w, h, numChannels, s, f);
	widths=Array.concat(widths, w);
	heights=Array.concat(heights, h);
	channelSelect(numChannels);
	run("8-bit");
	if (thresholdBrighfield) {
		setAutoThreshold("Huang dark");
		run("Convert to Mask");
		run("Invert");
		if (transparentBrighfield) {
			setMinAndMax(0, 510);
		};
	};
	imageName = updateName("BF");
	imageNames = Array.concat(imageNames, imageName);
};
if (hasRed) {
	Dialog.create("Red");
	Dialog.addMessage("Please select the RED channel file");
	Dialog.show();
	redPath = File.openDialog("Select Red Channel File");
	open(redPath);
	getDimensions(w, h, numChannels, s, f);
	widths=Array.concat(widths, w);
	heights=Array.concat(heights, h);
	channelSelect(numChannels);
	imageName = processImage("Red");
	imageNames = Array.concat(imageNames, imageName);
};
if (hasFarRed) {
	Dialog.create("FarRed");
	Dialog.addMessage("Please select the FAR-RED channel file");
	Dialog.show();
	farRedPath = File.openDialog("Select FarRed Channel File");
	open(farRedPath);
	getDimensions(w, h, numChannels, s, f);
	widths=Array.concat(widths, w);
	heights=Array.concat(heights, h);
	channelSelect(numChannels);
	imageName = processImage("FarRed");
	imageNames = Array.concat(imageNames, imageName);
};
if (hasGreen) {
	Dialog.create("Green");
	Dialog.addMessage("Please select the GREEN channel file");
	Dialog.show();
	greenPath = File.openDialog("Select Green Channel File");
	open(greenPath);
	getDimensions(w, h, numChannels, s, f);
	widths=Array.concat(widths, w);
	heights=Array.concat(heights, h);
	channelSelect(numChannels);
	imageName = processImage("Green");
	imageNames = Array.concat(imageNames, imageName);
};
if (hasCyan) {
	Dialog.create("Cyan");
	Dialog.addMessage("Please select the CYAN channel file");
	Dialog.show();
	cyanPath = File.openDialog("Select Cyan Channel File");
	open(cyanPath);
	getDimensions(w, h, numChannels, s, f);
	widths=Array.concat(widths, w);
	heights=Array.concat(heights, h);
	channelSelect(numChannels);
	imageName = processImage("Cyan");
	imageNames = Array.concat(imageNames, imageName);
};

function updateName(colour) {
	name=colour + timeString;
	rename(name);
	return name;
}

function processImage(colour) {
	setOption("Changes", false);
	rename("tmp");
	if (zProject) {
		run("Z Project...", "projection=[Max Intensity]");
	};
	close("tmp");
	run("Enhance Contrast", "saturation=0.35");
	setOption("Changes", false);
	run("8-bit");
	run("Apply LUT");
	setOption("Changes", true);
	newName = updateName(colour);
	return newName;
}

function channelSelect(numChannels) {
	if (numChannels > 1) {
		temp_name="tmp";
		rename(temp_name);
		a = newArray();
		for (i=1; i<=numChannels; i++) {
			a=Array.concat(a, "C" + i);
		};
		Dialog.create("Select channel");
		Dialog.addRadioButtonGroup("Channel", a, numChannels, 0, a[0]);
		Dialog.show();
		selected_c=Dialog.getRadioButton();
		a=Array.deleteValue(a, selected_c);
		run("Split Channels");
		for (i=0; i<a.length; i++) {
			close(a[i] + "-" + temp_name);
		};
		selectWindow(selected_c + "-" + temp_name);
	}
}

channelMergeString = "";

if (hasBrightfield) {
	channelMergeString = channelMergeString + "c4=BF" + timeString + " ";
};

if (hasRed) {
	channelMergeString = channelMergeString + "c1=Red" + timeString + " ";
};

if (hasFarRed) {
	channelMergeString = channelMergeString + "c6=FarRed" + timeString + " ";
};

if (hasGreen) {
	channelMergeString = channelMergeString + "c2=Green" + timeString + " ";
};

if (hasCyan) {
	channelMergeString = channelMergeString + "c5=Cyan" + timeString + " ";
};
print("widths");
Array.print(widths);
widthIdxs=Array.rankPositions(widths);
Array.print(widthIdxs);
widthIdxs = Array.reverse(widthIdxs);
Array.print(widthIdxs);
widestImage = widthIdxs[0];
for (i=0; i<imageNames.length; i++) {
	selectWindow(imageNames[i]);
	run("Size...", "width=" + widths[widestImage] + " height=" + heights[widestImage] + " average interpolation=Bilinear");
};

if (keepSeparate) {
	run("Merge Channels...", channelMergeString + "create keep");
} else {
	run("Merge Channels...", channelMergeString + "create");
};
