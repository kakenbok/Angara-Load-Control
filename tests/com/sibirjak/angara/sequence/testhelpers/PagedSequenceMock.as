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
