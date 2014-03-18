; -----------------------------------------------------------------------------
; BLAKE Hash Machine Code UDF
; Purpose: Provide The Machine Code Version of BLAKE Hash Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include-once
#Include <Memory.au3>

Global $_BLAKE_CodeBuffer, $_BLAKE_CodeBufferMemory
Global $_BLAKE224_InitOffset, $_BLAKE224_InputOffset, $_BLAKE224_ResultOffset
Global $_BLAKE256_InitOffset, $_BLAKE256_InputOffset, $_BLAKE256_ResultOffset
Global $_BLAKE384_InitOffset, $_BLAKE384_InputOffset, $_BLAKE384_ResultOffset
Global $_BLAKE512_InitOffset, $_BLAKE512_InputOffset, $_BLAKE512_ResultOffset

Global $_HASH_BLAKE224[4] = [28, 128, '_BLAKE224_', '_BLAKE_']
Global $_HASH_BLAKE256[4] = [32, 128, '_BLAKE256_', '_BLAKE_']
Global $_HASH_BLAKE384[4] = [48, 248, '_BLAKE384_', '_BLAKE_']
Global $_HASH_BLAKE512[4] = [64, 248, '_BLAKE512_', '_BLAKE_']

Func _BLAKE_Exit()
	$_BLAKE_CodeBuffer = 0
	_MemVirtualFree($_BLAKE_CodeBufferMemory, 0, $MEM_RELEASE)
EndFunc

