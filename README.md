# docker-texlive
docker texlive image

# Spell Checking

The container includes `aspell` which can be used for LaTex spell checking. Use it like

```shell
find . -name "*.tex" -exec cat "{}" \; | aspell -t -d en_US list --encoding=utf-8 -p ./dict.txt
```

where `dict.txt` is a personal dictionary.