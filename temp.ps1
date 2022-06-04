$secrets = kubectl get secrets -o json | ConvertFrom-Json
$secrets.PSObject.Properties | ForEach-Object {
    #  $_.Name
    if ($_.Name -eq 'items') {
        $val = $_.Value
        foreach ($secret in $val) {
            if ($secret.type -eq 'Opaque') {
                $secret.PSObject.Properties | ForEach-Object {
                    if ($_.Name -eq 'data') {
                        $val = $_.Value
                        $val.PSObject.Properties | ForEach-Object {
                            $_.Name
                            # DecodeBase64String($_.Value )
                        }
                    }
                }
            }
        }
    }
}