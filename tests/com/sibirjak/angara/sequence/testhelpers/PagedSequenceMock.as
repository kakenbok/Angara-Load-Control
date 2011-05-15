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
package com.sibirjak.angara.sequence.testhelpers {

	import com.sibirjak.angara.sequence.PagedSequence;

	import org.as3commons.collections.framework.IIterator;


	/**
	 * @author jes 05.05.2009
	 */
	public class PagedSequenceMock extends PagedSequence {

		/*
		 * Iterator
		 */

		override public function iterator(cursor : * = undefined) : IIterator {
			return super.getResourceLoaderIterator(cursor);
		}

		/*
		 * Sequence status manipulation
		 */

		public function setStatus(status : String) : void {
			_status = status;
		}

		public function setNumItemsLoaded(numItemsLoaded : uint) : void {
			_numItemsLoaded = numItemsLoaded;
		}

		public function setProgress(progress : Number) : void {
			_progress = progress;
		}
		
		public function dispatchCompleteMock() : void {
			dispatchComplete();
		}

		public function dispatchProgressMock() : void {
			dispatchProgress();
		}

	}
}
