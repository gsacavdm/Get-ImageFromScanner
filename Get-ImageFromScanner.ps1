
function Get-ImageFromScanner(
    # Created using the following StackOverflow posts:
    # https://stackoverflow.com/questions/25371269/scan-automation-with-powershell-and-wia-how-to-set-png-as-image-type
    # https://stackoverflow.com/questions/2245675/set-page-size-using-wia-with-scanner

    [parameter(ValueFromPipeline=$true)]
    $FileName = "temp" + (Get-Date).ToString("hhmmss"),

    $Resolution = 150,
    $Quality = 95,

    $WidthPercent = 100,
    $HeightPercent = 100,

    #Letter
    $PageHeightInches = 11, # Max = 11.67 | Rotated Letter = (11 * 0.8484)
    $PageWidthInches = 8.5, # Already maxed out

    $OutputFolder = "C:\temp\"
    ) {


    $height = $PageHeightInches * ($heightPercent/100) * $resolution
    $width = $PageWidthInches * ($widthPercent/100) * $resolution
    
    $ErrorActionPreference = "Stop"

    $deviceManager = New-Object -ComObject WIA.DeviceManager
    $device = $deviceManager.DeviceInfos.Item(1).Connect()    

    #From: https://msdn.microsoft.com/en-us/library/windows/desktop/ms630810(v=vs.85).aspx
    $wiaFormat = "{B96B3CAE-0728-11D3-9D7B-0000F81EF32E}"
    $scanner = $device.Items.Item(1)

    $scanner.Properties.Item("Vertical Resolution").Value = "$resolution"
    $scanner.Properties.Item("Horizontal Resolution").Value = "$resolution"

    $scanner.Properties.Item("Vertical Extent").Value = "$height"
    $scanner.Properties.Item("Horizontal Extent").Value = "$width"

    $image = $scanner.Transfer($wiaFormat) 

    $imageProcess = New-Object -ComObject WIA.ImageProcess
    $imageProcess.Filters.Add($imageProcess.FilterInfos.Item("Convert").FilterID)
    $imageProcess.Filters.Item(1).Properties.Item("FormatID").Value = $wiaFormat 
    $imageProcess.Filters.Item(1).Properties.Item("Quality").Value = "$quality" 
    $image = $imageProcess.Apply($image)
    
    $image.SaveFile("$outputFolder$fileName.jpg")
}