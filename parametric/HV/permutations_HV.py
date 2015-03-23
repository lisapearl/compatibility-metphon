#!/usr/bin/python

#Generates all valid permutations of parameter values for HV system

import itertools
import sys
permutations = open("permutations_HV.txt", "w")
sys.stdout = permutations

first = [1,2,3] #quantity
second = [1,2,3]  #extrametricality
third = [1,2]  #foot directionality
fourth = [1,2,3,4,5] #boundedness
fifth = [1,2] #foot headedness

grammar = []
for a in first: # a is one permutation
    for b in second: # 
        for c in third: # 
            for d in fourth: # 
                for e in fifth: # 
                    if (a == 1 and d == 4) or (a == 1 and d == 5):
                            continue
                    grammar = [a,b,c,d,e]
                    print ' '.join (map(str,grammar))


# first = 1 AND fourth = 4 invalid, as this corresponds to Quantity-Insensitive and Boundedness-TwoMora, which is illogical combination

# first = 1 AND fourth = 5 invalid, as this corresponds to Quantity-Insensitive and Boundedness-ThreeMora, which is illogical combination


