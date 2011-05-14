package com.sibirjak.angara.core {

	/**
	 * Abstract implementation of the ILoaderItem interface.
	 * 
	 * @author jes 30.04.2009
	 */
	public class AbstractLoaderItem extends AbstractProgressInfo implements ILoaderItem {

		/**
		 * The loader item type.
		 */
		protected var _type : String;

		/**
		 * The key used for debugging purposes.
		 */
		protected var _key : String;

		/**
		 * The loader item status.
		 */
		protected var _status : String;

		/**
		 * The schedule marker.
		 */
		protected var _isScheduled : Boolean = false;

		/*
		 * ILoaderItem
		 */

		/**
		 * @inheritDoc
		 */
		public function get itemType() : String {
			return _type;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set key(key : String) : void {
			_key = key;
		}

		/**
		 * @inheritDoc
		 */
		public function get key() : String {
			return _key;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get scheduled() : Boolean {
			return _isScheduled;
		}

		/**
		 * @inheritDoc
		 */
		public function get status() : String {
			return _status;
		}
		
		/**
		 * @inheritDoc
		 * 
		 * <p>This method must be implemented by each subclass independently.</p>
		 */
		public function stop() : void {
			// hook
		}
		
		/**
		 * @inheritDoc
		 * 
		 * <p>This method must be implemented by each subclass independently.</p>
		 */
		public function pause() : void {
			// hook
		}
		
		/**
		 * @inheritDoc
		 * 
		 * <p>This method must be implemented by each subclass independently.</p>
		 */
		public function resume() : void {
			// hook
		}

		/*
		 * sibirjak_loader
		 */

		/**
		 * Framework internal method to modify a loader item status
		 * crossover the class visibility.
		 */
		sibirjak_loader function setScheduled(scheduled : Boolean) : void {
			_isScheduled = scheduled;
		}
		
	}
}
