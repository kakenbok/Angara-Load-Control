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
	 * Abstract implementation of the ILoaderItem interface.
	 * 
	 * @author jes 30.04.2009
	 */
	public class AbstractLoaderItem extends AbstractProgressInfo implements ILoaderItem {

		/**
		 * The loader item type.
		 */
		protected var _type : String;

		/**
		 * The key used for debugging purposes.
		 */
		protected var _key : String;

		/**
		 * The loader item status.
		 */
		protected var _status : String;

		/**
		 * The schedule marker.
		 */
		protected var _isScheduled : Boolean = false;

		/*
		 * ILoaderItem
		 */

		/**
		 * @inheritDoc
		 */
		public function get itemType() : String {
			return _type;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set key(key : String) : void {
			_key = key;
		}

		/**
		 * @inheritDoc
		 */
		public function get key() : String {
			return _key;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get scheduled() : Boolean {
			return _isScheduled;
		}

		/**
		 * @inheritDoc
		 */
		public function get status() : String {
			return _status;
		}
		
		/**
		 * @inheritDoc
		 * 
		 * <p>This method must be implemented by each subclass independently.</p>
		 */
		public function stop() : void {
			// hook
		}
		
		/**
		 * @inheritDoc
		 * 
		 * <p>This method must be implemented by each subclass independently.</p>
		 */
		public function pause() : void {
			// hook
		}
		
		/**
		 * @inheritDoc
		 * 
		 * <p>This method must be implemented by each subclass independently.</p>
		 */
		public function resume() : void {
			// hook
		}

		/*
		 * sibirjak_loader
		 */

		/**
		 * Framework internal method to modify a loader item status
		 * crossover the class visibility.
		 */
		sibirjak_loader function setScheduled(scheduled : Boolean) : void {
			_isScheduled = scheduled;
		}
		
	}
}
