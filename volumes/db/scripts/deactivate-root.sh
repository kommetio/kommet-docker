#! /bin/bash

hash=$1

psql -U postgres -d env0010000000002 -c "UPDATE obj_004 SET _triggerflag = 'UPDATEROOTPWD', isactive = false, activationhash = '$hash' where username = 'root'";

echo $hash
