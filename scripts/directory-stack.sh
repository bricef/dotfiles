#!/bin/bash

#    utility to keep track of a stack of directory.
#    
#    usage:
#    
#    ~$ ds
#    [3]: /path/of/dir3
#    [2]: /path/of/dir2
#    [1]: /path/of/dir1
#    ~$ ds s /path/to/other/dir
#    [4]: /path/to/other/dir
#    [3]: /path/of/dir3
#    [2]: /path/of/dir2
#    [1]: /path/of/dir1
#    ~$ ds g 4
#    /path/to/other/dir$ ds
#    [4]: /path/to/other/dir
#    [3]: /path/of/dir3
#    [2]: /path/of/dir2
#    [1]: /path/of/dir1
#    /path/to/other/dir$ ds r 2
#    [3]: /path/to/other/dir
#    [2]: /path/of/dir3
#    [1]: /path/of/dir1
#    /path/to/other/dir$ ds gs /foo
#    [4]: /foo
#    [3]: /path/to/other/dir
#    [2]: /path/of/dir3
#    [1]: /path/of/dir1
#    /foo$ ds + /bar
#    [5]: /bar
#    [4]: /foo
#    [3]: /path/to/other/dir
#    [2]: /path/of/dir3
#    [1]: /path/of/dir1
#    /foo$ ds -
#    [4]: /foo
#    [3]: /path/to/other/dir
#    [2]: /path/of/dir3
#    [1]: /path/of/dir1
#    /bar$ 


STACK_FILE=~/.config/bs-stack


#
# Check that the file exists
#
if [[ -f "$STACK_FILE" ]]; then 
  :
else
  mkdir -p `dirname $STACK_FILE`
  touch $STACK_FILE
fi


ds_usage () {
  :
}

#
# Directives
#
ds_goto () {
  cd $2
}

# Adds a path to the stack without changing the local directory
ds_add () {
  if [[ -d "$1" ]]; then
    echo "$1" >> $STACK_FILE;
    MODIFIED="true"
  else
    echo "[error]: The Path '$1' could not be found and was not added to the stack" ;
    return 1
  fi
}

ds_push () {
  ds_add $1
  test $? && return 0;
  ds_goto $(wc -l $STACK_FILE | grep -o "[^0-9]*")
}

ds_pop () {
  ds_goto $(wc -l $STACK_FILE | grep -o "[^0-9]*")
  ds_delete $(wc -l $STACK_FILE | grep -o "[^0-9]*")
}

ds_delete () {
  if [[ $(echo $1 | grep -Eo '^[0-9]*$') ]]; then
    sed -i "$1d" $STACK_FILE
    MODIFIED="true"
  else
    echo "[error]: Could not understand the number specified '$1'"
  fi
}

ds_show () {
 cat $STACK_FILE | nl | sed 's/^\([[:space:]]*[0-9]*\)/\1:/'
}

#
# s: save
# g: go
# p: push (save and go)
# d: delete
# -: pop (goto and remove)
#

dirstack () {
  MODIFIED=""
  if [[ -n "$1" ]]; then 
    case $1 in
      "d"|"r")
        ds_delete $2
        ;;
      "g") 
        ds_goto $2
        ;;
      "a")
        ds_add $2
        ;;
      "+")
        ds_push $2
        ;;
      "-")
        ds_pop
        ;;
    esac
  else
    ds_usage
  fi

  if [[ "$MODIFIED" ]]; then
    ds_show
  fi
}
