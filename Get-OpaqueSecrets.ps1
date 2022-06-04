function DecodeBase64String {
    param (
        [Parameter()]
        [String] $EncodedString
    )

    return [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($EncodedString))

}

function EncodeBase64String {
    param (
        [Parameter()]
        [String] $DecodedString
    )

    $Bytes = [System.Text.Encoding]::Unicode.GetBytes($DecodedString)
    return [Convert]::ToBase64String($Bytes)
}

function ParseSecretJson {
    param (
        [Parameter()]
        [String] $SecretJson
    )

    $returnval = @()

    
    $secrets.PSObject.Properties | ForEach-Object {
        #  $_.Name
        if ($_.Name -eq 'items') {
            $val = $_.Value
            foreach ($secret in $val) {

                if ($secret.type -eq 'Opaque') {

                    $obj = New-Object PSObject -Property @{
                        Namespace = $secret.metadata.namespace
                        Name      = $secret.metadata.name
                        Secrets   = @()
                    }

                    $secret.PSObject.Properties | ForEach-Object {
                        if ($_.Name -eq 'data') {
                            $val = $_.Value
                            $val.PSObject.Properties | ForEach-Object {
                                $secobj = New-Object PSObject -Property @{
                                    SecretName  = $_.Name
                                    SecretValue = DecodeBase64String($_.Value)
                                }
                                #"$($_.Name) -> $(DecodeBase64String($_.Value))"
                                $obj.Secrets += $secobj
                            }   
                        }
                    }
                
                    $returnval += $obj

                }
            }
        }
    }

    return $returnval
}

$secrets = kubectl get secrets -o json | ConvertFrom-Json
ParseSecretJson -SecretJson $secrets | Select-Object -ExpandProperty Secrets
