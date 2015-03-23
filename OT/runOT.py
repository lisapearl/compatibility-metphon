#!/usr/bin/python
from __future__ import division
from time import sleep
import argparse
import subprocess
import os
import re
import collections
import multiprocessing, Queue

parser = argparse.ArgumentParser()
parser.add_argument("grammar", help="Name of the file containing all grammars, usually\
		something like 'grammars.all' or 'grammars.english')")
parser.add_argument("data", help="Name of brent data file containing list of word forms\
		and their token and type frequency, usually something like 'brent.data'")
parser.add_argument("--scores", help="Store wordform scores in a file scores.txt, containing\
		information about how many grammars got a certain wordform correct. this is \
		useful when running it with English grammars.", action="store_true")
args = parser.parse_args()

if (args.scores):
	scores = open('scores.csv', 'w')

FTBIN = 0
WSPVC = 1
WSPVV = 2
PARSE = 3
NONFINAL = 4
ALIGNRIGHT = 5
ALIGNLEFT = 6
TROCHAIC = 7
SONNUC = 8

numToStrMapping = ["FtBin", "WSPVC", "WSPVV", "Parse", "NonFinal", "AlignRight", "AlignLeft", "Trochaic", "SonNuc"]

def minusOne(num):
	return num-1

# gets the stress pattern of some word ex. (Cc)x(L) -> 1001
def getStress(cand):
	cand = re.sub(r'[\(\)]', '', cand)
	cand = re.sub(r'[A-Z]','1', cand)
	cand = re.sub(r'[a-z]','0', cand)
	return cand

# checks to see if two stresses are equivalent
def stressMatch(orig, cand):
	return (getStress(orig) == getStress(cand))

# EVAL function
def genOutputUnderGrammar(wordForm, grammar):
	firstConstr = grammar[0]
	currSet = absMins[numToStrMapping[firstConstr]][wordForm]
	i = 1
	while (i < len(grammar) and len(currSet) > 1):
		currCands = getFirstElements(currSet)
		currSet = grabMatches(currCands, candViolationPairs[grammar[i]][wordForm])
		currSet.sort(key=lambda tup: tup[1])
		currSet = getMins(currSet)
		i += 1
	return currSet[0]
		
def grabMatches(cands, listOfPairs):
	matches = []
	for cand in cands:
		if cand in listOfPairs:
			matches.append(listOfPairs[cand])
	return matches

def getFirstElements(someList):
	return map(lambda tup: tup[0], someList)

def getMins(someList):
	length = len(someList)
	mins = []
	firstEl = someList[0]
	mins.append(firstEl)
	currMin = firstEl[1]
	i = 1
	while (i < length and someList[i][1] <= currMin):
		mins.append(someList[i])
		i += 1
	return mins

def checkFtBinSyl(cand):

	cand = re.sub(r'\([A-Za-z]{3,}\)', '1', cand)

	cand = re.sub(r'\([A-Za-z]{1}\)', '1', cand)
	cand = re.sub(r'[^1]+', '0', cand)

	return cand

def checkFtBinMor(cand):
	cand = re.sub(r'\([XR]\)', '1', cand)
	cand = re.sub(r'\([A-Za-z]+\)', '0', cand)
	cand = re.sub(r'[^10]+', '0', cand)
	return cand

# merged version of above two functions
def checkFtBin(cand):
	def bin(s):
		return str(s) if s<=1 else bin(s>>1) + str(s&1)
	ftbinsyl = checkFtBinSyl(cand)
	ftbinmor = checkFtBinMor(cand)
	ftbin = bin(int(ftbinsyl, 2) & int(ftbinmor, 2))
	ftbin = re.sub(r'[^1]', '', ftbin)
	return len(ftbin)

# favors stressed closed syllables
def checkWSPVC(cand):
	cand = re.sub(r'[csdmt]', '1', cand)
	cand = re.sub(r'[^1]', '', cand)
	cand = re.sub(r'^$', '0', cand)
	if (cand == '0'):
		return 0
	else:
		return len(cand)

# favors stressed long vowel syllables
def checkWSPVV(cand):
	cand = re.sub(r'[ls]', '1', cand)
	cand = re.sub(r'[^1]', '', cand)
	cand = re.sub(r'^$', '0', cand)
	if (cand == '0'):
		return 0
	else:
		return len(cand)

# counts number of unfooted syllables
def checkParse(cand):
	cand = re.sub(r'\([A-Za-z]*\)', '', cand)
	cand = re.sub(r'.','1', cand)
	cand = re.sub(r'[^1]', '', cand)
	cand = re.sub(r'^$', '0', cand)
	if (cand == '0'):
		return 0
	else:
		return len(cand)

