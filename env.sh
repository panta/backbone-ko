if [[ $_ == $0 ]] ; then
	echo "Please source this script instead of executing it!"
	exit 1
fi

export PATH=`pwd`/node_modules/.bin:$PATH
echo
echo "The environment is ready."
echo
