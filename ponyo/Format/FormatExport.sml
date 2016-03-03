structure FormatExport =
struct
    local structure String = StringExport in

    type t = {str: unit -> string}

    val formatVariable : string ref = ref "%"

    fun make (fmt: unit -> string) : t =
	{str=fmt}

    fun int (i: int) : t =
	make (fn () => Int.toString (i))

    fun str (s: string) : t =
	make (fn () => s)

    val last = make (fn () => "")

    val null = {1=last}

    fun sprintf (fmt: string) record accessors : string =
	let
	    val formatVariable = !formatVariable

	    fun isEscape (index: int) : bool =
		String.length (fmt) > index + 1 andalso
		String.hasPrefix (String.substringToEnd (fmt, index + 1), formatVariable)

	    fun sprintfNext (index: int, accessors) : string =
		sprintf (String.substringToEnd (fmt, index)) record accessors

	    fun escapedLength (start: int) : int =
		start + 2 * (String.length formatVariable)

	    fun replaceAndContinue (index: int) : string =
		let
		    val (replacement, accessors) = case accessors of
		        [] => (formatVariable, [])
		      | hd :: tl => (#str ((hd record): t) (), tl)

                    val offset = index + String.length (formatVariable)
		in
		    replacement ^ sprintfNext (offset, accessors)
		end
	in
	    case String.indexOf (fmt, formatVariable) of
	        ~1 => fmt
	       | i => String.substring (fmt, 0, i) ^
	           (if isEscape (i)
		        then formatVariable ^ sprintfNext (escapedLength (i), accessors)
                    else
		        replaceAndContinue (i))
	end

    fun printf (fmt: string) record accessors : unit =
	print (sprintf fmt record accessors)

    fun sprintln record accessors : string =
	let
	    val fmtVar = !formatVariable
	    val len = length accessors
	    fun mkFmt (i: int, fmt: string) =
		case i of
		    0 => fmt
		| i => mkFmt (i - 1, fmt ^ (if i < len then " " else "") ^ fmtVar)

	    val fmt = if len = 0 then "" else mkFmt (len - 1, fmtVar) ^ "\n"
	in
	    sprintf fmt record accessors
	end

    fun println record accessors : unit =
	print (sprintln record accessors)

    end
end
