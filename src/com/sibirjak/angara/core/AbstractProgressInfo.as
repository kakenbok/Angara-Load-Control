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

	import flash.events.EventDispatcher;

	/**
	 * Abstract implementation of the IProgressInfo interface.
	 * 
	 * @author jes 10.02.2009
	 */
	public class AbstractProgressInfo extends EventDispatcher implements IProgressInfo {

		/**
		 * The number of items added.
		 */
		protected var _numItems : uint = 0;

		/**
		 * The number of items alredy loaded.
		 */
		protected var _numItemsLoaded : uint = 0;

		/**
		 * The number of items failed loading.
		 */
		protected var _numItemsFailed : uint = 0;

		/**
		 * The overall progress of the item.
		 */
		protected var _progress : Number = 0;
		
		/*
		 * IProgressInfo
		 */

		/**
		 * @inheritDoc
		 */
		public function get numItems() : uint {
			return _numItems;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get numItemsLoaded() : uint {
			return _numItemsLoaded;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get numItemsFailed() : uint {
			return _numItemsFailed;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get progress() : Number {
			return _progress;
		}
		
	}

}
