#!/bin/bash

# Check if the input file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <names_file>"
    exit 1
fi

names_file="$1"
output_directory="policy_generated_files"

# Check if the file exists
if [ ! -f "$names_file" ]; then
    echo "Error: File '$names_file' not found."
    exit 1
fi

# Create the output directory if it doesn't exist
mkdir -p "$output_directory"

clifilename="${output_directory}/cli.txt"

echo " " > ${clifilename}

# Loop through each name in the file
while IFS= read -r name; do
    # Create a file with the name and write contents to it in the specified directory
    filename="${output_directory}/${name}_lifecycle_s3_policy.json"


    # Generate a paragraph with variables
      contents="{
                      \"Rules\": [
                        {
                          \"ID\": \"LifeCycle-30-days-to-IA\",
                          \"Status\": \"Enabled\",
                          \"Prefix\": \"example/\",
                          \"Transitions\": [
                            {
                              \"Days\": 30,
                              \"StorageClass\": \"STANDARD_IA\"
                            }
                          ]
                          
                        }
                      ]
                }
               "

    echo "$contents" > "$filename"
    echo "File '$filename' created with contents."


    #aws s3api put-bucket-lifecycle-configuration \
    #--bucket <YourBucketName> \
    #--lifecycle-configuration file://lifecycle-policy.json


    clicontents=" aws s3api put-bucket-lifecycle-configuration --bucket ${name} --lifecycle-configuration file://${name}_lifecycle_s3_policy.json "

    echo "$clicontents" >> "$clifilename"

    echo "File '$clifilename' created with contents."

done < "$names_file"

echo "Files created successfully in the directory: $output_directory"
