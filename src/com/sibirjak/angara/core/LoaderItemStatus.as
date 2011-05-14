package com.sibirjak.angara.core {

	/**
	 * Defines the loader item stati.
	 * 
	 * @author jes 06.02.2009
	 */
	public class LoaderItemStatus {
		
		/**
		 * Item is ready to load.
		 * 
		 * <p>Defined by loader, sequence, sequence manager.</p>
		 */
		public static const WAITING : String = "item_waiting";

		/**
		 * Item is currently being loading.
		 * 
		 * <p>Defined only by resource loaders.</p>
		 */
		public static const LOADING : String = "item_loading";

		/**
		 * Item is paused and should be ignored by loader manager queue.
		 * 
		 * <p>Defined by loader, sequence, sequence manager.</p>
		 */
		public static const PAUSED : String = "item_paused";

		/**
		 * Item has been loaded completely.
		 * 
		 * <p>Defined by loader, sequence, sequence manager.</p>
		 */
		public static const COMPLETE : String = "item_complete";

		/**
		 * Item loading has been failed.
		 * 
		 * <p>Defined only by resource loaders.</p>
		 */
		public static const FAILURE : String = "item_failure";

	}
}
