#!/bin/bash
TERRAFORM_VERSION="0.11.3"
docker run --rm -v $(pwd):/data --workdir=/data hashicorp/terraform:$TERRAFORM_VERSION output $1
