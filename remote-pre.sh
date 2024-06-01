#!/bin/bash
# setup SSH host
set -o verbose
set -eu
set -o pipefail
mkdir -p ~/.ssh
if [ -e "/ssh/error" ]; then
#no server could be provisioned
cat /ssh/error
exit 1
elif [ -e "/ssh/otp" ]; then
curl --cacert /ssh/otp-ca -XPOST -d @/ssh/otp $(cat /ssh/otp-server) >~/.ssh/id_rsa
echo "" >> ~/.ssh/id_rsa
else
cp /ssh/id_rsa ~/.ssh
fi
chmod 0400 ~/.ssh/id_rsa
export SSH_HOST=$(cat /ssh/host)
export WORKD_DIR=$(cat /ssh/user-dir)
export SSH_ARGS="-o StrictHostKeyChecking=no"

mkdir -p scripts
echo "$BUILD_DIR"
ssh $SSH_ARGS "$SSH_HOST"  mkdir -p "$BUILD_DIR/workspaces" "$BUILD_DIR/scripts" "$BUILD_DIR/tmp"
echo -e local arch is: $(arch)
echo -e remote arch is:
ssh $SSH_ARGS "$SSH_HOST" /bin/bash -c "arch"

# transfers data
# rsync -ra $(workspaces.source.path)/ "$SSH_HOST:$BUILD_DIR/workspaces/source/"

# write the script to disk:
cat >scripts/script-build.sh <<'REMOTESSHEOF'
#!/bin/bash
set -o verbose
echo 'script-build.sh start'
echo -e  $(uname -m)

# cd $(workspaces.source.path)
# if [ -z "$CONFIG_FILE" ] ; then
#  CONFIG_FILE_ARG=""
# else
#  CONFIG_FILE_ARG="  --image-config=source/$CONFIG_FILE "
#fi

# rpm-ostree compose image --initialize --format oci $CONFIG_FILE_ARG "source/$IMAGE_FILE" rhtap-final-image

echo 'script-build.sh end'
REMOTESSHEOF

# make it executable
chmod +x scripts/script-build.sh

# sync scripts dir to the SSH Host
rsync -ra scripts "$SSH_HOST:$BUILD_DIR"

# for debugging
ssh $SSH_ARGS "$SSH_HOST" /bin/bash -c "ls -alR /scripts"
ssh $SSH_ARGS "$SSH_HOST" /bin/bash -c "cat /script/script-build.sh"


# execute the script in a container on the SSH host
ssh $SSH_ARGS "$SSH_HOST" podman  run \
-e PARAM_BUILDER_IMAGE="quay.io/bcook/jq-ubi9:latest" \
-v $BUILD_DIR/scripts:/script:Z \
--user=0  --rm  "$BUILDER_IMAGE" /script/script-build.sh


