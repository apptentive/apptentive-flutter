Release Process
Currently this package does not get released automatically, but instead must be pushed manually when a change occurs. This is the process for that:

1. Pull latest on the master branch 
1. Create new branch with your changes and update pubspec version 
1. PR the updated pubspec version
1. Merge PR and pull changes locally
Note: The PR should be merged before continuing to the next step to ensure that all GitHub actions complete and no code changes are needed prior to creating a new version.;

Pushing to Cloudsmith
Now that the changeset has been merged, it's time to create a new release!

Note: Before following these steps, make sure you have installed and authenticated with the Cloudsmith CLI.
See here for instructions installing Cloudsmith CLI https://confluence.alkami.com/adn/flutter/topic-guides/cloudsmith#Cloudsmith-Installingcloudsmith-cli


Create a tar file of the package

    tar --exclude='.dart_tool' --exclude='example' --exclude='build' -czvf package.tar.gz ./*

Push the package tar file to Cloudsmith using the CLI

    cloudsmith push dart alkami/fluttercore package.tar.gz

Create a tag for the branch for the updated version

    git tag v<versionNumber>

Example: 
    
    git tag v1.0.0

Push tag to the main branch
    
    git push origin <tag_name>
