#! /bin/bash

BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SECURESTORE="$BIN_DIR/securestore"
VCSTORE="$BIN_DIR/vcstore"
PASS="$BIN_DIR/pass"

EDITOR=cat
WORKING_DIR="$(mktemp --directory)"

TMP_FILE="$(mktemp)"

NUM_PASSED=0
NUM_FAILED=0

#
# Helper functions
#

result_of() {
	if [ $? -eq 0 ]; then
		echo -en "\e[32m ✓ Pass: "
		(( NUM_PASSED++ ))
	else
		echo -en "\e[31m ✗ Fail: "
		(( NUM_FAILED++ ))
	fi

	echo -e "$@" "\e[m"
}

run_test_func() {
	echo "$1 Tests"
	echo

	$2
	echo

	rm -Rf * .git .gpg_id
}

#
# Test functions
#

test_securestore() {
	[[ "$($SECURESTORE 2>&1)" =~ not\ initialised ]]
	result_of "Run command"

	[[ "$($SECURESTORE init 2>&1)" =~ provide\ a\ GPG\ Key ]]
	result_of "Initialise store, no key"

	[[ "$($SECURESTORE init $GPG_KEY_ID 2>&1)" =~ ^$ ]]
	result_of "Initialise store"

	[[ "$($SECURESTORE init $GPG_KEY_ID 2>&1)" =~ already\ initialised ]]
	result_of "Reinitialise store"

	[[ "$($SECURESTORE list 2>&1)" =~ \. ]]
	result_of "List empty store"

	[[ "$(ls -a 2>&1)" =~ \.gpg_id ]]
	result_of "Verify .gpg_id file exists"

	[[ "$($SECURESTORE add Entry $TMP_FILE 2>&1)" =~ ^$ ]]
	result_of "Add file to store"

	[[ "$($SECURESTORE file Entry 2>&1)" =~ encrypted|^Entry:\ data$ ]]
	result_of "Verify entry is encrypted"

	[[ "$($SECURESTORE list 2>&1)" =~ Entry ]]
	result_of "List store containing single entry"

	[[ "$($SECURESTORE move Entry MovedEntry 2>&1)" =~ ^$ ]]
	result_of "Move entry"

	[[ "$($SECURESTORE list 2>&1)" =~ Entry ]]
	result_of "Verify store does not contain old entry"

	[[ "$($SECURESTORE list 2>&1)" =~ MovedEntry ]]
	result_of "Verify store contains moved entry"

	[[ "$($SECURESTORE get MovedEntry 2>&1)" =~ Hello\ World ]]
	result_of "Get contents of entry"

	OLD_HASH="$(md5sum MovedEntry 2> /dev/null)"
	[[ "$($SECURESTORE edit MovedEntry 2>&1)" =~ Hello\ World ]]
	result_of "Edit entry"

	[[ "$(md5sum MovedEntry 2>&1)" == "$OLD_HASH" ]]
	result_of "Verify entry was not re-encrypted (i.e. changed)"

	[[ "$($SECURESTORE file MovedEntry 2>&1)" =~ encrypted ]]
	result_of "Verify entry is encrypted"

	! [[ "$($SECURESTORE strings MovedEntry 2>&1)" =~ Username ]]
	result_of "Verify entry is encrypted (alternate method)"

	[[ "$($SECURESTORE remove MovedEntry 2>&1)" =~ ^$ ]]
	result_of "Remove entry"

	! [[ "$($SECURESTORE list 2>&1)" =~ MovedEntry ]]
	result_of "Verify store does not contain moved entry"
}

