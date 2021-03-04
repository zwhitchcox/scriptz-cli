git add . -A
git commit -m "release"
git tag -f latest
git push -f origin latest
git push