Func _BLAKE_Startup()
	If Not IsDllStruct($_BLAKE_CodeBuffer) Then
		If @AutoItX64 Then
			Local $Code = '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'
				$Code &= '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'
				$Code &= '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'
				$Code &= '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'
				$Code &= '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'
				$Code &= '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'
				$Code &= '86RfKV7DEBDQy6oM0QA='
		Else
			Local $Code = '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'
				$Code &= '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'
				$Code &= 'BIPAATnodeCSdOEdidUcCygN7RTreJQjygXwQ4PSRgbpelOT5kLjiYkyX5hvD4ZVEf0I6rhofx/v6OMj8kHo+imjCsAU2LtCtAT36HnlEKkcuRwkCWpldQLzq3R9TS9zuvI6piwB8Rnpz/4KucEEKEiEGCux5yJYkkmqMEA4HCuaK3wbggjk6mSLIekamW3Gkq8TAep2oo6AjJkNOoA1VlOLMo2YUIgvsO0X5HLD+HOeDEEIzgQMHOBBEM4EFBzgQRjOBBwc4EEgzgQkHOBBKM4ELBzgQTDOBDQc4EE4z+JSYdFTz+AZjZC+7EWYzB1ZyNBaO0HaD5B8g+QfIPkHyD5B8gBJHMeAcPCkAcgU9FnoHIlkSkPsc1t8Fo4kXsOPEmRCXmiNTHZeC+LHANAIybzzkdgDZ+YJan8RCDunyoSBDIWuZ7sQECv4IpT+BBRy8248QBjxNh1fiBw6EfVPpQIg0YLmrS8hf1IOURAoH2wiPisELIxoBZtAMGu9QfuINKsR2YMfAjh5IX4TIDwZzeBEW0DhdgZ6pghHSCNMkVDIVORYclwR6PpIqIPEFGTDU9YnGIRLIPJaT8cUxFTMAwRCCFm0SCcQcft62EVcGFs16fhv/VCQ85BT02TNV/v3YCamE6/iYJUzgtieBcEQXZ0hu8sCB9V8NhAqKSGaYgIX3XAwEFoBIVmRHTnIDvdA2OwvFYQIMQvA/0FnJjPOEBEVIVhoAodKtI4Qp48h+WQCDS4M2xCkTyH6vgIdSLVHFVgl/Y/EBiw+R/q5cfoqgow8Ug03cEBDp7hrMb+QZpUAaCnwOcgPhy2EHTFTTJEJXEvd5aZlHDrM5z9IH1tMT39Qh21U80BYIn+0gjHQtXCwvjLEnPyX23/c+eGajVz7rbI93qOsVMypXIFgAmQEaAhsEXAlnOZnRZiXmdyMaNi3GSXUfzP+0IU8qFJldIh43YqSK2j2o1/RAhYcAYHzf10zl/f1RvH1f0sWNfoz17bMeryG0raj8CGEjOsMs2gxhcmC1RsBu0AqjScB0Wh2cQihDbqlapH+HnF8Et8RK+YsS4Ml/kDscyl1svYQgSK4naVhg/jh0K04bRQPzU1bxboEBUAEo3VBhHhnwVIID8ojUG4o309JDKnJGVKMLjAAWxAPdcucf7MoWOl2FPXOI2RqIkMPfxipzxtmMiJIwhwWQHQgjs0iZLziDLVckUKKSShea8gxWyyuW0B8MI6XsFJ/NKZelTDRbTiuYUFw3gy7eNcj5P6ktH/MDwObKi/mypUx+qxN5+jCgUrxpYz9hFEwMdHlnDMeD8HJEFLzBwmNPDkKt8NAMfjByH4MNCwqtkQigfaIzAEZxTHpWAigSx9kB/8wREwDs61Elxz+rJPiL4rC+Wzki5OLAo00MjVVrhh9c3IQPbAovOsSywwfy9nwHggkSyzJtou5jUQuyF1Y0EKTU7pmUAfCtbl9KKK7SBSNBAKUSqVNGTee+kDn6AbGwWPOwDw+wvqIyOtPzMrM6KKWRmry0KIeQUP3kuMYTXZIShSpE/uzqG1U0DZDT1BFt0UVpchStslltHHjo5MybSCQGjH+krFQdHMsfC5M6PhCklSvGLcZnyAkRAOkDubH2lb5KCeskSAkZENJWoeKhAmtVhOMA2zN3TYx7qHnzy5EbPs7XJIq0rStKRQB/R5kfzRNRJ8WyWJ29ZcaIfZmqVcSB+JqPlyuEOJsOIimyJVpKgMlaaWUWiOVZhIOAdYx8ZTCiTihAo0cGfnaIi9qK+WiD9aNEnyhvFkfmd0syyiR4cRM7Eq1XDWPl0LIY4QU6MYx8+juqZ1ARYdJhjuaRgwVHgiOSQfhynDgkyii2WakOK1KGOKfUCcDlcmAhP0UbEve5DZFEFnjphghOZqzeKMJvVbEigHviCXGEpoPpF+uTEkYGGhE5UlcO+owqE9SAw1Gg1Wbk1UoZtCIUs+MbDQnUKFf9wz9oh65bCglEX9yY3z+ekrUFs1KzhCUJghxWL1bRGRINazJx7KBJNAQSwyx+AgI+KK7EMox2JGh'
				$Code &= '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'
				$Code &= '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'
				$Code &= 'M0hwOnQ/LHiBc0CBxDwBLss1XtSNyGUEl8TmEujUB6gy1qlrFIlwLOS7ONWDTOyWEnhA+c+IlJaIQKX32iHyCtAR+kux1ZYiPATiU3TH2PnkWjJzeA8sQRKXL5iQj4SDkISrGV0OeNcYAz2+0Q+HYpYzuDdfGXMwD4R2B3P8hDIs/g1EaEwoFLleQMzFbJfBWtguwKHoa+GXxFNaGaaJEjHAC6uD3iEykoZfGUPw+MR8pt8ohdKXRJGNUpCWBYNreAE1kwEzdA+Gai+MGjAjuD9Y4AaJQBsQ8ODIDujv2l2FADk+vCnyvjGK6LKNfelCV3Q6gXDqUwKMGenUicaARGcB68CATMQP6fq7cbNYRCGwzl2XrURSCFMDGY1QZPNYnLtod0kKDMdAeNBMDnSM/wiJEkoMW+1CIjBENCCGl0w68y7YMgiXbCpLDLYiJRDbGhIU7RKJGHYKxBy7YgIgO8xyKDksCOhKKfJRJTDR4lwhZP3nWMh/o9PJXuLpXtrECLpi0gxdMcoQLpjCFJdMuksYprIlHNOqI9PwVv6PxAcskUf8uebEoZT5pSkQSm/Sb5YbpymSysLSMbQap6mASuzSt7r2lGKlK+9IBxv7HnmJ2QcWkqzg35imCx0x0bfAGtDbcv0vAJZ+Jmrtr+G4AJl/LPFFkHy6B/dskbNH0KEkFvwAjoXi8gEIaU4OV3HYIMVjWAqHdJBCwAQnAwoBkgG8ldwoD4S+ZAUJBkgHkQgiCUQKC4kMEg0kDkoPCGUKNDhiLA+ZJAZMXAykZ9DIRMoHZGUDMhAIliRTBShGRCkKZJQDlPIBOQRNEPKZIAFMNAymWFMOTCkGWKGoThRg0LCkYngHmTAETSwK4CkB/OUGMjgDmWwCSxgpCkyUCySyBJooFPSHVBEJygUQaBzFDT2Ewpk8BkxQCaZ0UwhoJA1UeQ5MUAGlLJQF8PUopAamRFMKDEZ4KQlMpBfqmFkCT8QpAZzqVFIUkFMErMoB8HkLTFwOjpFETQIigKrgXsNWXlcOJQyLdNE2j4XJIC/8g/kILnIn1yBQ/AI3pEkUWEAFZqWDf+kZicrBCvPru9Hh4QPcpOvdFhlfiFeRdxALMA+2oXlpwAGzA60IIXQDBQqqSSEKdfZQP/zzq6RAGKpfwwA='
		EndIf
		Local $Opcode = String(_BLAKE_CodeDecompress($Code))
		$_BLAKE224_InitOffset = (StringInStr($Opcode, "89DB") - 3) / 2
		$_BLAKE224_InputOffset = (StringInStr($Opcode, "87DB") - 3) / 2
		$_BLAKE224_ResultOffset = (StringInStr($Opcode, "09DB") - 3) / 2
		$_BLAKE256_InitOffset = (StringInStr($Opcode, "89C9") - 3) / 2
		$_BLAKE256_InputOffset = (StringInStr($Opcode, "87C9") - 3) / 2
		$_BLAKE256_ResultOffset = (StringInStr($Opcode, "09C9") - 3) / 2
		$_BLAKE384_InitOffset = (StringInStr($Opcode, "89D2") - 3) / 2
		$_BLAKE384_InputOffset = (StringInStr($Opcode, "87D2") - 3) / 2
		$_BLAKE384_ResultOffset = (StringInStr($Opcode, "09D2") - 3) / 2
		$_BLAKE512_InitOffset = (StringInStr($Opcode, "89F6") - 3) / 2
		$_BLAKE512_InputOffset = (StringInStr($Opcode, "87F6") - 3) / 2
		$_BLAKE512_ResultOffset = (StringInStr($Opcode, "09F6") - 3) / 2
		$Opcode = Binary($Opcode)

		$_BLAKE_CodeBufferMemory = _MemVirtualAlloc(0, BinaryLen($Opcode), $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)
		$_BLAKE_CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $_BLAKE_CodeBufferMemory)
		DllStructSetData($_BLAKE_CodeBuffer, 1, $Opcode)
		OnAutoItExitRegister("_BLAKE_Exit")
	EndIf
