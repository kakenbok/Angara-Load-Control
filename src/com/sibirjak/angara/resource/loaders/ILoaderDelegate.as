/*******************************************************************************
* The MIT License
* 
* Copyright (c) 2011 Jens Struwe.
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
******************************************************************************/
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
