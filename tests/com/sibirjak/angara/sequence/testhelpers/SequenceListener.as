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

	import com.sibirjak.angara.sequence.ISequence;
	import com.sibirjak.angara.sequence.SequenceEvent;

	/**
	 * @author jes 17.02.2009
	 */
	public class SequenceListener {
		
		private var _sequenceStoppedReceived : Boolean = false;
		private var _sequenceResumedReceived : Boolean = false;

		private var _sequenceCompleteReceived : Boolean = false;
		private var _sequenceProgressReceived : Boolean = false;

		public function SequenceListener(sequence : ISequence) {
			sequence.addEventListener(SequenceEvent.COMPLETE, sequenceCompleteHandler);
			sequence.addEventListener(SequenceEvent.PROGRESS, sequenceProgressHandler);

			sequence.addEventListener(SequenceEvent.PAUSE, sequenceStoppedHandler);
			sequence.addEventListener(SequenceEvent.RESUME, sequenceResumedHandler);
		}
		
		private function sequenceCompleteHandler(event : SequenceEvent) : void {
			_sequenceCompleteReceived = true;
		}
		
		private function sequenceProgressHandler(event : SequenceEvent) : void {
			_sequenceProgressReceived = true;
		}
		
		private function sequenceStoppedHandler(event : SequenceEvent) : void {
			_sequenceStoppedReceived = true;
		}

		private function sequenceResumedHandler(event : SequenceEvent) : void {
			_sequenceResumedReceived = true;
		}

		public function get sequenceCompleteReceived() : Boolean {
			var received : Boolean = _sequenceCompleteReceived;
			_sequenceCompleteReceived = false;
			return received;
		}
		
		public function get sequenceProgressReceived() : Boolean {
			var received : Boolean = _sequenceProgressReceived;
			_sequenceProgressReceived = false;
			return received;
		}
		
		public function get sequenceStoppedReceived() : Boolean {
			var received : Boolean = _sequenceStoppedReceived;
			_sequenceStoppedReceived = false;
			return received;
		}
		
		public function get sequenceResumedReceived() : Boolean {
			var received : Boolean = _sequenceResumedReceived;
			_sequenceResumedReceived = false;
			return received;
		}
		
	}
}