EndFunc

Func _BLAKE224Init()
	If Not IsDllStruct($_BLAKE_CodeBuffer) Then _BLAKE_Startup()

	Local $Context = DllStructCreate("byte[" & $_HASH_BLAKE224[1] & "]")
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_BLAKE_CodeBuffer) + $_BLAKE224_InitOffset, _
													"ptr", DllStructGetPtr($Context), _
													"int", 0, _
													"int", 0, _
													"int", 0)

	Return $Context
EndFunc

Func _BLAKE256Init()
	If Not IsDllStruct($_BLAKE_CodeBuffer) Then _BLAKE_Startup()

	Local $Context = DllStructCreate("byte[" & $_HASH_BLAKE256[1] & "]")
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_BLAKE_CodeBuffer) + $_BLAKE256_InitOffset, _
													"ptr", DllStructGetPtr($Context), _
													"int", 0, _
													"int", 0, _
													"int", 0)

	Return $Context
EndFunc

Func _BLAKE384Init()
	If Not IsDllStruct($_BLAKE_CodeBuffer) Then _BLAKE_Startup()

	Local $Context = DllStructCreate("byte[" & $_HASH_BLAKE384[1] & "]")
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_BLAKE_CodeBuffer) + $_BLAKE384_InitOffset, _
													"ptr", DllStructGetPtr($Context), _
													"int", 0, _
													"int", 0, _
													"int", 0)

	Return $Context
EndFunc

