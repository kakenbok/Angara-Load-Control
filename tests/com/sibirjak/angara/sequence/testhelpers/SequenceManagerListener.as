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

	import com.sibirjak.angara.core.LoaderItemEvent;
	import com.sibirjak.angara.sequence.ISequenceManager;

	/**
	 * @author jes 17.02.2009
	 */
	public class SequenceManagerListener {
		
		private var _sequenceManagerStoppedReceived : Boolean = false;
		private var _sequenceManagerResumedReceived : Boolean = false;

		private var _sequenceManagerCompleteReceived : Boolean = false;

		public function SequenceManagerListener(sequenceManager : ISequenceManager) {
			sequenceManager.addEventListener(LoaderItemEvent.COMPLETE, sequenceManagerCompleteHandler);

			sequenceManager.addEventListener(LoaderItemEvent.PAUSE, sequenceManagerStoppedHandler);
			sequenceManager.addEventListener(LoaderItemEvent.RESUME, sequenceManagerResumedHandler);
		}
		
		private function sequenceManagerCompleteHandler(event : LoaderItemEvent) : void {
			_sequenceManagerCompleteReceived = true;
		}
		
		private function sequenceManagerStoppedHandler(event : LoaderItemEvent) : void {
			_sequenceManagerStoppedReceived = true;
		}

		private function sequenceManagerResumedHandler(event : LoaderItemEvent) : void {
			_sequenceManagerResumedReceived = true;
		}

		public function get sequenceManagerCompleteReceived() : Boolean {
			var received : Boolean = _sequenceManagerCompleteReceived;
			_sequenceManagerCompleteReceived = false;
			return received;
		}
		
		public function get sequenceManagerStoppedReceived() : Boolean {
			var received : Boolean = _sequenceManagerStoppedReceived;
			_sequenceManagerStoppedReceived = false;
			return received;
		}
		
		public function get sequenceManagerResumedReceived() : Boolean {
			var received : Boolean = _sequenceManagerResumedReceived;
			_sequenceManagerResumedReceived = false;
			return received;
		}
		
	}
}
