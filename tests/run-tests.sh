#!/bin/bash
set -e
function cleanup {
  echo "Removing Tex Live generated files"
  rm *.aux *.log
}
trap cleanup EXIT

# Just check if PDF LaTex is available
pdflatex -version

# Create using XeLaTex
xelatex -version
xelatex example-valid
xelatex example-error
xelatex example-valid-de

function assert {
	if [ "$1" == "$2" ]
	then
		echo -e "\e[32mpassed\e[39m"
	else
		echo -e "\e[31mfailed\e[39m"
		exit 1
	fi
}

function print_results {
	echo "-----------------------------------------------"
	echo "$3"
	echo "-----------------------------------------------"
	echo "Expecting:"
	echo "$1"
	echo "----------"
	echo "Founded:"
	echo "$2"
	echo "-----------------------------------------------"
	echo -n "check: "
	assert $1 $2
	echo "-----------------------------------------------"
	echo ""
	echo ""
}

# Spell Checking using aspell with single dictionary
SPELL_EXPECTS="xxcvd"
SPELL_RESULTS=$(find . -name "*.tex" ! -path "*-de.tex" -exec cat "{}" \; | aspell -t -d en_US list --encoding=utf-8 -p ./dict.txt)
print_results "$SPELL_EXPECTS" "$SPELL_RESULTS" "Spell checking (single dictionary) founds:"

# Spell Checking using aspell with two dictionaries
SPELL_EXPECTS=""
SPELL_RESULTS=$(find . -name "*.tex" ! -path "*-de.tex" -exec cat "{}" \; | aspell -t -d en_US list --encoding=utf-8 --add-extra-dicts=./dict.txt --add-extra-dicts=./dict2.txt)
print_results "$SPELL_EXPECTS" "$SPELL_RESULTS" "Spell checking (two dictionaries) founds:"

# Spell Checking using aspell with DE dictonary
SPELL_EXPECTS=""
SPELL_RESULTS=$(find . -name "*-de.tex" -exec cat "{}" \; | aspell -t -d de_DE list --encoding=utf-8)
print_results "$SPELL_EXPECTS" "$SPELL_RESULTS" "Spell checking (DE dictionary) founds:"

