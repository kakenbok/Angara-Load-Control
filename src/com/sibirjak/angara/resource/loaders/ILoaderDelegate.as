package com.sibirjak.angara.resource.loaders {
	import com.sibirjak.angara.resource.IDisplayAssetLoader;
	import com.sibirjak.angara.resource.IResourceLoader;
	import flash.system.LoaderContext;


	/**
	 * Extends the IResourceLoader interface with flash Loader functionality.
	 * 
	 * @author jes 07.05.2009
	 */
	public interface ILoaderDelegate extends IResourceLoader, IDisplayAssetLoader {

		/**
		 * Speficies a LoaderContext property with security and application domain
		 * information.
		 * 
		 * <p>You need to set up this property before the loader starts loading.</p>
		 * 
		 * @param loaderContext The loader context property.
		 */
		function set loaderContext(loaderContext : LoaderContext) : void;

	}
}
