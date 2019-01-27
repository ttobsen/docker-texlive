#!/bin/bash

RUN_TESTS_EXIT_CODE=0

function cleanup {
  echo "Removing Tex Live generated files"
  find . -name "*.aux" -type f -delete
  find . -name "*.log" -type f -delete
}

function assert {
	if [ "$1" == "$2" ]
	then
		echo -e "\e[32mpassed\e[39m"
	else
		echo -e "\e[31mfailed\e[39m"
		RUN_TESTS_EXIT_CODE=1
	fi
}

function print_empty {
    if [ "$1" == "" ]
    then
        echo -e "\e[36m(empty)\e[39m"
    else
        echo -n "$1"
    fi
}

function print_results {
	echo "-----------------------------------------------"
	echo "$3"
	echo "-----------------------------------------------"
	echo "Expecting:"
	echo $(print_empty "$1")
	echo "----------"
	echo "Founded:"
	echo $(print_empty "$2")
	echo "-----------------------------------------------"
	echo -n "check: "
	assert "$1" "$2"
	echo "-----------------------------------------------"
	echo ""
	echo ""
}

#Prepare artefacts folder where PDFs will be stored
ARTEFACTS=artefacts
mkdir $ARTEFACTS

XELATEX_COMPILE='xelatex -interaction=batchmode -halt-on-error'

##################################################################################
#                            Test Installation                                   #
##################################################################################
TEST_FOLDER=installation

cd $TEST_FOLDER

# Just check if PDF LaTex is available
pdflatex -version

# Run XeLatex test by creating an example
xelatex -version

rsvg-convert -f pdf -o example.pdf example.svg
$XELATEX_COMPILE test

COMPILE_EXIT_CODE=$?

INST_EXPECTS="Exit with Code 0"

if [ "$COMPILE_EXIT_CODE" == "0" ]
then
    INST_RESULTS="$INST_EXPECTS"
else
    INST_RESULTS="Exit with Code $COMPILE_EXIT_CODE: $(cat test.log | grep "LaTeX Error")"
fi

print_results "$INST_EXPECTS" "$INST_RESULTS" "Check installation by creating an example:"

ARTEFACTS_INSTALLATION=../$ARTEFACTS/$TEST_FOLDER
mkdir $ARTEFACTS_INSTALLATION
cp *.pdf $ARTEFACTS_INSTALLATION

cd ..

##################################################################################
#                          Test Spelling Checker                                 #
##################################################################################
TEST_FOLDER=spelling

cd $TEST_FOLDER

$XELATEX_COMPILE example-valid
$XELATEX_COMPILE example-error
$XELATEX_COMPILE example-valid-de

# Spell Checking using aspell with single dictionary
SPELL_EXPECTS="xxcvd"
SPELL_RESULTS=$( { find . -name "*.tex" ! -path "*-de.tex" -exec cat "{}" \; | aspell -t -d en_US list --encoding=utf-8 -p ./dict.txt; } 2>&1 )
print_results "$SPELL_EXPECTS" "$SPELL_RESULTS" "Spell checking (single dictionary) founds:"

# Spell Checking using aspell with two dictionaries
SPELL_EXPECTS=""
SPELL_RESULTS=$( { find . -name "*.tex" ! -path "*-de.tex" -exec cat "{}" \; | aspell -t -d en_US list --encoding=utf-8 --add-extra-dicts=./dict.txt --add-extra-dicts=./dict2.txt; } 2>&1 )
print_results "$SPELL_EXPECTS" "$SPELL_RESULTS" "Spell checking (two dictionaries) founds:"

# Spell Checking using aspell with DE dictonary
SPELL_EXPECTS=""
SPELL_RESULTS=$( { find . -name "*-de.tex" -exec cat "{}" \; | aspell -t -d de_DE list --encoding=utf-8; } 2>&1 )
print_results "$SPELL_EXPECTS" "$SPELL_RESULTS" "Spell checking (DE dictionary) founds:"

ARTEFACTS_INSTALLATION=../$ARTEFACTS/$TEST_FOLDER
mkdir $ARTEFACTS_INSTALLATION
cp *.pdf $ARTEFACTS_INSTALLATION

cd ..

cleanup
exit $RUN_TESTS_EXIT_CODE
