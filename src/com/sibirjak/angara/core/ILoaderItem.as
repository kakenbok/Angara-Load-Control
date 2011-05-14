package com.sibirjak.angara.core {

	/**
	 * The internal loader item type. A loader item can be either a
	 * resource loader, a sequence or a sequence manager.
	 * 
	 * <p>A loader item can be added or removed from the loader manager,
	 * provides information about its loading status and progress and
	 * offers operations to stop and resume loading.</p>
	 *    
	 * @author jes 12.02.2009
	 */
	public interface ILoaderItem extends IProgressInfo {
		
		/**
		 * The type of the loader item.
		 * 
		 * <p>The type can be either LoaderItemType.LOADER, LoaderItemType.SEQUENCE
		 * or LoaderItemType.SEQUENCE_MANAGER.</p>
		 * 
		 * <p>A loader item is supposed to dispatch an event if it should be removed
		 * from the loader manager queue (LoaderItemEvent.COMPLETE, LoaderItemEvent.FAILURE)
		 * and an event to notify the loader manager to continue loading
		 * (LoaderItemEvent.RESUME).</p>
		 * 
		 * @return The type of the loader item.
		 */
		function get itemType() : String;
		
		/**
		 * Sets a identifying key for the loader item.
		 * 
		 * <p>The key is used for debugging purposes</p>
		 * 
		 * @param key The key of the loader item.
		 */
		function set key(key : String) : void;

		/**
		 * Returns the identifying key of the loader item.
		 * 
		 * @return Key of the loader item.
		 */
		function get key() : String;

		/**
		 * Returns true, if the item already has been added to the loader manager
		 * directly or to a sequence or a sequence manager.
		 * 
		 * <p>A scheduled item cannot be added twice to any of the loader item
		 * containers (loader manager, sequence, sequence manager). It has to be
		 * removed from its current container beforehand.</p>
		 * 
		 * @return true, if the item is already scheduled directly or added
		 * to a sequence or a sequence manager.  
		 */
		function get scheduled() : Boolean;
		
		/**
		 * The current loading status.
		 * 
		 * <p>The initial status is LoaderItemStatus.WAITING for every loader
		 * item instance. Once the status is set to LoaderItemStatus.COMPLETE
		 * or LoaderItemStatus.FAILURE, the status won't be changed any more.</p>
		 * 
		 * @return The current loading status.
		 */
		function get status() : String;

		/**
		 * Immediately stops loading of the item or its containing items.
		 * 
		 * <p>If the item is of type LoaderItemType.LOADER and is currently being
		 * loading, the associated net connection will be closed. Does only have effect
		 * to resource loaders, which status is LoaderItemStatus.LOADING. Sets the loader
		 * status back to LoaderItemStatus.WAITING. You cannot stop finished loaders
		 * (LoaderItemStatus.COMPLETE, LoaderItemStatus.FAILURE) any more.</p>
		 * 
		 * <p>If the item is of type LoaderItemType.SEQUENCE, all open loaders
		 * assigned to the seqeunce will be stopped.</p>
		 * 
		 * <p>If the item is of type LoaderItemType.SEQUENCE_MANAGER, the stop
		 * method of all assigned sequences will be called.</p>
		 */
		function stop() : void;

		/**
		 * Marks the item to be ignored by subsequent loader manager queue pulling operations.
		 * 
		 * <p>Sets the items status to LoaderItemStatus.PAUSED. Does only have effect to items
		 * which status is LoaderItemStatus.WAITING. You cannot pause a loading or finished item.
		 * To interrupt loading you need to call stop() for the particular item.</p>
		 * 
		 * <p>If the item is of type LoaderItemType.SEQUENCE, only the sequence will be marked
		 * as paused.</p>
		 * 
		 * <p>If the item is of type LoaderItemType.SEQUENCE_MANAGER, only the sequence manager
		 * will be marked as paused.</p>
		 */
		function pause() : void;

		/**
		 * Marks a prior paused item to be eligible for loader manager queue polling
		 * operations.
		 * 
		 * <p>Sets the items status to LoaderItemStatus.WAITING. Does only have effect to items
		 * which status is LoaderItemStatus.PAUSED.</p>
		 * 
		 * <p>If the item is of type LoaderItemType.SEQUENCE, only the sequence's status will be
		 * affected.</p>
		 * 
		 * <p>If the item is of type LoaderItemType.SEQUENCE_MANAGER, only the sequence manager's
		 * status will be affected.</p>
		 */
		function resume() : void;

	}
}