Func _BLAKE512Init()
	If Not IsDllStruct($_BLAKE_CodeBuffer) Then _BLAKE_Startup()

	Local $Context = DllStructCreate("byte[" & $_HASH_BLAKE512[1] & "]")
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_BLAKE_CodeBuffer) + $_BLAKE512_InitOffset, _
													"ptr", DllStructGetPtr($Context), _
													"int", 0, _
													"int", 0, _
													"int", 0)

	Return $Context
EndFunc


Func _BLAKE224Input(ByRef $Context, $Data)
	If Not IsDllStruct($_BLAKE_CodeBuffer) Then _BLAKE_Startup()
	If Not IsDllStruct($Context) Then Return SetError(1, 0, 0)

	$Data = Binary($Data)
	Local $InputLen = BinaryLen($Data)
	Local $Input = DllStructCreate("byte[" & $InputLen & "]")
	DllStructSetData($Input, 1, $Data)
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_BLAKE_CodeBuffer) + $_BLAKE224_InputOffset, _
													"ptr", DllStructGetPtr($Context), _
													"ptr", DllStructGetPtr($Input), _
													"uint", $InputLen, _
													"int", 0)
EndFunc

Func _BLAKE256Input(ByRef $Context, $Data)
	If Not IsDllStruct($_BLAKE_CodeBuffer) Then _BLAKE_Startup()
	If Not IsDllStruct($Context) Then Return SetError(1, 0, 0)

	$Data = Binary($Data)
	Local $InputLen = BinaryLen($Data)
	Local $Input = DllStructCreate("byte[" & $InputLen & "]")
	DllStructSetData($Input, 1, $Data)
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_BLAKE_CodeBuffer) + $_BLAKE256_InputOffset, _
													"ptr", DllStructGetPtr($Context), _
													"ptr", DllStructGetPtr($Input), _
													"uint", $InputLen, _
													"int", 0)
EndFunc

Func _BLAKE384Input(ByRef $Context, $Data)
	If Not IsDllStruct($_BLAKE_CodeBuffer) Then _BLAKE_Startup()
	If Not IsDllStruct($Context) Then Return SetError(1, 0, 0)

	$Data = Binary($Data)
	Local $InputLen = BinaryLen($Data)
	Local $Input = DllStructCreate("byte[" & $InputLen & "]")
	DllStructSetData($Input, 1, $Data)
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_BLAKE_CodeBuffer) + $_BLAKE384_InputOffset, _
													"ptr", DllStructGetPtr($Context), _
													"ptr", DllStructGetPtr($Input), _
													"uint", $InputLen, _
													"int", 0)
EndFunc

Func _BLAKE512Input(ByRef $Context, $Data)
	If Not IsDllStruct($_BLAKE_CodeBuffer) Then _BLAKE_Startup()
	If Not IsDllStruct($Context) Then Return SetError(1, 0, 0)

	$Data = Binary($Data)
	Local $InputLen = BinaryLen($Data)
	Local $Input = DllStructCreate("byte[" & $InputLen & "]")
	DllStructSetData($Input, 1, $Data)
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_BLAKE_CodeBuffer) + $_BLAKE512_InputOffset, _
													"ptr", DllStructGetPtr($Context), _
													"ptr", DllStructGetPtr($Input), _
													"uint", $InputLen, _
													"int", 0)
EndFunc


Func _BLAKE224Result(ByRef $Context)
	If Not IsDllStruct($_BLAKE_CodeBuffer) Then _BLAKE_Startup()
	If Not IsDllStruct($Context) Then Return SetError(1, 0, "")

	Local $Digest = DllStructCreate("byte[" & $_HASH_BLAKE224[0] & "]")
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_BLAKE_CodeBuffer) + $_BLAKE224_ResultOffset, _
													"ptr", DllStructGetPtr($Context), _
													"ptr", DllStructGetPtr($Digest), _
													"int", 0, _
													"int", 0)
	Return DllStructGetData($Digest, 1)
EndFunc

Func _BLAKE256Result(ByRef $Context)
	If Not IsDllStruct($_BLAKE_CodeBuffer) Then _BLAKE_Startup()
	If Not IsDllStruct($Context) Then Return SetError(1, 0, "")

	Local $Digest = DllStructCreate("byte[" & $_HASH_BLAKE256[0] & "]")
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_BLAKE_CodeBuffer) + $_BLAKE256_ResultOffset, _
													"ptr", DllStructGetPtr($Context), _
													"ptr", DllStructGetPtr($Digest), _
													"int", 0, _
													"int", 0)
	Return DllStructGetData($Digest, 1)