# prefers that the last syllable isn't footed
def checkNonFinal(cand):
	cand = re.sub(r'\)$', '1', cand)
	cand = re.sub(r'[^1]', '', cand)
	cand = re.sub(r'^$', '0', cand)
	if (cand == '0'):
		return 0
	else:
		return len(cand)

def checkAlignRight(cand): # this is now like AlignHead in Pater 2000
	cand = re.sub(r'\(', '', cand)
	cand = re.sub(r'\)', '', cand)
	cand = re.sub(r'[a-z]', '1', cand)
	cand = re.sub(r'.*[A-Z]', '', cand)
	cand = re.sub(r'^$', '0', cand)
	if (cand == '0'):
		return 0
	else:
		return len(cand)

def checkAlignLeft(cand): # this now works like AlignLeft in Pater 2000
	cand = re.sub(r'^[^\(]+', '1', cand)
	cand = re.sub(r'\(.*', '', cand)
	cand = re.sub(r'^$', '0', cand)
	if (cand == '0'):
		return 0
	else:
		return len(cand)

# favors feet headed on the left
def checkTrochaic(cand):
	cand = re.sub(r'\([xlcsrdmt]', '1', cand)
	cand = re.sub(r'[^1]', '', cand)
	cand = re.sub(r'^$', '0', cand)
	if (cand == '0'):
		return 0
	else:
		return len(cand)

# returns number of times a candidate has a sonorant nucleus
def checkSonNuc(cand):
	cand = re.sub(r'[RrDd]', '1', cand)
	cand = re.sub(r'[^1]', '', cand)
	cand = re.sub(r'^$', '0', cand)
	if (cand == '0'):
		return 0
	else:
		return len(cand)

# the following function is no longer used since deciding that the 'Rooting'
# constraint should be a principle
#def checkRooting(cand):
	#cand = re.sub(r'^[A-Za-z]+$', '1', cand)
	#if (cand == '1'):
		#return 1
	#else:
		#return 0

grammarFileName = args.grammar
brentFileName = args.data
brentFile = open(brentFileName)

# list of word forms [Cc, xC, LL, etc...]
wordForms = []
# list of 2-D hashes
candViolationPairs = [collections.defaultdict(lambda:{}) for i in range(9)]
numTokens = {}
numTypes = {}

# total types and tokens counters
totalTokens = 0
totalTypes = 0

for line in brentFile:
	line = line.strip().split()
	wordForm = line[0]
	tokens = int(line[1])
	types = int(line[2])
	wordForms.append(wordForm)
	numTokens[wordForm] = tokens
	totalTokens += tokens
	numTypes[wordForm] = types
	totalTypes += types

wordFormCands = {}
candViolations = {
		'FtBin' : collections.defaultdict(lambda:[]),
		'WSPVC' : collections.defaultdict(lambda:[]),
		'WSPVV' : collections.defaultdict(lambda:[]),
		'Parse' : collections.defaultdict(lambda:[]),
		'NonFinal' : collections.defaultdict(lambda:[]),
		'AlignRight' : collections.defaultdict(lambda:[]),
		'AlignLeft' : collections.defaultdict(lambda:[]),
		'SonNuc' : collections.defaultdict(lambda:[]),
		'Trochaic' : collections.defaultdict(lambda:[])
		#'Rooting' : collections.defaultdict(lambda:[])
		}

