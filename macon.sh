#!/bin/bash

# 1st paramter is collection_id. Make sure the first parameter isn't blank.
if [ -z "$1" ]; then
	echo "Usage: $0 <collection_id>"
	exit 1
fi
collection_id=$1

# Get a list of the NFTs from the Mintgarden API. Encoded_id is the value we know as "NFT ID".
nft_list=$(curl -s https://api.mintgarden.io/collections/$collection_id/nfts/ids | jq -r '.[] | .encoded_id')

# Start with an empty string and we will loop through every NFT and add it's JSON to our variable.
# Emulate a progress bar by just printing a period each time it processes an NFT.
mg_nfts_json=""
echo -n "Processing"
for nid in $nft_list; do
    nft_data=$(curl -s https://api.mintgarden.io/nfts/$nid)
    mg_nfts_json="$mg_nfts_json$nft_data,"
	printf "."
done
printf " Done!"
echo ""

# Do a little mending of the JSON by removing the last unneeded comma and wrapping in square brackets so it is valid JSON.
mg_nfts_json="[${mg_nfts_json%?}]"

# Get the collection name from the last NFT. Also replace any spaces with an underscore.
collection_name=$(echo $nft_data | jq -r '.collection.name')
cname="${collection_name// /_}"

# Write to an output file in the current directory.
echo "$mg_nfts_json" > ./$cname.json
