#!/usr/bin/env bash

if [ -z "$STANDARDS_CSV" ]
then
	STANDARDS_CSV=PEAR
fi

defaultFiles=(
  '.phpcs.xml'
  'phpcs.xml'
)
for phpcsfile in "${defaultFiles[@]}"; do
  if [[ -f "/github/workspace/$phpcsfile" ]]; then
      STANDARDS_CSV="${STANDARDS_CSV},/github/workspace/$phpcsfile"
  fi
done

BASE_REF_HASH=$(git show-ref -s $GITHUB_BASE_REF) # Sha of the target branch
HEAD_REF_HASH=$(git show-ref -s $GITHUB_HEAD_REF) # Sha of our branch
DIFF_FILEPATHS=$(git diff --name-only $BASE_REF_HASH $HEAD_REF_HASH)

echo "Starting PHPCS parser..."
/root/.composer/vendor/bin/phpcs -q \
 	--extensions=php \
	-d memory_limit=1G \
	--standard=${STANDARDS_CSV} \
	${DIFF_FILEPATHS}

## Get the exit status code ##
status=$?
[ $status -eq 0 ] &&echo "[Success] Finished code inspection." || exit $status