for wordForm in wordForms:
	wordLower = wordForm.lower()
	if wordLower not in wordFormCands:
		forXFSTName = "input"
		forXFST = open(forXFSTName, 'w')
		forXFST.write(wordLower)
		forXFST.close()
		candidates = subprocess.check_output("./gen_candidates")
		candidates = candidates.strip().split("\n")
		wordFormCands[wordLower] = []
		for cand in candidates:
			wordFormCands[wordLower].append(cand)
			
			FtBinViolated = checkFtBin(cand)
			FtBinPair = (cand, FtBinViolated)
			WSPVCViolated = checkWSPVC(cand)
			WSPVCPair = (cand, WSPVCViolated)
			WSPVVViolated = checkWSPVV(cand)
			WSPVVPair = (cand, WSPVVViolated)
			ParseViolated = checkParse(cand)
			ParsePair = (cand, ParseViolated)
			NonFinalViolated = checkNonFinal(cand)
			NonFinalPair = (cand, NonFinalViolated)
			AlignRightViolated = checkAlignRight(cand)
			AlignRightPair = (cand, AlignRightViolated)
			AlignLeftViolated = checkAlignLeft(cand)
			AlignLeftPair = (cand, AlignLeftViolated)
			TrochaicViolated = checkTrochaic(cand)
			TrochaicPair = (cand, TrochaicViolated)
			SonNucViolated = checkSonNuc(cand)
			SonNucPair = (cand, SonNucViolated)
			#RootingViolated = checkRooting(cand)
			#RootingPair = (cand, RootingViolated)
			candViolations["FtBin"][wordLower].append(FtBinPair)
			candViolations["WSPVC"][wordLower].append(WSPVCPair)
			candViolations["WSPVV"][wordLower].append(WSPVVPair)
			candViolations["Parse"][wordLower].append(ParsePair)
			candViolations["NonFinal"][wordLower].append(NonFinalPair)
			candViolations["AlignRight"][wordLower].append(AlignRightPair)
			candViolations["AlignLeft"][wordLower].append(AlignLeftPair)
			candViolations["Trochaic"][wordLower].append(TrochaicPair)
			candViolations["SonNuc"][wordLower].append(SonNucPair)
			#candViolations["Rooting"][wordLower].append(RootingPair)
			candViolationPairs[FTBIN][wordLower][cand] = FtBinPair
			candViolationPairs[WSPVC][wordLower][cand] = WSPVCPair 
			candViolationPairs[WSPVV][wordLower][cand] = WSPVVPair
			candViolationPairs[PARSE][wordLower][cand] = ParsePair
			candViolationPairs[NONFINAL][wordLower][cand] = NonFinalPair
			candViolationPairs[ALIGNRIGHT][wordLower][cand] = AlignRightPair 
			candViolationPairs[ALIGNLEFT][wordLower][cand] = AlignLeftPair
			candViolationPairs[TROCHAIC][wordLower][cand] = TrochaicPair
			candViolationPairs[SONNUC][wordLower][cand] = SonNucPair
			#candViolationPairs[ROOTING][wordLower][cand] = RootingPair

# sort candidates by violations
for constr in candViolations:
	for wf in candViolations[constr]:
		candViolations[constr][wf].sort(key=lambda tup: tup[1])

absMins = {}
for constr in candViolations:
	absMins[constr] = {}
	for wf in candViolations[constr]:
		absMins[constr][wf] = getMins(candViolations[constr][wf])

constraintMapping = [candViolations["FtBin"], candViolations["WSPVC"], candViolations["WSPVV"], candViolations["Parse"], candViolations["NonFinal"], candViolations["AlignRight"], candViolations["AlignLeft"], candViolations["Trochaic"], candViolations["SonNuc"]]


grammarFile = open(grammarFileName)

if args.scores:
	header = ','.join(wordForms)
	scores.write(header)
	scores.write('\n')

for grammar in grammarFile:
	grammar = map(int, grammar.strip().split())
	FtBinLoc = grammar.index(FTBIN)
	TrochLoc = grammar.index(TROCHAIC)
	NonFinalLoc = grammar.index(NONFINAL)
	AlignRightLoc = grammar.index(ALIGNRIGHT)
	AlignLeftLoc = grammar.index(ALIGNLEFT)
	ParseLoc = grammar.index(PARSE)
	WSPVVLoc = grammar.index(WSPVV)
	WSPVCLoc = grammar.index(WSPVC)
	SonNucLoc = grammar.index(SONNUC)
	#RootingLoc = grammar.index(ROOTING)
	correctTokens = 0
	correctTypes = 0
	first = True
	for wf in wordForms:
		if not first:
			if args.scores:
				scores.write(',')
		else:
			first = False
		bestCand = genOutputUnderGrammar(wf.lower(), grammar)[0]
		match = stressMatch(wf, bestCand)
		if (match):
			if args.scores:
				scores.write('1')
			correctTokens += numTokens[wf]
			correctTypes += numTypes[wf]
		else:
			if args.scores:
				scores.write('0')
	tokenPercentage = correctTokens/totalTokens
	typePercentage = correctTypes/totalTypes
	grammar = ' '.join(map(str, grammar))
	isEnglish = 0
	if args.scores:
		scores.write('\n')
	if (TrochLoc < AlignRightLoc and \
			NonFinalLoc < AlignRightLoc and AlignRightLoc < ParseLoc and \
			WSPVCLoc < SonNucLoc and \
			SonNucLoc < AlignLeftLoc and \
			TrochLoc < WSPVVLoc and WSPVVLoc < NonFinalLoc and \
			NonFinalLoc < WSPVCLoc and WSPVCLoc < FtBinLoc and \
			FtBinLoc < ParseLoc):
		isEnglish = 1
	grammar += ' ' + str(tokenPercentage) + " " + str(typePercentage) + " " + str(isEnglish)
	print grammar


