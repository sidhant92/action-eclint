#!/bin/sh

cd "$GITHUB_WORKSPACE"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"


ls -la

eclint --version

TARGET_FOLDER=$(mktemp -d -t reviewdog-eclint-XXXXXXXXXX)



eclint check src/

# Make eclint think that we are Jenkins to get Checksuite type output
JENKINS_URL=1 BUILD_ID=1 CI_REPORTS="$TARGET_FOLDER" \
  eclint check ${INPUT_ECLINT_FLAGS:-'.'} 2>/dev/null

# Extract result from file or fallback if file does not exist
(cat $TARGET_FOLDER/*/checkstyle-result.xml 2>/dev/null || echo '<checkstyle></checkstyle>') | \
  reviewdog -f=checkstyle -name="eclint" -reporter="${INPUT_REPORTER:-github-pr-check}" -level="${INPUT_LEVEL}"
