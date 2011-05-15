package com.sibirjak.angara.monitor {

	import com.sibirjak.angara.core.ILoaderItem;
	import com.sibirjak.angara.core.IProgressInfo;

	/**
	 * A monitor encapsulates the progress calculation of a sequence of
	 * loader items.
	 * 
	 * <p>A monitor returns the overall progress of its containing loader
	 * items.</p>
	 * 
	 * <p>It is possible to add loader items cross over their assignment to
	 * the loader manager, to a sequence or a sequence manager.</p>
	 * 
	 * <p>The monitor listens to progress and complete events of its loader
	 * items and updates its internal progress information simultaneously.</p>
	 * 
	 * @author jes 13.02.2009
	 */
	public interface IMonitor extends IProgressInfo {

		/**
		 * Adds a loader item to a progress monitor.
		 * 
		 * <p>You can add any loader item type (resource loader, sequence,
		 * sequence manager).</p>
		 * 
		 * <p>If no weight parameter is given, the monitor uses the items.numItems
		 * property for the weight. Adding one resource loader and a sequence of
		 * 3 items would this way result in a cumulative weight of 4.
		 * Finishing the sequence would change the monitor's progress to .75 then.</p>
		 * 
		 * @param loaderItem The loader item to be monitored.
		 * @param weight The weight of the item within all monitor item's 
		 */
		function add(loaderItem : ILoaderItem, weight : uint = 0) : void;

		/**
		 * Removes a loader item from the progress monitor.
		 * 
		 * @param loaderItem The loader to be removed.
		 */
		function remove(loaderItem : ILoaderItem) : void;

		/**
		 * Removes all loader item references from the progress monitor.
		 */
		function clear() : void;

	}
}
