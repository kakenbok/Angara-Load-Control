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
