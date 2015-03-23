#!/bin/bash

DataTable="dataTableFull.csv"
if [ ! -f $DataTable ];
then
	echo "Enter name of data table file:"
	read DataTable
fi
read -p "Do you want to strip inflection? " yn
case $yn in
	[Yy]* ) perl getFreqs.pl -d $DataTable -syl 8 -stress 10 -freq 17 -i -root 12 | perl applyStress.pl | perl typesTokens.pl;;
	[Nn]* ) perl getFreqs.pl -d $DataTable -syl 8 -stress 10 -freq 17 | perl applyStress.pl | perl typesTokens.pl ;;
	* ) echo "Please answer yes or no.";;
esac
