#!/usr/bin/env bash

# This script should update any incidental copies of the 
# "single source of truth" version, e.g. in package.json.
# It will be different for each project.

# Fail on first error.
set -e

# Check for correct number of arguments.
if [ $# -ne 1 ]; then
    echo "Usage: $0 <new.distribution.version>"
    exit 1
fi

new_version="$1"
pubspec_file="pubspec.yaml"

# Check if the podspec file exists
if [ ! -f "$pubspec_file" ]; then
    echo "Error: $pubspec_file does not exist."
    exit 1
fi

version_script=".version=\"$new_version\""
yq e -i $version_script "$pubspec_file"

echo "Updated version to $new_version in $pubspec_file."

podspec_file="ios/apptentive_flutter.podspec"

# Check if the podspec file exists
if [ ! -f "$podspec_file" ]; then
    echo "Error: $podspec_file does not exist."
    exit 1
fi

# Use sed to update the version in the podspec file
sed -i "s/s.version\( *\)= *\"[^\"]*\"/s.version\1= \"$new_version\"/" "$podspec_file"

echo "Updated version to $new_version in $podspec_file."

dart_file="lib/apptentive_flutter.dart"

# Check if the javascript file exists
if [ ! -f "$dart_file" ]; then
    echo "Error: $dart_file does not exist."
    exit 1
fi

# Use sed to update the version in the javascript file
sed -i "s/this.distributionVersion = \"[^\"]*\"/this.distributionVersion = \"$new_version\"/" "$dart_file"

echo "Updated version to $new_version in $dart_file."
