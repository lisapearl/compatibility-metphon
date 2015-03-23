#!/usr/bin/python
from __future__ import division
import collections
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("file", help="The name of the Brent data file used for either the OT\
		or the parametric systems. Usually called brent.data")
args = parser.parse_args()

# allSyllables is a dictionary (hash) with word types like 'xC',
# 'Ll', and 'Cc' as keys, and lists of "wordStat" tuples as values
# It is meant to keep track of each individual word type and their counts
allSyllables = {}
# named tuple constructor, just for readability and simplicity
wordStat = collections.namedtuple('wordStat', ['wordAndStress', 'tokenCount', 'typeCount'])
allWordStats = []
brentFileName = args.file
brentFile = open(brentFileName)
allTokens = 0
allTypes = 0
numOfSyllables = 0
# process each line of brent.data, adding to the counters
# of tokens and types, and keeping separate information
# for each word type
for line in brentFile:
	line = line.strip().split()
	wordStress = line[0]
	tokens = int(line[1])
	allTokens += tokens
	types = int(line[2])
	allTypes += types
	numOfSyllables += 1 # counting word types (xC, Ll, etc)

	wordStats = wordStat(wordAndStress=wordStress, tokenCount=tokens, typeCount=types)
	# this checks if the hash already contains something for the
	# word type being processed
	if (wordStress.lower() not in allSyllables):
		allSyllables[wordStress.lower()] = []
	allSyllables[wordStress.lower()].append(wordStats)
	allWordStats.append(wordStats)

print "Total tokens:", allTokens
print "Total types:", allTypes

upperBoundTokens = 0
upperBoundTypes = 0
numberOfMultiStressTypes = 0
for syllType in allSyllables:
	# checks if allSyllables[syllType] has more than one stress assignment
	if (len(allSyllables[syllType]) > 1):
		numberOfMultiStressTypes += 1
		currMaxTokens = 0
		currMaxTypes = 0
		for stressContour in allSyllables[syllType]:
			if (stressContour.tokenCount > currMaxTokens):
				currMaxTokens = stressContour.tokenCount
			if (stressContour.typeCount > currMaxTypes):
				currMaxTypes = stressContour.typeCount
		upperBoundTokens += currMaxTokens
		upperBoundTypes += currMaxTypes
	else:
		upperBoundTokens += allSyllables[syllType][0].tokenCount
		upperBoundTypes += allSyllables[syllType][0].typeCount

print "Token upper bound:", upperBoundTokens
print "Type upper bound:", upperBoundTypes
print "Number of syllables with multiple stress contours:", numberOfMultiStressTypes
print "Total number of syllables:", numOfSyllables
print "Total number of unique syllables:", len(allSyllables.keys())

print "Upper bound compatibility by tokens:", upperBoundTokens/allTokens
print "Upper bound compatibility by types:", upperBoundTypes/allTypes

print "Word Form\tToken Count\tType Count\tToken Percentage\tType Percentage"
for ws in allWordStats:
	print '\t'.join(map(str,[ws.wordAndStress, ws.tokenCount, ws.typeCount, round(100*ws.tokenCount/allTokens,2), round(100*ws.typeCount/allTypes, 2)]))
