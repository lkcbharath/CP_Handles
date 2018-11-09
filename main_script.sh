#!bin/bash

# A simple script to display Competitive Programming statistics of a user by using Web Scraping and JSON parsing tools.
# Error-handling is performed for invalid profiles and user input.
# Dependencies: cURL (web scraping), Python 3 (JSON parsing), bash (script execution), awk, sed & tr (text pattern-matching and editing)
# Authors: Adikar Bharath NVS, Ayush Gupta, Prathmesh Dahikar, Sai Siddarth V
# Last Updated: 9/11/2018

#======================================================================================================================

# Fetch the handle(s) from user input. 
# If any of the handles is invalid, terminate the program. Else, call the functions defined below main().

main() {

	echo "Enter your Competitive Programming handle:" 
	echo "The handle is assumed to be valid on either StopStalk or all: StopStalk, CodeForces, SPOJ, and CodeChef:"
	read cphandle

	echo -e "\nIf you have different handles for CodeForces, SPOJ and CodeChef, enter 1, followed by each handle. Else, hit Enter."
	read different_handles

	if (( different_handles == 1 ))
	then
		echo "Enter your CodeForces handle:"
		read cphandle_cf
		echo "Enter your SPOJ handle:"
		read cphandle_spoj
		echo "Enter your CodeChef handle:"
		read cphandle_cc
	else
		cphandle_cf=$cphandle
		cphandle_spoj=$cphandle
		cphandle_cc=$cphandle
	fi

	if [ -z $cphandle ] || [ -z $cphandle_cf ] || [ -z $cphandle_spoj ] || [ -z $cphandle_cc ] 
	then
		echo "Enter a valid handle."
		exit 0
	else
		echo -e "\nNow fetching user data:"
		stopstalk
		codeforces
		spoj
		codechef
	fi
}

#======================================================================================================================

# Fetch the StopStalk profile associated with the handle.
# If the profile is invalid, then there will be no accuracies associated with it.

stopstalk() {

	stopstalk_url="https://www.stopstalk.com/user/profile/$cphandle"
	curl -s $stopstalk_url | awk '/alt=/{getline; print}' | tr -d "[:blank:]" > accuracy.txt

	if [ -s accuracy.txt ]
	then
		echo -e "\nSuccessful submission accuracies on different CP websites:\n"

		echo "CodeChef submission accuracy:" `sed '1!d' accuracy.txt`
		echo "CodeForces submission accuracy:" `sed '2!d' accuracy.txt`
		echo "SPOJ submission accuracy:" `sed '3!d' accuracy.txt`
		echo "HackerEarth submission accuracy:" `sed '4!d' accuracy.txt`
		echo "HackerRank submission accuracy:" `sed '5!d' accuracy.txt`
		echo "uVa submission accuracy:" `sed '6!d' accuracy.txt`
		echo "Timus submission accuracy:" `sed '7!d' accuracy.txt`
	else
		echo -e "\nNo StopStalk profile associated with this handle."
	fi
}

#======================================================================================================================

# Fetch the CodeForces profile associated with the handle.
# codeforces.com provides a public API for requesting data, which returns a JSON Object. 
# To parse the JSON objects, a Python3 script is used. Error-handling is taken care by the script.

codeforces() {

	echo -e "\nCodeForces details:"

	codeforces_user_url="http://codeforces.com/api/user.info?handles=$cphandle_cf"
	codeforces_ac_url="http://codeforces.com/api/user.status?handle=$cphandle_cf"

	curl -s $codeforces_ac_url > codeforces_ac.json
	curl -s $codeforces_user_url > codeforces_user.json

	python3 codeforces.py
}

#======================================================================================================================

# Fetch the SPOJ profile associated with the handle.
# If the profile is invalid, then there will be no World Rank associated with it.

spoj() {

	echo -e "\nSPOJ details:"

	spoj_url="https://www.spoj.com/users/$cphandle_spoj/"
	curl -s $spoj_url > spoj.html

	world_rank=`awk '/World Rank/' spoj.html | tr -d "[:blank:]"`
	problems_solved=`awk '/Problems solved/{getline; print}' spoj.html | tr -d "[:blank:]"`

	if [ -z ${world_rank:40:-13} ]
	then
		echo "No SPOJ profile associated with this handle."
	else
		echo "World rank: ${world_rank:40:-13}"
		echo "Problems solved: ${problems_solved:4:-5}"
	fi
}

#======================================================================================================================

# Fetch the CodeChef profile associated with the handle.
# If the profile is invalid, then there will be no CodeChef Rating associated with it.

codechef() {

	echo -e "\nCodeChef details:"

	codechef_url="https://www.codechef.com/users/$cphandle_cc"

	curl -s $codechef_url > codechef.html

	rating=`awk '/rating-number/' codechef.html | tr -d "[:blank:]"`
	fully_solved=`awk '/Fully Solved/' codechef.html | tr -d "[:blank:]"`
	partially_solved=`awk '/Partially Solved/' codechef.html | tr -d "[:blank:]"`

	if [ -z ${rating:26:4} ]
	then
		echo "No CodeChef profile associated with this handle."
	else
		echo "Rating: ${rating:26:4}"
		echo "Problems fully solved: ${fully_solved:16:-6}"
		echo "Problems partially solved: ${partially_solved:20:-6}"
	fi
}

#======================================================================================================================

# Call the main function after declaring all other functions.

main

#======================================================================================================================

# Cleaning up of temporary resources used for the program.

rm -f accuracy.txt
rm -f codeforces_ac.json
rm -f codeforces_user.json
rm -f spoj.html
rm -f codechef.html

#======================================================================================================================