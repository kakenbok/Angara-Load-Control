package com.sibirjak.angara.sequence {
	
	/**
	 * A paged sequence enables loading of only a range of containing loaders
	 * at a time.
	 * 
	 * <p>A resource loader added to a paged sequence will be automatically
	 * paused.</p>
	 * 
	 * @author jes 18.05.2009
	 */
	public interface IPagedSequence extends ISequence {

		/**
		 * Resumes all loaders in the specified range and pauses all
		 * other currently waiting loaders.
		 * 
		 * @param index The index of the first resource loader.
		 * @param numItems The number of loaders to be resumed.
		 */
		function activateLoaders(index : uint, numItems : uint) : void;

	}
}
