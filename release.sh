#! /bin/bash

set -u
set -e

VERSION="$1"

pep8 setup.py vulture.py
py.test-2.7
py.test-3.4
./vulture.py vulture.py whitelist.py

# Install with: sudo pip install -U collective.checkdocs
# Alternative: python setup.py --long-description | \
#              rst2html.py --exit-status 2 > output.html
python setup.py checkdocs

if [[ -n $(hg diff) ]]; then
    echo "Error: repo has uncomitted changes"
    exit 1
fi

# Bump version.
sed -i -e "s/__version__ = '.*'/__version__ = '$VERSION'/" vulture.py
if [[ -n $(hg diff) ]]; then
    hg commit -m "Update version number to $VERSION for release."
else
    echo "version number has already been set to $VERSION"
fi
hg tag "v$VERSION"

python setup.py register
python setup.py sdist upload