test_vcstore() {
	[[ "$($VCSTORE 2>&1)" =~ not\ initialised ]]
	result_of "Run command"

	[[ "$($VCSTORE init $GPG_KEY_ID 2>&1)" =~ ^$ ]]
	result_of "Initialise store"

	[[ "$(git status 2>&1)" =~ On\ branch\ master ]]
	result_of "Verify git respository was initialised"

	[[ "$(git log --oneline 2>&1)" =~ Added\ .gpg_id\ file ]]
	result_of "Verify initial commit was made"

	[[ "$($VCSTORE add Entry $TMP_FILE 2>&1)" =~ ^$ ]]
	result_of "Add file to store"

	[[ "$(git log --oneline 2>&1)" =~ Added\ \'Entry\' ]]
	result_of "Verify commit was made"

	[[ "$($VCSTORE move Entry MovedEntry 2>&1)" =~ ^$ ]]
	result_of "Move entry"

	[[ "$(git log --oneline 2>&1)" =~ Renamed\ \'Entry\' ]]
	result_of "Verify commit was made"

	[[ "$($VCSTORE edit MovedEntry 2>&1)" =~ Hello\ World ]]
	result_of "Edit entry"

	! [[ "$(git log --oneline 2>&1)" =~ Updated\ \'MovedEntry\' ]]
	result_of "Verify no commit was made"

	[[ "$($VCSTORE file MovedEntry 2>&1)" =~ encrypted ]]
	result_of "Verify entry is encrypted"

	! [[ "$($VCSTORE strings MovedEntry 2>&1)" =~ Username ]]
	result_of "Verify entry is encrypted (alternate method)"

	[[ "$($VCSTORE remove MovedEntry 2>&1)" =~ ^$ ]]
	result_of "Remove entry"

	[[ "$(git log --oneline 2>&1)" =~ Removed\ \'MovedEntry\' ]]
	result_of "Verify commit was made"
}

test_pass() {
	export STORE_DIR="$WORKING_DIR"
	export NEW_PASS_CHARS='a-zA-Z'
	export NEW_PASS_LEN=10

	cat > .template <<-EOF
	Username="TestUser"
	Password="{PASSWORD}"

	AutoType() {
		return 0
	}

	DoSomething() {
		echo -n "Running Function"
	}
	EOF


	[[ "$($PASS 2>&1)" =~ not\ initialised ]]
	result_of "Run command"

	[[ "$($PASS init $GPG_KEY_ID 2>&1)" =~ ^$ ]]
	result_of "Initialise store"

	[[ "$($PASS add Entry 2>&1)" =~ ^Username ]]
	result_of "Add entry to store"

	[[ "$($PASS add 2>&1)" =~ provide\ a\ unique\ name ]]
	result_of "Add blank entry to store"

	! [[ "$($PASS add OtherEntry 2>&1)" =~ \{PASSWORD\} ]]
	result_of "Add entry to store with automated password generation"

	[[ "$($PASS list 2>&1)" =~ Entry.+OtherEntry ]]
	result_of "List store containing multiple entries"

	[[ "$($PASS list-properties Entry 2>&1)" =~ ^Username.Password$ ]]
	result_of "List properties of entry"

	[[ "$($PASS list-functions Entry 2>&1)" =~ ^AutoType.DoSomething$ ]]
	result_of "List functions from entry"

	[[ "$($PASS get-property Entry Username 2>&1)" =~ ^TestUser$ ]]
	result_of "Get property from entry"

	[[ "$($PASS run-function Entry DoSomething 2>&1)" =~ ^Running\ Function$ ]]
	result_of "Run function from entry"

	[[ "$($PASS file Entry 2>&1)" =~ encrypted ]]
	result_of "Verify entry is encrypted"

	! [[ "$($PASS strings Entry 2>&1)" =~ Username ]]
	result_of "Verify entry is encrypted (alternate method)"

	[[ "$($PASS pass_generate_password 2>&1)" =~ ^[a-zA-Z]{10}$ ]]
	result_of "Generate password"
}

#
# Initialisation
#

echo "Hello World" > "$TMP_FILE"

if [ -z "$GPG_KEY_ID" ]; then
	read -p 'GPG Key ID to use for tests: ' GPG_KEY_ID
fi

#
# Run tests
#

pushd "$WORKING_DIR" &> /dev/null

run_test_func "SecureStore" test_securestore
run_test_func "VCStore" test_vcstore
run_test_func "Pass" test_pass

echo "Passed $NUM_PASSED tests, failed $NUM_FAILED"

popd &> /dev/null
rm -Rf "$WORKING_DIR" "$TMP_FILE"


[ $NUM_FAILED -eq 0 ] && exit 0 || exit 1
