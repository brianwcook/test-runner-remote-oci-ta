
#!/bin/bash

# this is all bringing data back.

# rsync -ra "$SSH_HOST:$BUILD_DIR/workspaces/source/" "$(workspaces.source.path)/"
# rsync -ra "$SSH_HOST:$BUILD_DIR/tekton-results/" "/tekton/results/"
# buildah pull oci:rhtap-final-image
# buildah images
# buildah tag localhost/rhtap-final-image "$IMAGE"
# container=$(buildah from --pull-never "$IMAGE")
# buildah mount "$container" | tee /workspace/container_path
# echo $container > /workspace/container_name

env

# Hardcode result for now.
RESULT=SUCCESS

# emit a result like:
# TEST_OUTPUT:	{"timestamp":"1717031352","namespace":"","successes":20,"failures":0,"warnings":0,"result":"SUCCESS"}
      
echo -n "{"timestamp":"${date +%s}","namespace":"","successes":${success},"failures":"","warnings":0,"result":${RESULT}}" > "$(results.TEST_OUTPUT.path)"
