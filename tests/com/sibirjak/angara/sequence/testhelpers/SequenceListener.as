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
