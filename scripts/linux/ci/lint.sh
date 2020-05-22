#!/bin/bash

PWD="$(pwd)"
echo "Current working directory: $PWD"

git diff-tree --check "$(git hash-object -t tree /dev/null)" HEAD

find "$(pwd)" -type f -not -path "*/\.git/*" >tmp
while IFS= read -r file; do
    case "$(git diff --no-index --numstat /dev/null "$file")" in
    "$(printf '%s\t-\t' -)"*)
        echo "skipping newline check for $file because it's a binary"
        continue
        ;;
    *)
        echo "Checking $file"
        [ -z "$(tail -c1 "$file")" ] || exit 1
        ;;
    esac
done <tmp
rm tmp

find . -name "Dockerfile" -type f -print0 |
    xargs -0 -I file sh -c 'docker run --rm -i hadolint/hadolint:v1.17.5-8-gc8bf307-alpine < "file"'

docker run -t \
    -v "$(pwd)":/kubernetes-playground:ro \
    garethr/kubeval:0.14.0 \
    --strict -d /kubernetes-playground/kubernetes

while IFS= read -r -d '' file; do
    f="${file#$(pwd)}"
    f="${f/\//}"
    echo "Linting $f"
    if [ ! -x "$f" ]; then echo "Error: $f is not executable!"; fi
    docker run -v "$(pwd)":/mnt:ro --rm -t koalaman/shellcheck:v0.7.1 "$f"
done < <(find "$(pwd)" -type f -not -path "*/\.git/*" -not -name "*.md" -exec grep -Eq '^#!(.*/|.*env +)(sh|bash|ksh)' {} \; -print0)

yamllint --strict "$(git ls-files '*.yaml' '*.yml')"

find . -name "*.md" -print0 -not -path "*/node_modules/*" | xargs markdownlint

shfmt -d .

cd ansible || exit 1
ansible-lint -v kubernetes.yml openssl-self-signed-certificate.yml
