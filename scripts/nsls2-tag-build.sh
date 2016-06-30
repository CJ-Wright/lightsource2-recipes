#!/usr/bin/env bash

# Set up the environmental variables
# Set the path to the condarc
CONDARC_PATH="/root/.condarc"
# set the location of the repo
REPO_DIR="/repo"
# define the docker container to use
IMAGE_NAME="nsls2/debian-with-miniconda:latest"
# Set the channel to upload the built packages to
UPLOAD_CHANNEL="lightsource2-tag"
REPO_ROOT=$(cd "$(dirname "$0")/.."; pwd;)
docker pull $IMAGE_NAME

echo "Running the docker container"

cat << EOF | docker run -i \
                        -v $REPO_ROOT:/repo \
                        -a stdin -a stdout -a stderr \
                        $IMAGE_NAME \
                        bash || exit $?

echo "CONDARC_PATH=$CONDARC_PATH"

# Create the condarc that we need
echo "binstar_upload: false
always_yes: true
show_channel_urls: true
channels:
- $UPLOAD_CHANNEL
- conda-forge
- defaults" > $CONDARC_PATH

# And set the correct environmental variable that lets us use it
echo "Exporting CONDARC=$CONDARC_PATH"
export CONADRC=$CONDARC_PATH

# show the conda info and make sure that the $CONDARC_PATH is what is shown 
# under "config file:" in the output of "conda info"
echo "showing conda info"
conda info

# show the contents of the condarc
echo "contents of condarc at $CONDARC_PATH"
cat $CONDARC_PATH

# install some required dependencies
conda install conda-build anaconda-client conda-execute

# not sure why this is here, but I'm reasonably certain it is important
export PYTHONUNBUFFERED=1

# execute the dev build
./repo/scripts/build.py /repo/recipes-config -u $UPLOAD_CHANNEL --python 2.7 3.4 3.5 --numpy 1.10 1.11 --token $BINSTAR_TOKEN
./repo/scripts/build.py /repo/recipes-tag -u $UPLOAD_CHANNEL --python 2.7 3.4 3.5 --numpy 1.10 1.11 --token $BINSTAR_TOKEN

EOF