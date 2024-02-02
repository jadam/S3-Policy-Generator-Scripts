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
    filename="${output_directory}/${name}_s3_policy.json"


    # Generate a paragraph with variables
    contents="{
                \"Version\": \"2012-10-17\",
                \"Id\": \"SSLRulePolicy\",
                \"Statement\": [
                    {
                        \"Sid\": \"AllowSSLRequestsOnly\",
                        \"Effect\": \"Deny\",
                        \"Principal\": \"*\",
                        \"Action\": \"s3:*\",
                        \"Resource\": [
                            \"arn:aws:s3:::$name\",
                            \"arn:aws:s3:::$name/*\"
                        ],
                        \"Condition\": {
                            \"Bool\": {
                                \"aws:SecureTransport\": \"false\"
                            }
                        }
                    }
                ]
            }"

    echo "$contents" > "$filename"
    echo "File '$filename' created with contents."


    clicontents=" aws s3api put-bucket-policy --bucket ${name} --policy file://${name}_s3_policy.json "

    echo "$clicontents" >> "$clifilename"

    echo "File '$clifilename' created with contents."

done < "$names_file"

echo "Files created successfully in the directory: $output_directory"
