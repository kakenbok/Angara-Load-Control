package com.sibirjak.angara.sequence {

	import com.sibirjak.angara.core.ILoaderItem;

	import org.as3commons.collections.framework.IIterable;

	/**
	 * The sequence manager is a convenient class to group and manage the
	 * behaviour of a list of sequences.
	 * 
	 * <p>The sequence manager can be added to the loader manager the same
	 * way as resource loaders or sequences.</p>
	 * 
	 * <p>In certain situations we only want one out of a list of sequences
	 * to be loading. This might be a tab bar, where the assets of only the
	 * visible tab should be loading. If the use changes the visible tab,
	 * the loading of the former active tab should be stopped or delayed.
	 * In such a case we can call pauseAllExcept() or loadBeforeOthers() to
	 * stop or reprioritise the sequences of the invisible tabs.</p>
	 * 
	 * @author jes 14.05.2009
	 */
	public interface ISequenceManager extends ILoaderItem, IIterable {

		/**
		 * Adds a sequence to a sequence manager.
		 * 
		 * <p>Its possible to add sequence at any time of loading to a sequence
		 * manager but not after the sequence manager has been marked as complete.</p>
		 * 
		 * @param sequence The sequence to manage within this manager.
		 */
		function add(sequence : ISequence) : void;

		/**
		 * Removes a sequence from a sequence manager.
		 * 
		 * @param sequence The sequence to remove from the manager.
		 */
		function remove(sequence : ISequence) : void;

		/**
		 * Stops all loaders and removes all sequence references from the manager.
		 */
		function clear() : void;

		/**
		 * Pauses all other sequences and resumes the specified sequence.
		 * 
		 * <p>Does not stop resource loaders of other sequences. Sequence will
		 * therefore resume loading not before all loaders of other sequences
		 * are finished (complete or failure).
		 * 
		 * @param sequence The sequence to resume while all others gets paused.
		 */
		function pauseAllExcept(sequence : ISequence) : void;

		/**
		 * Reprioritised a sequence to be loaded before all other sequences
		 * in a sequence manager.
		 * 
		 * @param sequence The sequence to load before other sequences.
		 */
		function loadBeforeOthers(sequence : ISequence) : void;

	}
}
