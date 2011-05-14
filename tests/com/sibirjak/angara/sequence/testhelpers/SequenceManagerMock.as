package com.sibirjak.angara.sequence.testhelpers {
	import com.sibirjak.angara.sequence.SequenceManager;

	/**
	 * @author jes 14.05.2009
	 */
	public class SequenceManagerMock extends SequenceManager {

		public function setStatus(status : String) : void {
			_status = status;
		}

		public function dispatchCompleteMock() : void {
			dispatchComplete();
		}

	}
}
