#!/bin/sh
set -eu

cat > /usr/share/nginx/html/index.html <<EOF
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>LC417617 Kubernetes exp</title>
</head>
<body>
  <h1>LC417617 Kubernetes exp demo</h1>
  <p>Web-server dziala.</p>
  <p>Pod: $(hostname)</p>
</body>
</html>
EOF

exec nginx -g 'daemon off;'
