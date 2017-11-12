# hugo && rsync -Pavz --delete public/ fx@35.185.154.193:/usr/local/nginx/html
mkdir -p deployed && hugo && hugodeploy push -d