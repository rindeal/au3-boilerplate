#include<../Execute.au3>

$file=FileOpen("beispiel1.au3")
$read=FileRead($file)
FileClose($file)
_Execute($read)