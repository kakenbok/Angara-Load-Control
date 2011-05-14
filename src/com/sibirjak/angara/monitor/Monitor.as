package com.sibirjak.angara.monitor {

	import com.sibirjak.angara.core.AbstractProgressInfo;
	import com.sibirjak.angara.core.ILoaderItem;
	import com.sibirjak.angara.core.LoaderItemEvent;
	import org.as3commons.collections.Map;
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.framework.IMap;


	/**
	 * The monitor takes care of the loading progess of a list of loader items.
	 * 
	 * <p>The monitor holds an internal map to track the progress of its added
	 * loader item objects. The progress will be calculated incrementally to
	 * achieve the best possible performance. In order to do so, the monitor
	 * calculates the differences between two states of a loader item and adds
	 * this difference to the overall progress properties.</p>
	 * 
	 * <p>Generally the overall progress is the arithmetic average of all items
	 * added. It is though possible to give each element a specific weight.
	 * This can be useful for displaying a progress bar respecting the different
	 * sizes of the particular resources.</p>
	 * 
	 * <p>Adding a sequence uses its numItems property to calculate the weight
	 * of the sequence within the monitor. So adding one resource loader and a
	 * sequence of 3 items would this way result in a cumulative weight of 4.
	 * Finishing the sequence would change the monitor's progress to .75 then.</p>
	 * 
	 * <p>Sequences uses an internal monitor to calculate the sequence progress.</p>
	 * 
	 * @author jes 13.02.2009
	 */
	public class Monitor extends AbstractProgressInfo implements IMonitor {
		
		/**
		 * Internal map to keep track of progress.
		 */
		private var _watchedItems : IMap;
		
		/*
		 * this may change
		 * - if a loader has been added
		 * - if a sequence has been added
		 * - if a loader has been removed from a sequence
		 * - if a loader has been added to an already added sequence
		 * 
		 */
		private var _sumWeights : uint = 0;
		
		/**
		 * Creates a new monitor.
		 */
		public function Monitor() {
			_watchedItems = new Map();
		}
		
		/*
		 * IMonitor
		 */

		/**
		 * @inheritDoc
		 */
		public function add(loaderItem : ILoaderItem, weight : uint = 0) : void {
			// do not allow adding the same sequence multiple times
			if (_watchedItems.hasKey(loaderItem)) return;
			
			_numItems += loaderItem.numItems;
			_numItemsLoaded += loaderItem.numItemsLoaded;
			_numItemsFailed += loaderItem.numItemsFailed;

			var monitorItemUpdateInfo : MonitorItemUpdateInfo = watchItem(
				loaderItem,
				weight,
				loaderItem.numItems,
				loaderItem.numItemsLoaded,
				loaderItem.numItemsFailed,
				loaderItem.progress
			);

			_progress = incrementProgress(monitorItemUpdateInfo);

			dispatchProgress();

			// regisiter for monitor events
			configureListeners(loaderItem);
		}

		/**
		 * @inheritDoc
		 */
		public function remove(loaderItem : ILoaderItem) : void {
			if (!_watchedItems.hasKey(loaderItem)) return;

			// unregister event listener
			deconfigureListeners(loaderItem);

			var monitorItemUpdateInfo : MonitorItemUpdateInfo = updateItem(
				loaderItem,
				0,
				0,
				0,
				0
			);
			// reset weight to be considered in progress calculation
			monitorItemUpdateInfo.monitorItem.weight = 0;

			_progress = incrementProgress(monitorItemUpdateInfo);
			
			// update progress info
			_numItems -= loaderItem.numItems;
			_numItemsLoaded -= loaderItem.numItemsLoaded;
			_numItemsFailed -= loaderItem.numItemsFailed;

			// remove sequence from monitor
			_watchedItems.removeKey(loaderItem);
			
			dispatchProgress();
		}

		/**
		 * @inheritDoc
		 */
		public function clear() : void {
			var iterator : IIterator = _watchedItems.iterator();
			var monitorItem : MonitorItem;
			while (iterator.hasNext()) {
				monitorItem = iterator.next();
				deconfigureListeners(monitorItem.loaderItem);
			}
			_watchedItems.clear();

			_numItems = 0;
			_numItemsLoaded = 0;
			_numItemsFailed = 0;
			_progress = 0;

			_sumWeights = 0;
		}

		/**
		 * Info
		 */
		override public function toString() : String {
			return "[Monitor] items:" + _numItems + " loaded:" + _numItemsLoaded + " failed:" + _numItemsFailed + " progress:" + _progress;
		}

		/*
		 * Item listeners
		 */

		/**
		 * Starts listening to loader item progess notifications.
		 */
		private function configureListeners(loaderItem : ILoaderItem) : void {
			loaderItem.addEventListener(LoaderItemEvent.STOP, itemProgressHandler);
			loaderItem.addEventListener(LoaderItemEvent.PROGRESS, itemProgressHandler);
			loaderItem.addEventListener(LoaderItemEvent.COMPLETE, itemFinishedHandler);
			loaderItem.addEventListener(LoaderItemEvent.FAILURE, itemFinishedHandler);
		}
		
		/**
		 * Stops listening to loader item progess notifications.
		 */
		private function deconfigureListeners(loaderItem : ILoaderItem) : void {
			loaderItem.removeEventListener(LoaderItemEvent.STOP, itemProgressHandler);
			loaderItem.removeEventListener(LoaderItemEvent.PROGRESS, itemProgressHandler);
			loaderItem.removeEventListener(LoaderItemEvent.COMPLETE, itemFinishedHandler);
			loaderItem.removeEventListener(LoaderItemEvent.FAILURE, itemFinishedHandler);
		}
		
		/**
		 * Item progress handler.
		 */
		private function itemProgressHandler(event : LoaderItemEvent) : void {
			//trace ("progress " + event.loaderItem + " " + event);
			updateProgress(event.loaderItem);
		}

		/**
		 * Handler for item finish events
		 */
		private function itemFinishedHandler(event : LoaderItemEvent) : void {
			deconfigureListeners(event.loaderItem);
			updateProgress(event.loaderItem);
			
			if (checkMonitorComplete()) dispatchMonitorComplete();
		}

		/*
		 * Private
		 */

		/**
		 * Updates the progress by a given loader item.
		 */
		private function updateProgress(loaderItem : ILoaderItem) : void {
			var monitorItemUpdateInfo : MonitorItemUpdateInfo = updateItem(
				loaderItem,
				loaderItem.numItems,
				loaderItem.numItemsLoaded,
				loaderItem.numItemsFailed,
				loaderItem.progress
			);
			
			_progress = incrementProgress(monitorItemUpdateInfo);

			// update numItems since it may have changed before a progress notification 
			_numItems += (monitorItemUpdateInfo.numItemsNew - monitorItemUpdateInfo.numItemsOld);
			_numItemsLoaded += (monitorItemUpdateInfo.numItemsLoadedNew - monitorItemUpdateInfo.numItemsLoadedOld);
			_numItemsFailed += (monitorItemUpdateInfo.numItemsFailedNew - monitorItemUpdateInfo.numItemsFailedOld);
			
			dispatchProgress();
		}

		/**
		 * Tests if all items of the monitor has been finished.
		 */
		private function checkMonitorComplete() : Boolean {
			return numItems == numItemsLoaded + numItemsFailed;
		}

		/**
		 * Creates a new entry in the internal map.
		 */
		private function watchItem(
			loaderItem : ILoaderItem,
			weight: uint,
			numItems : uint,
			numItemsLoaded : uint,
			numItemsFailed : uint,
			progress : Number
		) : MonitorItemUpdateInfo {
			var monitorItem : MonitorItem = new MonitorItem(
				loaderItem,
				weight,
				numItems,
				numItemsLoaded,
				numItemsFailed,
				progress
			);
			_watchedItems.add(loaderItem, monitorItem);

			var updateInfo : MonitorItemUpdateInfo = new MonitorItemUpdateInfo();
			updateInfo.monitorItem = monitorItem;
			updateInfo.numItemsOld = 0;
			updateInfo.weightOld = 0;
			updateInfo.numItemsLoadedOld = 0;
			updateInfo.progressOld = 0;
			return updateInfo;

		}
		
		/**
		 * Updates an internal map item.
		 */
		private function updateItem(
			loaderItem : ILoaderItem,
			numItems : uint,
			numItemsLoaded : uint,
			numItemsFailed : uint,
			progress : Number
		) : MonitorItemUpdateInfo {
			var monitorItem : MonitorItem = _watchedItems.itemFor(loaderItem);
			
			var numItemsOld : Number = monitorItem.numItems;
			var numItemsLoadedOld : Number = monitorItem.numItemsLoaded;
			var numItemsFailedOld : Number = monitorItem.numItemsFailed;
			var itemWeightOld : uint = monitorItem.weight; // changing numItems may change also the weight
			var itemProgressOld : Number = monitorItem.progress;
			
			monitorItem.numItems = numItems;
			monitorItem.numItemsLoaded = numItemsLoaded;
			monitorItem.numItemsFailed = numItemsFailed;
			monitorItem.progress = progress;
			
			var updateInfo : MonitorItemUpdateInfo = new MonitorItemUpdateInfo();
			updateInfo.monitorItem = monitorItem;
			updateInfo.numItemsOld = numItemsOld;
			updateInfo.numItemsLoadedOld = numItemsLoadedOld;
			updateInfo.numItemsFailedOld = numItemsFailedOld;
			updateInfo.weightOld = itemWeightOld;
			updateInfo.progressOld = itemProgressOld;

			return updateInfo;
			
		}
		
		/**
		 * Updates the overall progress incrementally.
		 */
		private function incrementProgress(info : MonitorItemUpdateInfo) : Number {
			
			// first we calculate the change in our countable items
			var sumWeightsNew : Number = _sumWeights + (info.weightNew - info.weightOld);
			
			// when empty sequence added and no items watched yet then there is no progress
			if (!sumWeightsNew) return 0;
			
			// this is the portion of the entire progress of the current item
			var progressNew : Number = info.progressNew * info.weightNew / sumWeightsNew;

			// when already items watched we recalculate and add their proportional progress
			if (_sumWeights) {
				
				var progressOthersOld : Number = progress;
				
				// subtract the items old relative progress if any
				if (info.progressOld) {
					// remove the old items relative progress
					var relativeItemProgressOld : Number = info.progressOld * info.weightOld / _sumWeights;
					progressOthersOld -= relativeItemProgressOld;
				}
				
				// new new progress respects the grown cumulative weight
				progressNew += (progressOthersOld * _sumWeights / sumWeightsNew);
			}
			
			// we save the new cumulative weight
			_sumWeights = sumWeightsNew;
			
			// and return the new progress value
			return progressNew;
		}
		
		//		/**
		//		 * Recalculates the progress.
		//		 */
		//		private function recalculateProgress() : Number {
		//			_sumWeights = recalculateSumWeights();
		//			
		//			var progress : Number = 0;
		//			var iterator : IMapIterator = _watchedItems.getMapIterator();
		//			var monitorItem : MonitorItem;
		//			while (iterator.hasNext()) {
		//				monitorItem = iterator.getNext() as MonitorItem;
		//				progress += monitorItem.getRelativeProgress(_sumWeights);
		//			}
		//			
		//			return progress;
		//		}
		//		
		//		/**
		//		 * Recalculates the cumulative weight
		//		 */
		//		private function recalculateSumWeights() : Number {
		//			var sumWeights : uint = 0;
		//			
		//			var iterator : IMapIterator = _watchedItems.getMapIterator();
		//			var monitorItem : MonitorItem;
		//			while (iterator.hasNext()) {
		//				monitorItem = iterator.getNext() as MonitorItem;
		//				sumWeights += monitorItem.weight;
		//			}
		//			
		//			return sumWeights;
		//		}

		/*
		 * Monitor events
		 */
		
		/**
		 * Dispatches the MonitorEvent.PROGRESS event.
		 */
		protected function dispatchProgress() : void {
			//trace ("DISPATCH MONITOR PROGRESS " + numItemsLoaded + " " + numItems);
			dispatchEvent(new MonitorEvent(MonitorEvent.PROGRESS, this));
		}
		
		/**
		 * Dispatches the MonitorEvent.COMPLETE event.
		 */
		protected function dispatchMonitorComplete() : void {
//			trace ("DISPATCH MONITOR COMPLETE " + numItemsLoaded + " " + numItems);
			dispatchEvent(new MonitorEvent(MonitorEvent.COMPLETE, this));
		}
	}
}

