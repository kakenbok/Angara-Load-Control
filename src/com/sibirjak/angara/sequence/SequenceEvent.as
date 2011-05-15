package com.sibirjak.angara.sequence {

	import com.sibirjak.angara.core.LoaderItemEvent;
	import com.sibirjak.angara.resource.IResourceLoader;

	/**
	 * Sequence event definition.
	 * 
	 * @author jes 17.02.2009
	 */
	public class SequenceEvent extends LoaderItemEvent {

		/**
		 * A loader has been added.
		 */
		public static const ADD : String = LoaderItemEvent.ADD;

		/**
		 * A loader has been removed.
		 */
		public static const REMOVE : String = LoaderItemEvent.REMOVE;

		/**
		 * Progress of sequence has changed.
		 */
		public static const PROGRESS : String = LoaderItemEvent.PROGRESS;

		/**
		 * All containing loaders are finished (either complete or failed).
		 */
		public static const COMPLETE : String = LoaderItemEvent.COMPLETE;

		/**
		 * Sequence stopped.
		 */
		public static const STOP : String = LoaderItemEvent.STOP;

		/**
		 * Sequence paused.
		 */
		public static const PAUSE : String = LoaderItemEvent.PAUSE;

		/**
		 * Sequence or any containing loader resumed.
		 */
		public static const RESUME : String = LoaderItemEvent.RESUME;

		/**
		 * Creates a new SequenceEvent.
		 * 
		 * @param type Type of the event.
		 * @param sequence Reference to the sequence.
		 * @param resourceLoader The affected (added or removed) resource loader.

		 */
		public function SequenceEvent(type : String, sequence : ISequence, resourceLoader : IResourceLoader = null) {
			super(type, sequence, resourceLoader);
		}
		
		/**
		 * Returns the event dispatching sequence.
		 * 
		 * @return The event dispatching sequence.
		 */
		public function get sequence() : ISequence {
			return _loaderItem as ISequence;
		}

		/**
		 * Returns the added or removed resource Loader in case of ADD or REMOVE events.
		 * 
		 * @return The added or removed resource loader.
		 */
		public function get resourceLoader() : IResourceLoader {
			return _affectedLoaderItem as IResourceLoader;
		}
	}
}
