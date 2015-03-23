#!/usr/bin/python

import itertools
import sys
permutations = open("permutations.txt", "w")
sys.stdout = permutations

first = [1,2,3,4] #extrametricality
second = [2,3]  #quantity
third = [1,2]  #foot directionality
fourth = [1,2,3] #foot inventory
fifth = [1,2] #local parsing
sixth = [1,2] #degenerate foot prohibition
seventh = [1,2] #word layer end rule
eigth = [1,2] # topdown-bottomup

grammar = []
for a in first: # a is one permutation
    for b in second: # 
        for c in third: # 
            for d in fourth: # 
                for e in fifth: # 
                    for f in sixth: # 
                        for g in seventh:
				for h in eigth:
                            		grammar = [a,b,c,d,e,f,g,h]                            
                            		print ' '.join (map(str,grammar))

# Notes below for old version -- all combinations are logical in current version (see writeup for Hayes system)

# ----Old Version notes start here ---:

# second = 1 AND fourth = 1 invalid, as this corresponds to Quantity-Insensitive and Foot Inventory-Moraic Trochee, which is illogical combination (see Hayes_Parameters.doc)

# second = 2 AND fourth = 3 invalid, as this corresponds to Quantity-VCHeavy and Foot Inventory-Syllabic Trochee, which is illogical combination (see Hayes_Parameters.doc)

# second = 3 AND fourth = 3 invalid, as this corresponds to Quantity-VCLight and Foot Inventory-Syllabic Trochee, which is illogical combination (see Hayes_Parameters.doc)


