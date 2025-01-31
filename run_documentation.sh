# Change to the script directory
cd $(dirname "$0")
# Ensure a properly setup virtual environment
printf "Setting up the virtual environment..."
python3 -m virtualenv venv > /dev/null
source venv/bin/activate
# If not in an venv, do not continue
if [ -z "$VIRTUAL_ENV" ]; then
    printf "\nNot in a virtual environment. Exiting."
    exit 1
fi
pip install -r requirements.txt > /dev/null
printf "done.\n"
# Make a temp init.py that only has the content below the __README_CONTENT_IS_COPIED_ABOVE__ line
cp README.md type_enforced/__init__.py
sed -i '1s/^/\"\"\"\n/' type_enforced/__init__.py
echo "\"\"\"" >> type_enforced/__init__.py
echo "from .enforcer import Enforcer, FunctionMethodEnforcer" >> type_enforced/__init__.py


# Specify versions for documentation purposes
VERSION="1.10.1"
OLD_DOC_VERSIONS="1.9.0 1.8.1 1.7.0 1.6.0 1.5.0 1.4.0 1.3.0 1.2.0 1.1.1 0.0.16"
export version_options="$VERSION $OLD_DOC_VERSIONS"

# generate the docs for a version function:
function generate_docs() {
    INPUT_VERSION=$1
    if [ $INPUT_VERSION != "./" ]; then
        if [ $INPUT_VERSION != $VERSION ]; then
            pip install "./dist/type_enforced-$INPUT_VERSION.tar.gz"
        fi
    fi
    pdoc -o ./docs/$INPUT_VERSION -t ./doc_template type_enforced
}

# Generate the docs for the current version
generate_docs ./
generate_docs $VERSION

# Generate the docs for all the old versions
for version in $OLD_DOC_VERSIONS; do
    generate_docs $version
done;

# Reinstall the current package as an egg
pip install -e .
