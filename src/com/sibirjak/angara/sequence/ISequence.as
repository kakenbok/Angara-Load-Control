package com.sibirjak.angara.sequence {

	import com.sibirjak.angara.core.ILoaderItem;
	import com.sibirjak.angara.resource.IResourceLoader;
	import org.as3commons.collections.framework.IIterable;


	/**
	 * A sequence enables the controlling of a list of resource loaders.
	 * 
	 * <p>A sequence can be prioritised, added, removed, stopped, paused
	 * or resumed like ordinary loaders. A sequence is the best approach
	 * to load lists of display assets such as lists of thumbnails.</p>
	 * 
	 * <p>A sequence does not support the status LoaderItemStatus.FAILURE.
	 * A sequence instead will be marked as LoaderItemStatus.COMPLETE when all
	 * contained items are either COMPLETE or FAILURE.
	 * if (numItemsLoaded + numItemsFailed == numItems) => status = LoaderItemStatus.COMPLETE.</p>
	 * 
	 * @author jes 10.02.2009
	 */
	public interface ISequence extends ILoaderItem, IIterable {

		/**
		 * Adds a new resource loader to the sequence.
		 * 
		 * <p>Its possible to add resource at any time of loading to a sequence but
		 * not after the sequence has been marked as complete.</p>
		 * 
		 * @param resourceLoader The resource loader to add.
		 */
		function add(resourceLoader : IResourceLoader, weight : uint = 0) : void;

		/**
		 * Removes a loader from a sequence.
		 * 
		 * <p>This will decrease the number of items by 1 and adjust the sequence's
		 * progress value.</p>
		 *  
		 * @param resourceLoader The resource loader to remove.
		 */
		function remove(resourceLoader : IResourceLoader) : void;

		/**
		 * Stops all loaders and removes all loader references from the sequence.
		 */
		function clear() : void;
		
	}
}
