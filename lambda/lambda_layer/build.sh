#!/bin/bash
export WRKDIR=$(pwd)
export LYR_PDS_DIR="package_layers"

# Init Packages Directory: where we store the zip file
#Init Packages Directory
mkdir -p packages/

# Building Python-pandas layer
cd ${WRKDIR}/${LYR_PDS_DIR}/
${WRKDIR}/${LYR_PDS_DIR}/build_layer.sh
zip -r ${WRKDIR}/packages/layers.zip .
rm -rf ${WRKDIR}/${LYR_PDS_DIR}/python/
