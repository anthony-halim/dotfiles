genpw() {
  local length="${1:-32}"
  python -c "import secrets;import string;print(secrets.token_urlsafe($length));"
}
