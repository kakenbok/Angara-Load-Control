package com.sibirjak.angara.sequence {
	import com.sibirjak.angara.core.LoaderItemEvent;

	/**
	 * Sequence event definition.
	 * 
	 * @author jes 17.02.2009
	 */
	public class SequenceManagerEvent extends LoaderItemEvent {

		/**
		 * A sequence has been added.
		 */
		public static const ADD : String = LoaderItemEvent.ADD;

		/**
		 * A sequence has been removed.
		 */
		public static const REMOVE : String = LoaderItemEvent.REMOVE;

		/**
		 * Progress of sequence manager has changed.
		 */
		public static const PROGRESS : String = LoaderItemEvent.PROGRESS;

		/**
		 * All containing sequences are completed.
		 */
		public static const COMPLETE : String = LoaderItemEvent.COMPLETE;

		/**
		 * Sequence manager stopped.
		 */
		public static const STOP : String = LoaderItemEvent.STOP;

		/**
		 * Sequence manager paused.
		 */
		public static const PAUSE : String = LoaderItemEvent.PAUSE;

		/**
		 * Sequence or any containing sequence resumed.
		 */
		public static const RESUME : String = LoaderItemEvent.RESUME;

		/**
		 * Creates a new SequenceManagerEvent.
		 * 
		 * @param type Type of the event.
		 * @param sequenceManager Reference to the sequence manager.
		 * @param sequence The affected (added or removed) sequence.
		 */
		public function SequenceManagerEvent(type : String, sequenceManager : ISequenceManager, sequence : ISequence = null) {
			super(type, sequenceManager, sequence);
		}
		
		/**
		 * Returns the event dispatching sequence managaer.
		 * 
		 * @return The event dispatching sequence manager.
		 */
		public function get sequenceManager() : ISequenceManager {
			return _loaderItem as ISequenceManager;
		}

		/**
		 * Returns the added or removed sequence in case of ADD or REMOVE events.
		 * 
		 * @return The added or removed sequence.
		 */
		public function get sequence() : ISequence {
			return _affectedLoaderItem as ISequence;
		}
	}
}
