package com.sibirjak.utils {

	/**
	 * @author jes 11.02.2009
	 */
	public class ArrayUtils {

		/**
		 * Compares the values of 2 arrays using strictly equality
		 */

		public static function arraysEqual(array1 : Array, array2 : Array) : Boolean {
			var i : Number = array1.length;
			if (i != array2.length) {
				return false;
			}
			while (i--) {
				if (array1[i] !== array2[i]) {
					return false;
				}
			}
			return true;
		}

	}
}