EndFunc

Func _BLAKE384Result(ByRef $Context)
	If Not IsDllStruct($_BLAKE_CodeBuffer) Then _BLAKE_Startup()
	If Not IsDllStruct($Context) Then Return SetError(1, 0, "")

	Local $Digest = DllStructCreate("byte[" & $_HASH_BLAKE384[0] & "]")
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_BLAKE_CodeBuffer) + $_BLAKE384_ResultOffset, _
													"ptr", DllStructGetPtr($Context), _
													"ptr", DllStructGetPtr($Digest), _
													"int", 0, _
													"int", 0)
	Return DllStructGetData($Digest, 1)
EndFunc

Func _BLAKE512Result(ByRef $Context)
	If Not IsDllStruct($_BLAKE_CodeBuffer) Then _BLAKE_Startup()
	If Not IsDllStruct($Context) Then Return SetError(1, 0, "")

	Local $Digest = DllStructCreate("byte[" & $_HASH_BLAKE512[0] & "]")
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_BLAKE_CodeBuffer) + $_BLAKE512_ResultOffset, _
													"ptr", DllStructGetPtr($Context), _
													"ptr", DllStructGetPtr($Digest), _
													"int", 0, _
													"int", 0)
	Return DllStructGetData($Digest, 1)
EndFunc

Func _BLAKE224($Data)
	Local $Context = _BLAKE224Init()
	_BLAKE224Input($Context, $Data)
	Return _BLAKE224Result($Context)
EndFunc

Func _BLAKE256($Data)
	Local $Context = _BLAKE256Init()
	_BLAKE256Input($Context, $Data)
	Return _BLAKE256Result($Context)
EndFunc

Func _BLAKE384($Data)
	Local $Context = _BLAKE384Init()
	_BLAKE384Input($Context, $Data)
	Return _BLAKE384Result($Context)
EndFunc

Func _BLAKE512($Data)
	Local $Context = _BLAKE512Init()
	_BLAKE512Input($Context, $Data)
	Return _BLAKE512Result($Context)
EndFunc

