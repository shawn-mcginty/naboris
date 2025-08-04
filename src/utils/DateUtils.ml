let formatForHeaders time =
	let tm = Unix.gmtime time in
	let weekDay = match tm.tm_wday with
		| 0 -> "Sun"
		| 1 -> "Mon"
		| 2 -> "Tue"
		| 3 -> "Wed"
		| 4 -> "Thu"
		| 5 -> "Fri"
		| 6 -> "Sat"
		| _ -> "Sun"
	in
	let month = match tm.tm_mon with
		| 0 -> "Jan"
		| 1 -> "Feb"
		| 2 -> "Mar"
		| 3 -> "Apr"
		| 4 -> "May"
		| 5 -> "Jun"
		| 6 -> "Jul"
		| 7 -> "Aug"
		| 8 -> "Sep"
		| 9 -> "Oct"
		| 10 -> "Nov"
		| 11 -> "Dec"
		| _ -> "Jan"
	in

	let day = match tm.tm_mday with
		| mday when mday < 10 -> "0" ^ string_of_int mday
		| mday -> string_of_int mday
	in

	let hours = match tm.tm_hour with
		| hr when hr < 10 -> "0" ^ string_of_int hr
		| hr -> string_of_int hr
	in

	let minutes = match tm.tm_min with
		| min when min < 10 -> "0" ^ string_of_int min
		| min -> string_of_int min
	in

	let seconds = match tm.tm_sec with
		| sec when sec < 10 -> "0" ^ string_of_int sec
		| sec -> string_of_int sec
	in

	weekDay ^ ", " ^ day ^ " " ^ month ^ " " ^ string_of_int (tm.tm_year + 1900) ^ " " ^ hours ^ ":" ^ minutes ^ ":" ^ seconds ^ " GMT" 