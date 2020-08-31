let formatForHeaders = (time) => {
	let tm = Unix.gmtime(time);
	let weekDay = switch(tm.tm_wday) {
		| 0 => "Sun"
		| 1 => "Mon"
		| 2 => "Tue"
		| 3 => "Wed"
		| 4 => "Thu"
		| 5 => "Fri"
		| 6 => "Sat"
		| _ => "Sun"
	};
	let month = switch(tm.tm_mon) {
		| 0 => "Jan"
		| 1 => "Feb"
		| 2 => "Mar"
		| 3 => "Apr"
		| 4 => "May"
		| 5 => "Jun"
		| 6 => "Jul"
		| 7 => "Aug"
		| 8 => "Sep"
		| 9 => "Oct"
		| 10 => "Nov"
		| 11 => "Dec"
		| _ => "Jan"
	};

	let day = switch(tm.tm_mday) {
		| mday when mday < 10 => "0" ++ string_of_int(mday)
		| mday => string_of_int(mday)
	};

	let hours = switch(tm.tm_hour) {
		| hr when hr < 10 => "0" ++ string_of_int(hr)
		| hr => string_of_int(hr);
	};

	let minutes = switch(tm.tm_min) {
		| min when min < 10 => "0" ++ string_of_int(min)
		| min => string_of_int(min)
	};

	let seconds = switch(tm.tm_sec) {
		| sec when sec < 10 => "0" ++ string_of_int(sec)
		| sec => string_of_int(sec)
	};

	weekDay ++ ", " ++ day ++ " " ++ month ++ " " ++ string_of_int(tm.tm_year + 1900) ++ " " ++ hours ++ ":" ++ minutes ++ ":" ++ seconds ++ " GMT";
}