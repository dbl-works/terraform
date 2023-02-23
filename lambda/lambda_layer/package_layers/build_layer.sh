#!/bin/bash
export PKG_DIR="python"

rm -rf ${PKG_DIR} && mkdir -p ${PKG_DIR}
# --rm: Automatically remove the container when it exits
# -v: Bind mount a volume
# -w: Working directory inside the container
# lambda/lambda: A sandboxed local environment that replicates the live AWS Lambda environment almost identically (https://hub.docker.com/r/lambci/lambda/)
docker run --rm -v $(pwd):/layer -w /layer lambci/lambda:build-python3.9 \

# Run this command in the docker images
pip3 install -r requirements.txt --no-deps -t ${PKG_DIR}
