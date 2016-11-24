#This Powershell Script creates Outlook signatures for Active Direcory users and sets it as their default 
$strName = $env:username

$strFilter = "(&(objectCategory=User)(samAccountName=$strName))"

$objSearcher = New-Object System.DirectoryServices.DirectorySearcher 
$objSearcher.Filter = $strFilter

$objPath = $objSearcher.FindOne() 
$objUser = $objPath.GetDirectoryEntry()

$strName = $objUser.FullName 
$strTitle = $objUser.Title 
$strCompany = $objUser.Company 
$objdepartment = $objUser.department
$strCred = $objUser.info 
$strStreet = $objUser.StreetAddress 
$strPhone = $objUser.telephoneNumber 
$strmobile = $objUser.mobile
$strDirect = $objUser.ipPhone 
$strXTEN = $objUser.PhysicalDeliveryOfficeName 
$strFax = $objUser.facsimileTelephoneNumber 
$strCity = $objUser.l 
$strCountry = $objUser.co 
$strEmail = $objUser.mail 
$strWebsite = $objUser.wWWHomePage




$UserDataPath = $Env:appdata 

$FolderLocation = $UserDataPath + '\\Microsoft\\signatures' 
mkdir $FolderLocation -force



("<html><head>") | out-file "$FolderLocation\\$strName.htm" -Encoding unicode
("<meta charset=utf-8 />") | out-file "$FolderLocation\\$strName.htm" -Encoding unicode -Append
#("<TITLE>Signature</TITLE>") | out-file "$FolderLocation\\$strName.htm" -Encoding unicode -Append
("</head>")  | out-file "$FolderLocation\\$strName.htm" -Encoding unicode -Append

("<body style=`"FONT-SIZE: 11pt; FONT-FAMILY: `'Arial`'`">") | out-file "$FolderLocation\\$strName.htm" -Encoding unicode -Append

#Name of Employee & Job Title 
("<hr/>")| out-file "$FolderLocation\\$strName.htm" -Encoding unicode -Append
("<div><b>З повагою</B></div>")  | out-file "$FolderLocation\\$strName.htm" -Encoding unicode -Append
("<div><b>$strName</B></div>")  | out-file "$FolderLocation\\$strName.htm" -Encoding unicode -Append
("<div>$strTitle</div>")  | out-file "$FolderLocation\\$strName.htm" -Encoding unicode -Append
("<div>$objdepartment</div>")  | out-file "$FolderLocation\\$strName.htm" -Encoding unicode -Append

#Company Name
("<div style='font-size:150%; font=weight:bold;'> Компанія $strCompany</div> ") | out-file "$FolderLocation\\$strName.htm" -Encoding unicode -Append


("<div style=""color: #595959;"">")| out-file "$FolderLocation\\$strName.htm" -Encoding unicode -Append
#Telephone Numbers
("<div><b>Мобільний: </b>$strmobile</div> ") | out-file "$FolderLocation\\$strName.htm" -Encoding unicode -Append
("<div><b>Внутрішній: </b>$strDirect</div> ") | out-file "$FolderLocation\\$strName.htm" -Encoding unicode -Append

#Email 
("<div style=`"FONT-SIZE: 12pt; `"><b>E-mail:</b><a href=`"mailto:"+ $strEmail +"`">" + $strEmail +"</a></div> ") | out-file "$FolderLocation\\$strName.htm" -Encoding unicode -Append
("</div> ") | out-file "$FolderLocation\\$strName.htm" -Encoding unicode -Append

#LOGO BANNER
("<div><a href=`"www.volia.com`"><IMG src=`"http://volia.com/user/img/logo/logo.png`"> ") | out-file "$FolderLocation\\$strName.htm" -Encoding unicode -Append
("</div></BODY></HTML> ") | out-file "$FolderLocation\\$strName.htm" -Encoding unicode -Append

#Open HTM Signature File 
$MSWord = New-Object -com word.application 
$fullPath = $FolderLocation+'\'+$strName+'.htm' 
$MSWord.Documents.Open($fullPath)

#Save HTM Signature File as RTF 
$saveFormat = [Enum]::Parse([Microsoft.Office.Interop.Word.WdSaveFormat], "wdFormatRTF"); 
$path = $FolderLocation+'\'+$strName+".rtf" 
$MSWord.ActiveDocument.SaveAs([ref] $path, [ref]$saveFormat)

#Close File 
$MSWord.ActiveDocument.Close() 
$MSWord.Quit()

#Forcing signature for new messages 
#Set company signature as default for New messages 
$MSWord = New-Object -com word.application 
$EmailOptions = $MSWord.EmailOptions 
$EmailSignature = $EmailOptions.EmailSignature 
$EmailSignatureEntries = $EmailSignature.EmailSignatureEntries 
$EmailSignature.NewMessageSignature=$StrName 
$MSWord.Quit()

#Forcing signature for reply/forward messages 
#Set company signature as default for Reply/Forward messages 
$MSWord = New-Object -com word.application 
$EmailOptions = $MSWord.EmailOptions 
$EmailSignature = $EmailOptions.EmailSignature 
$EmailSignatureEntries = $EmailSignature.EmailSignatureEntries 
$EmailSignature.ReplyMessageSignature=$StrName 
$MSWord.Quit() 
#############################################################