Func _BLAKE_CodeDecompress($Code)
	If @AutoItX64 Then
		Local $Opcode = '0x89C04150535657524889CE4889D7FCB28031DBA4B302E87500000073F631C9E86C000000731D31C0E8630000007324B302FFC1B010E85600000010C073F77544AAEBD3E85600000029D97510E84B000000EB2CACD1E8745711C9EB1D91FFC8C1E008ACE8340000003D007D0000730A80FC05730783F87F7704FFC1FFC141904489C0B301564889FE4829C6F3A45EEB8600D275078A1648FFC610D2C331C9FFC1E8EBFFFFFF11C9E8E4FFFFFF72F2C35A4829D7975F5E5B4158C389D24883EC08C70100000000C64104004883C408C389F64156415541544D89CC555756534C89C34883EC20410FB64104418800418B3183FE010F84AB00000073434863D24D89C54889CE488D3C114839FE0F84A50100000FB62E4883C601E8C601000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D3C1E20241885500EB7383FE020F841C01000031C083FE03740F4883C4205B5E5F5D415C415D415EC34863D24D89C54889CE488D3C114839FE0F84CA0000000FB62E4883C601E86401000083ED2B4080FD5077E2480FBEED0FB6042884C078D683E03F410845004983C501E964FFFFFF4863D24D89C54889CE488D3C114839FE0F84E00000000FB62E4883C601E81D01000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D389D04D8D7501C1E20483E03041885501C1F804410845004839FE747B0FB62E4883C601E8DD00000083ED2B4080FD5077E6480FBEED0FB6042884C00FBED078D789D0C1E2064D8D6E0183E03C41885601C1F8024108064839FE0F8536FFFFFF41C7042403000000410FB6450041884424044489E84883C42029D85B5E5F5D415C415D415EC34863D24889CE4D89C6488D3C114839FE758541C7042402000000410FB60641884424044489F04883C42029D85B5E5F5D415C415D415EC341C7042401000000410FB6450041884424044489E829D8E998FEFFFF41C7042400000000410FB6450041884424044489E829D8E97CFEFFFF56574889CF4889D64C89C1FCF3A45F5EC3E8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3'
	Else
		Local $Opcode = '0x89C0608B7424248B7C2428FCB28031DBA4B302E86D00000073F631C9E864000000731C31C0E85B0000007323B30241B010E84F00000010C073F7753FAAEBD4E84D00000029D97510E842000000EB28ACD1E8744D11C9EB1C9148C1E008ACE82C0000003D007D0000730A80FC05730683F87F770241419589E8B3015689FE29C6F3A45EEB8E00D275058A164610D2C331C941E8EEFFFFFF11C9E8E7FFFFFF72F2C32B7C2428897C241C61C389D28B442404C70000000000C6400400C2100089F65557565383EC1C8B6C243C8B5424388B5C24308B7424340FB6450488028B550083FA010F84A1000000733F8B5424388D34338954240C39F30F848B0100000FB63B83C301E8CD0100008D57D580FA5077E50FBED20FB6041084C00FBED078D78B44240CC1E2028810EB6B83FA020F841201000031C083FA03740A83C41C5B5E5F5DC210008B4C24388D3433894C240C39F30F84CD0000000FB63B83C301E8740100008D57D580FA5077E50FBED20FB6041084C078DA8B54240C83E03F080283C2018954240CE96CFFFFFF8B4424388D34338944240C39F30F84D00000000FB63B83C301E82E0100008D57D580FA5077E50FBED20FB6141084D20FBEC278D78B4C240C89C283E230C1FA04C1E004081189CF83C70188410139F374750FB60383C3018844240CE8EC0000000FB654240C83EA2B80FA5077E00FBED20FB6141084D20FBEC278D289C283E23CC1FA02C1E006081739F38D57018954240C8847010F8533FFFFFFC74500030000008B4C240C0FB60188450489C82B44243883C41C5B5E5F5DC210008D34338B7C243839F3758BC74500020000000FB60788450489F82B44243883C41C5B5E5F5DC210008B54240CC74500010000000FB60288450489D02B442438E9B1FEFFFFC7450000000000EB9956578B7C240C8B7424108B4C241485C9742FFC83F9087227F7C7010000007402A449F7C702000000740566A583E90289CAC1E902F3A589D183E103F3A4EB02F3A45F5EC3E8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3'
	EndIf
	Local $AP_Decompress = (StringInStr($Opcode, "89C0") - 3) / 2
	Local $B64D_Init = (StringInStr($Opcode, "89D2") - 3) / 2
	Local $B64D_DecodeData = (StringInStr($Opcode, "89F6") - 3) / 2
	$Opcode = Binary($Opcode)

	Local $CodeBufferMemory = _MemVirtualAlloc(0, BinaryLen($Opcode), $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)
	Local $CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $CodeBufferMemory)
	DllStructSetData($CodeBuffer, 1, $Opcode)

	Local $B64D_State = DllStructCreate("byte[16]")
	Local $Length = StringLen($Code)
	Local $Output = DllStructCreate("byte[" & $Length & "]")

	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($CodeBuffer) + $B64D_Init, _
													"ptr", DllStructGetPtr($B64D_State), _
													"int", 0, _
													"int", 0, _
													"int", 0)

	DllCall("user32.dll", "int", "CallWindowProc", "ptr", DllStructGetPtr($CodeBuffer) + $B64D_DecodeData, _
													"str", $Code, _
													"uint", $Length, _
													"ptr", DllStructGetPtr($Output), _
													"ptr", DllStructGetPtr($B64D_State))

	Local $ResultLen = DllStructGetData(DllStructCreate("uint", DllStructGetPtr($Output)), 1)
	Local $Result = DllStructCreate("byte[" & ($ResultLen + 16) & "]")

	Local $Ret = DllCall("user32.dll", "uint", "CallWindowProc", "ptr", DllStructGetPtr($CodeBuffer) + $AP_Decompress, _
													"ptr", DllStructGetPtr($Output) + 4, _
													"ptr", DllStructGetPtr($Result), _
													"int", 0, _
													"int", 0)


	_MemVirtualFree($CodeBufferMemory, 0, $MEM_RELEASE)
	Return BinaryMid(DllStructGetData($Result, 1), 1, $Ret[0])
EndFunc
