package com.sibirjak.utils {

	/**
	 * @author jes 11.02.2009
	 */
	public class StringUtils {

		public static function strRepeat(string : String, multiplier : Number) : String {
	
			var repeatedString : String = "";
			for (var i : Number = 0; i < multiplier; i++) {
				repeatedString += string;
			}
			return repeatedString;
		}

	}
}
