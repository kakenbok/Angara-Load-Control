package com.sibirjak.angara.sequence.testhelpers {

	import com.sibirjak.angara.sequence.Sequence;

	/**
	 * @author jes 05.05.2009
	 */
	public class SequenceMock extends Sequence {

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
