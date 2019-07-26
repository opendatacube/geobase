set -eu

SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

cd "${SDIR}"

mkdir -p build
mkdir -p dl

docker run \
       -v $(pwd)/dl:/dl \
       -v $(pwd)/build:/build \
       -ti --rm \
       geo-builder:local $@
