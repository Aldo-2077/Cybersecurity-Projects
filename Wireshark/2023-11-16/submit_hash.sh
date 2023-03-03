#!/bin/bash
#**************************************************************************
# This script will read files from VT_Uploads directory, hash each one,
# and submit to virustotal.com
# Created by Aldo 02/27/2023, Rev.01
# Modified code to show only malicious results. 03/1/2023, Rev.02
# Added counter to count total and malicious files. 03/1/2023, Rev.02
# Saved VT API-key in a configuration file. 03/1/2023, Rev.02
#**************************************************************************


# Call virustotal API key
source /home/user1/Desktop/Wireshark\ Lessons/Scripts/.vt_config.cfg

# Assign directory name
dirname="/home/user1/VT_Uploads"

# Check if directory exists
if [ -d "$dirname" ]; then

   total_count=0
   total_malicious=0
   echo ""
   # Loop through each file in the directory
     for file in "$dirname"/*; do

        # Check if the file is a regular file
	  if [ -f "$file" ]; then

	     # Generate file hash		
	       hash_id=$( sha256sum "$file" | cut -d ' ' -f 1 )
	       
	     # Send hash to virustotal.com
	       response=$(curl -sS --request GET \
	       --url "https://www.virustotal.com/api/v3/files/${hash_id}" \
               --header "x-apikey: ${API_KEY}")

	       ((total_count++))

	       if [ $(echo "${response}" | jq '.data.attributes.last_analysis_stats.malicious') -gt 0 ]; then
	          echo "SHA256: ${hash_id}"
		  echo "${file}"
		  echo "${response}" | jq '.data.attributes.last_analysis_stats' | grep malicious 
		  echo ""
		  ((total_malicious++))
	       fi

          else
	     echo "${file} is not a valid file" 
	  fi
     done
else
   echo "Directory not found"
fi
echo ""
echo "*****Total files submitted: ${total_count}"
echo "*****Total malicious files: ${total_malicious}"
echo ""
