#!/bin/bash
set -euxo pipefail

dnf -y install nginx
systemctl enable --now nginx

cat >/usr/share/nginx/html/index.html <<'HTML'
<!doctype html>
<html lang="fr">
<body>
  <h1>Donatily — L3</h1>
  <p>Instance applicative privée (frontend). Sortie Internet via NAT Gateway classique.</p>
</body>
</html>
HTML

if curl -fsS --max-time 15 https://checkip.amazonaws.com >/usr/share/nginx/html/nat-check.txt; then
  echo "NAT_OK" >>/usr/share/nginx/html/nat-check.txt
else
  echo "NAT_FAIL" >/usr/share/nginx/html/nat-check.txt
fi

REPO="${app_repo_url}"
if [ -n "$REPO" ]; then
  dnf -y install git || true
  git clone "$REPO" /opt/donatily || true
fi
