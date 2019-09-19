$telephone_list = Get-ADUser -filter * -Properties displayname, Telephonenumber | Select-Object DisplayName, Telephonenumber

ForEach ($telephone in $telephone_list)
{
    if ($telephone.Telephonenumber -ne '')
    {
        $short_number = $telephone.Substring($telephone.length - 3)
        $final_short_number = '9' + $short_number
        $concat_value = $telephone.Displayname + ' ' + $final_short_number
        $concat_value | Export-Csv 'C:\phone_list.csv'
    }
}
