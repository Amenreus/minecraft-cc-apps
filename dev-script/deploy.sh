PC_PATH="$1"

# -- Main
## -- Clean
rm -r "${PC_PATH:?}/lib"
rm -r "${PC_PATH:?}/apps"

## -- Copy
cp -r ./lib "${PC_PATH:?}/"
cp -r ./apps "${PC_PATH:?}/"