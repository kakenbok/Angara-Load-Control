package com.sibirjak.angara.sequence {

	/**
	 * Paged sequence event definition.
	 * 
	 * @author jes 11.05.2009
	 */
	public class PagedSequenceEvent extends SequenceEvent {

		/**
		 * Sequence range loaded.
		 */
		public static const PAGE_COMPLETE : String = "sequence_page_complete";

		/**
		 * Creates a new PagedSequenceEvent.
		 * 
		 * @param type Type of the event.
		 * @param resourceLoader Reference to the sequence.
		 */
		public function PagedSequenceEvent(type : String, sequence : ISequence) {
			super(type, sequence);
		}

	}
}
