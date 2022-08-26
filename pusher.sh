die () {
    echo >&2 "$@"
    exit 1
}
[ "$#" -eq 1 ] || die "1 argument, the commit message, required, $# provided"
git add .;
git commit -m "$1";
git push;
