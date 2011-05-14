package com.sibirjak.angara.core {
	import flash.events.EventDispatcher;

	/**
	 * Abstract implementation of the IProgressInfo interface.
	 * 
	 * @author jes 10.02.2009
	 */
	public class AbstractProgressInfo extends EventDispatcher implements IProgressInfo {

		/**
		 * The number of items added.
		 */
		protected var _numItems : uint = 0;

		/**
		 * The number of items alredy loaded.
		 */
		protected var _numItemsLoaded : uint = 0;

		/**
		 * The number of items failed loading.
		 */
		protected var _numItemsFailed : uint = 0;

		/**
		 * The overall progress of the item.
		 */
		protected var _progress : Number = 0;
		
		/*
		 * IProgressInfo
		 */

		/**
		 * @inheritDoc
		 */
		public function get numItems() : uint {
			return _numItems;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get numItemsLoaded() : uint {
			return _numItemsLoaded;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get numItemsFailed() : uint {
			return _numItemsFailed;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get progress() : Number {
			return _progress;
		}
		
	}

}
