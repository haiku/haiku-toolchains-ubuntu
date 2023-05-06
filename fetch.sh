#!/bin/bash -e

GITHUB_REPOSITORY="haiku/haiku-toolchains-ubuntu"
HAIKU_ARCH="x86_64"

for opt in "$@"
do
    case $opt in
        -b|--buildtools)
            PACKAGE_NAME="buildtools"
            PACKAGE_REVISION="btrev"
            shift
            ;;
        -h|--hosttools)
            PACKAGE_NAME="hosttools"
            PACKAGE_REVISION="hrev"
            shift
            ;;
        -a=*|--arch=*)
            HAIKU_ARCH="${opt#*=}"
            shift
            ;;
        -r=*|--repository=*)
            GITHUB_REPOSITORY="${opt#*=}"
            shift
            ;;
        --rev-only)
            REV_ONLY=1
            shift
            ;;
        *)
            echo "Unknown option: $opt"
            exit 1
    esac
done

if [ -z "$PACKAGE_NAME" ]; then
    echo "Error: No package name specified."
    exit 1
fi

# Only buildtools are architecture-specific
if [ "$PACKAGE_NAME" = "buildtools" ]; then
    HAIKU_ARCH_SUFFIX="$HAIKU_ARCH-"
fi

latestRev=""
releaseUrl="https://github.com/$GITHUB_REPOSITORY/releases/tag/$PACKAGE_NAME-$HAIKU_ARCH_SUFFIX"
pageNum=1
while [ -z "$latestRev" ];
do
    # Fetch using GitHub API
    json=$(curl -s https://api.github.com/repos/$GITHUB_REPOSITORY/releases?page=$pageNum)
    pageNum=$((pageNum + 1))
    if [ $(echo $json | jq length) -eq 0 ]; then
        # This means that we've passed the end and reached an empty array
        break
    fi
    # Store array of revisions
    revisions=($(echo $json | jq -e -r ".[] | .html_url | select(contains(\"$PACKAGE_NAME\") and contains(\"$HAIKU_ARCH_SUFFIX\"))[${#releaseUrl}:]")) \
        || continue
    latestRev=${revisions[0]}
done

if [ -z "$latestRev" ]; then
    echo "Error: No revision found."
    exit 1
fi

if [ -n "$REV_ONLY" ]; then
    echo $latestRev
    exit 0
fi

hostArch=$(uname -m)
hostOs=$(uname -s | tr '[:upper:]' '[:lower:]')
releaseName="$PACKAGE_NAME-$HAIKU_ARCH_SUFFIX$latestRev"
echo "https://github.com/$GITHUB_REPOSITORY/releases/download/$releaseName/$hostArch-$hostOs-$releaseName.zip"
exit 0
