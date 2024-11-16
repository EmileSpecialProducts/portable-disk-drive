
################################################################################################################################
function ESPSPIFFSuploadfile() {
    param (
        [Parameter(Mandatory = $true)][String] $UploadURL, 
        [Parameter(Mandatory = $true)][String] $File, 
        [Parameter(Mandatory = $false)][String] $Destinaionfilename 
    )
    if ([string]::IsNullOrWhiteSpace($Destinaionfilename)) { $Destinaionfilename ="/$(Split-Path $File -leaf)" }    
    
    #write-host $UploadURL $File $Destinaionfilename
     try {
    $httpClientHandler = New-Object System.Net.Http.HttpClientHandler
    $httpClient = New-Object System.Net.Http.Httpclient $httpClientHandler

    $packageFileStream = New-Object System.IO.FileStream @($(Resolve-Path -Path $File) , [System.IO.FileMode]::Open)
        
    $contentDispositionHeaderValue = New-Object System.Net.Http.Headers.ContentDispositionHeaderValue "form-data"
    $contentDispositionHeaderValue.Name = "fileData"
    $contentDispositionHeaderValue.FileName = $Destinaionfilename #(Split-Path $path -leaf)
 
    $streamContent = New-Object System.Net.Http.StreamContent $packageFileStream
    $streamContent.Headers.ContentDisposition = $contentDispositionHeaderValue
    $streamContent.Headers.ContentType = New-Object System.Net.Http.Headers.MediaTypeHeaderValue "application/octet-stream"
        
    $content = New-Object System.Net.Http.MultipartFormDataContent
    $content.Add($streamContent)
   
        $response = $httpClient.PostAsync($UploadURL, $content).Result
        [System.Int32]$($response).StatusCode;
    }
    catch [Exception] {
        -1;     
    }
    if ($null -ne $httpClient) {
        $httpClient.Dispose()
    }

    if ($null -ne $response) {
        $response.Dispose()
    }
    if ($null -ne $packageFileStream) {
        $packageFileStream.Dispose()
    }
}
################################################################################################################################

$URI = "http://192.168.5.29"
ESPSPIFFSuploadfile "$URI/edit" 'ddd.png' '/test/d2.png'
Write-Host "responce = $a"
# create a test file 
"Testing $(get-date) " + [System.Guid]::NewGuid().ToString() > 'test.txt'
# Upload a file
ESPSPIFFSuploadfile "$URI/edit" 'test.txt' '/test2.txt'
# Dir 
Invoke-RestMethod -Uri "$URI/list?dir=/" -Method get
Invoke-RestMethod -Uri "$URI/test2.txt" -Method get
# Delete file
Invoke-RestMethod -Uri "$URI/test2.txt" -Method delete
# Dir /test 
Invoke-RestMethod -Uri "$URI/list?dir=/test" -Method get
Invoke-WebRequest -Uri "$URI/list?dir=/" -Method get
Invoke-RestMethod -Uri "$URI/edit?path=/test.txt" -Method delete
# Create dirctory
Invoke-RestMethod -Uri "$URI/edit?path=/test" -Method put
# create file
Invoke-RestMethod -Uri "$URI/edit?path=/test.txt" -Method put

ESPSPIFFSuploadfile "$URI/edit" 'SDWebServer\test.txt' '/test2.txt'


$File ="SDWebServer\test.txt"
$File = "test.txt"
$File = ".\SDWebServer\test.txt"
$(Resolve-Path -Path $File)

$packageFileStream = New-Object System.IO.FileStream @($(Resolve-Path -Path $File) , [System.IO.FileMode]::Open)
$packageFileStream.Dispose()

################################################################################################################################
# This will stop the ESP32 WebServer but the file is uploaded
################################################################################################################################
function NotWorking_ESPSPIFFSuploadfile() {
    param (
        [Parameter(Mandatory = $true)][String] $UploadURL, 
        [Parameter(Mandatory = $true)][String] $File, 
        [Parameter(Mandatory = $false)][String] $Destinaionfilename 
    )
    if ([string]::IsNullOrWhiteSpace($Destinaionfilename)) { $Destinaionfilename = "/$(Split-Path $File -leaf)" }     
    
    $FilePath = Get-Item -Path $File;
    $fileBytes = [System.IO.File]::ReadAllBytes($FilePath);
    $fileEnc = [System.Text.Encoding]::GetEncoding('iso-8859-1').GetString($fileBytes);
    $boundary = [System.Guid]::NewGuid().ToString(); 
    $EOL = "`r`n";

    $bodyLines = ( 
        "--$boundary",
        "Content-Disposition: form-data; name=`"data`"; filename=`"$Destinaionfilename`"",
        "Content-Type: application/octet-stream",
        "",
        $fileEnc,
        "--$boundary",
        "",
        "$EOL" 
    ) -join $EOL
    Invoke-RestMethod -Uri $UploadURL -Method Post -ContentType "multipart/form-data; boundary=`"$boundary`"" -Body $bodyLines 
}
################################################################################################################################
# This will stop the ESP32 WebServer but the file is uploaded
#NotWorking_ESPSPIFFSuploadfile "$URI/edit" 'test.txt' '/test2.txt'
