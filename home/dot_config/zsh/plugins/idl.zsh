export EXELIS_DIR=$HOME/Applications/harris
export IDL_DIR=$EXELIS_DIR/idl88
export IDL_EXE=$IDL_DIR/bin/idl

if command -v $IDL_EXE >/dev/null; then
    export PATH="$IDL_DIR/bin:$PATH"
    export PYTHONPATH=$IDL_DIR/lib/bridges:$PYTHONPATH
    export PYTHONPATH=$IDL_DIR/bin/bin.darwin.x86_64:$PYTHONPATH
fi