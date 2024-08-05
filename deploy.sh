#!/bin/zsh

bundle exec jekyll clean
bundle exec jekyll build

tar cf - _site | kubectl -n blog exec -i $(kubectl -n blog get pods -o name | grep blog | head -n 1) -- /bin/bash -c "tar xf - -C /tmp && rm -rf /usr/share/nginx/html/* && cp -r /tmp/_site/* /usr/share/nginx/html/"
