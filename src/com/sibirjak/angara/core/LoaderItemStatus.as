/*******************************************************************************
* The MIT License
* 
* Copyright (c) 2011 Jens Struwe.
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
******************************************************************************/
package com.sibirjak.angara.core {

	/**
	 * Defines the loader item stati.
	 * 
	 * @author jes 06.02.2009
	 */
	public class LoaderItemStatus {
		
		/**
		 * Item is ready to load.
		 * 
		 * <p>Defined by loader, sequence, sequence manager.</p>
		 */
		public static const WAITING : String = "item_waiting";

		/**
		 * Item is currently being loading.
		 * 
		 * <p>Defined only by resource loaders.</p>
		 */
		public static const LOADING : String = "item_loading";

		/**
		 * Item is paused and should be ignored by loader manager queue.
		 * 
		 * <p>Defined by loader, sequence, sequence manager.</p>
		 */
		public static const PAUSED : String = "item_paused";

		/**
		 * Item has been loaded completely.
		 * 
		 * <p>Defined by loader, sequence, sequence manager.</p>
		 */
		public static const COMPLETE : String = "item_complete";

		/**
		 * Item loading has been failed.
		 * 
		 * <p>Defined only by resource loaders.</p>
		 */
		public static const FAILURE : String = "item_failure";

	}
}
