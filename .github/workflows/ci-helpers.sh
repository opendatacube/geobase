# This script is sourced by every step.
#
# It defines how git branch maps to docker tag and provides some bash functions

branch="${GITHUB_REF/refs\/heads\//}"

if [ branch = "master" ]; then
    BUILDER_TAG="builder"
    WHEELS_TAG="wheels"
    RUNNER_TAG="runner"
else
    BUILDER_TAG="builder-${branch}"
    WHEELS_TAG="wheels-${branch}"
    RUNNER_TAG="runner-${branch}"
fi


pull_docker_cache () {
    local image=${1}
    local fallback=${2}

    if docker pull $image ; then
        echo "Pulled ${image}"
    else
        echo "Pulling fallback ${fallback}"
        if docker pull $fallback ; then
            echo "Using fallback: ${fallback}"
            docker tag $fallback $image
        fi
    fi
}