import com.sibirjak.angara.core.ILoaderItem;

/**
 * Loader item update information object.
 * 
 * <p>Stores the differences between two loader item states.</p>
 */
internal class MonitorItemUpdateInfo {
	public var monitorItem : MonitorItem;

	public var numItemsOld : uint;
	public var numItemsLoadedOld : uint;
	public var numItemsFailedOld : uint;
	public var weightOld : uint;
	public var progressOld : Number;
	
	public function get numItemsNew() : uint {
		return monitorItem.numItems;
	}
	public function get numItemsLoadedNew() : uint {
		return monitorItem.numItemsLoaded;
	}
	public function get numItemsFailedNew() : uint {
		return monitorItem.numItemsFailed;
	}
	public function get weightNew() : uint {
		return monitorItem.weight;
	}
	public function get progressNew() : Number {
		return monitorItem.progress;
	}
}

/**
 * Loader item progress information.
 */
internal class MonitorItem {
	public var loaderItem : ILoaderItem;
	public var _weight : uint;
	public var numItems : uint;
	public var numItemsLoaded : uint;
	public var numItemsFailed : uint;
	public var progress : Number;

	public function MonitorItem(
		theLoaderItem : ILoaderItem,
		theWeight : uint,
		theNumItems : uint,
		theNumItemsLoaded : uint,
		theNumItemsFailed : uint,
		theProgress : Number
	) {
		loaderItem = theLoaderItem;
		_weight = theWeight;
		numItems = theNumItems;
		numItemsLoaded = theNumItemsLoaded;
		numItemsFailed = theNumItemsFailed;
		progress = theProgress;
	}
	public function set weight(weight : uint) : void {
		_weight = weight;
	}
	public function get weight() : uint {
		return _weight ? _weight : numItems;
	}
//	public function getRelativeProgress(sumWeights : uint) : Number {
//		if (!sumWeights) return 0;
//		return _progress * weight / sumWeights;
//	}
	
}
