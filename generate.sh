ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" 

# generate templates from samples
$ROOTDIR/scripts/import-repo

# get gitops templates
REPO='https://github.com/redhat-appstudio/tssc-sample-gitops'
REPONAME=$(basename $REPO)

TEMPDIR=$ROOTDIR/temp
rm -rf $TEMPDIR # clean up
mkdir -p $TEMPDIR
cd $TEMPDIR
git clone $REPO 2>&1 > /dev/null


DEST=$ROOTDIR/skeleton/gitops-template
rm -rf $DEST/components
rm -rf $DEST/application.yaml
mkdir -p $DEST/components
cp -r $TEMPDIR/$REPONAME/templates/http $DEST/components/http     # only support http now
cp -r $TEMPDIR/$REPONAME/templates/application.yaml $DEST/
rm -rf $TEMPDIR

# replace {{value}} to ${{ value }} for GPT
function iterate() {
  local dir="$1"

  for file in "$dir"/*; do
    if [ -f "$file" ]  &&  [[ "$file" != *"catalog-info.yaml"* ]]; then
      sed -i "" "s/{{/\${{ /g" $file
      sed -i "" "s/}}/ }}/g" $file
    fi

    if [ -d "$file" ]; then
      iterate "$file"
    fi
  done
}

iterate $DEST
