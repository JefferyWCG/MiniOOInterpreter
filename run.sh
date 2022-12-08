mode=0

code=`cat user.txt`

while getopts ":m" flag; do
	case "${flag}" in
		m) mode=1;;
	esac
done

if [ "$mode" == "0" ]; then
	./src/interpreter "$code"
elif [ "$mode" == "1" ]; then
	./src/interpreter -m "$code"
else
    echo "please pass correct argument"
fi
