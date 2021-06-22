$version = (Get-AzTemplateSpec -Name "az-tempspec-vnetyyhub" -ResourceGroupName "gaag-rg-templates" -ErrorAction SilentlyContinue).Versions.Name
if($version){
    $minor = [int]$version.Split('.')[1]
    $major =
     [int]$version.Split('.')[0]
    $minor = $minor + 1
    if($minor -eq 9){
        $major = $major + 1
    }
    echo "::set-output name=versionnumber::$major.$minor"
}else{
    echo "::set-output name=versionnumber::0.1"
}
