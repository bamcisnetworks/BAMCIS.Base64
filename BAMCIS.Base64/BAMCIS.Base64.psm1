Function Invoke-Base64UrlEscape {
	<#
		.SYNOPSIS
			Performs character escaping on a string that is already base64 encoded.

		.DESCRIPTION
			This cmdlet takes an input and escapes url characters, changing + to - and / to _. The specified
			padding character is also removed from the end.

		.PARAMETER InputObject
			The base64 string to escape.

		.PARAMETER Padding
			The trailing padding character to remove. This defaults to '='.

		.EXAMPLE
			$Base64Str = "SGVsbG8gV29y/bGQhIEhlbG+xvIQ=="
			$EscapedStr = $Base64Str | Invoke-Base64UrlEscape

			The escaped string will be "SGVsbG8gV29y_bGQhIEhlbG-xvIQ".

		.INPUTS
			System.String

		.OUTPUTS
			System.String

		.NOTES
            AUTHOR: Michael Haken
			LAST UPDATE: 1/27/2018
	#>
	[CmdletBinding()]
	[OutputType([System.String])]
	Param(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[System.String]$InputObject,

		[Parameter()]
		[ValidateNotNull()]
		[System.Char]$Padding = '='
	)

	Begin {
	}

	Process {
		Write-Output -InputObject $InputObject.TrimEnd($Padding).Replace('+', '-').Replace('/', '_')
	}

	End {
	}
}

Function Invoke-Base64UrlUnescape {
	<#
		.SYNOPSIS
			Performs character unescaping on a string that is already base64 encoded and has already been escaped.

		.DESCRIPTION
			This cmdlet takes an input and unescapes url characters, changing - to + and _ to /. The appropriate amount
			of trailing padding is also added back.

		.PARAMETER InputObject
			The base64 string to unescape.

		.PARAMETER Padding
			The character that will be used for any necessary trailing padding. This defaults to '='.

		.EXAMPLE
			$EscapedStr = "SGVsbG8gV29y_bGQhIEhlbG-xvIQ"
			$Base64Str = $EscapedStr | Invoke-Base64UrlUnescape

			The escaped string will be "SGVsbG8gV29y/bGQhIEhlbG+xvIQ==".

		.INPUTS
			System.String

		.OUTPUTS
			System.String

		.NOTES
            AUTHOR: Michael Haken
			LAST UPDATE: 1/27/2018
	#>
	[CmdletBinding()]
	[OutputType([System.String])]
	Param(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[System.String]$InputObject,

		[Parameter()]
		[ValidateNotNull()]
		[System.Char]$Padding = '='
	)

	Begin {
	}

	Process {
		$InputObject = $InputObject.Replace('-', '+').Replace('_', '/')

		switch ($InputObject.Length % 4) {
			0 {
				# No padding should be added
				break
			}
			2 {
				$InputObject += "$Padding$Padding"
				break
			}
			3 {
				$InputObject += $Padding
				break
			}
			default {
				Write-Error -Exception (New-Object -TypeName System.ArgumentException("InputObject", "The input object is not a legal base64 string.")) -ErrorAction Stop
			}
		}

		Write-Output -InputObject $InputObject
	}

	End {
	}
}

Function ConvertTo-Base64UrlEncoding {
	<#
		.SYNOPSIS
			Converts a plain text string or bytes to a base64 url encoded string.

		.DESCRIPTION
			This cmdlet takes a string or a byte array and converts it to a base64 url encoded string. If a string
			is provided, you can specify the encoding to use to convert it to bytes, this defaults to UTF8.

		.PARAMETER InputObject
			The string to convert to a base64 url encoded string.

		.PARAMETER Bytes
			The bytes to convert to a base64 url encoded string.

		.PARAMETER Encoding
			The encoding to use to convert the InputObject parameter to a byte array. This defaults
			to UTF8.

		.PARAMETER Padding
			The character used as padding for the end of the base64 string before escaping, this defaults to '='.

		.EXAMPLE
			$Str = "Hello World!"
			$Base64UrlStr = $Str | ConvertTo-Base64UrlEncoding

			This converts the input string to a base64 url encoded string.

		.INPUTS
			System.String

		.OUTPUTS
			System.String

		.NOTES
            AUTHOR: Michael Haken
			LAST UPDATE: 1/27/2018
	#>
	[CmdletBinding()]
	[OutputType([System.String])]
	Param(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ParameterSetName = "Input")]
		[AllowEmptyString()]
		[System.String]$InputObject,

		[Parameter(Mandatory = $true, Position = 0, ParameterSetName = "Bytes")]
		[ValidateNotNull()]
		[System.Byte[]]$Bytes,

		[Parameter(ParameterSetName = "Input")]
		[ValidateNotNull()]
		[System.Text.Encoding]$Encoding = [System.Text.Encoding]::UTF8,

		[Parameter()]
		[ValidateNotNull()]
		[System.Char]$Padding = '='
	)

	Begin {
	}

	Process {
		if ($PSCmdlet.ParameterSetName -eq "Input")
		{
			$Bytes = $Encoding.GetBytes($InputObject)
		}

		$Temp = [System.Convert]::ToBase64String($Bytes)
		$Temp = Invoke-Base64UrlEscape -InputObject $Temp -Padding $Padding

		Write-Output -InputObject $Temp
	}

	End {
	}
}

Function ConvertFrom-Base64UrlEncoding {
	<#
		.SYNOPSIS
			Converts a base64 url encoded string back to a plain text string or bytes.

		.DESCRIPTION
			This cmdlet takes a base64 url encoded string and converts it back to a plain text
			string or a byte array.

		.PARAMETER InputObject
			The string to convert from a base64 url encoded string.

		.PARAMETER AsBytes
			Specifies that the output is returned as a byte array instead of a string.

		.PARAMETER Encoding
			The encoding to use to convert the base64 url encoded string back to a plain text string. This defaults
			to UTF8.

		.PARAMETER Padding
			The character used as padding for the end of the base64 string before escaping, this defaults to '='.

		.EXAMPLE
			$EscapedStr = "SGVsbG8gV29y_bGQhIEhlbG-xvIQ"
			$PlainText = $EscapedStr | ConvertFrom-Base64UrlEncoding

			This converts the input string back to a plain text string.

		.EXAMPLE
			$EscapedStr = "SGVsbG8gV29y_bGQhIEhlbG-xvIQ"
			$Bytes = $EscapedStr | ConvertFrom-Base64UrlEncoding -AsBytes

			This converts the input string back to a decoded byte array.

		.INPUTS
			System.String

		.OUTPUTS
			System.String

		.NOTES
            AUTHOR: Michael Haken
			LAST UPDATE: 1/27/2018
	#>
	[CmdletBinding()]
	[OutputType([System.String])]
	Param(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[AllowEmptyString()]
		[System.String]$InputObject,

		[Parameter()]
		[Switch]$AsBytes,

		[Parameter()]
		[ValidateNotNull()]
		[System.Text.Encoding]$Encoding = [System.Text.Encoding]::UTF8,

		[Parameter()]
		[ValidateNotNull()]
		[System.Char]$Padding = '='
	)

	Begin {
	}

	Process {
		$InputObject = Invoke-Base64UrlUnescape -InputObject $InputObject -Padding $Padding

		[System.Byte[]]$Bytes = [System.Convert]::FromBase64String($InputObject)

		if ($AsBytes)
		{
			Write-Output -InputObject $Bytes
		}
		else
		{
			Write-Output -InputObject $Encoding.GetString($Bytes)
		}
	}

	End {
	}
}