/**
 * BigBlueButton open source conferencing system - http://www.bigbluebutton.org/
 * 
 * Copyright (c) 2014 BigBlueButton Inc. and by respective authors (see below).
 *
 * This program is free software; you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free Software
 * Foundation; either version 3.0 of the License, or (at your option) any later
 * version.
 * 
 * BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 * PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License along
 * with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.
 *
 */

package org.bigbluebutton.clientcheck.model
{
	import mx.collections.ArrayCollection;

	import spark.collections.Sort;
	import spark.collections.SortField;

	public class DataProvider implements IDataProvider
	{
		private var _dataProvider:ArrayCollection = new ArrayCollection;

		public function addData(obj:Object, status:Object):void
		{
			_dataProvider.addItem(mergeWithStatusObject(obj, status));
		}

		public function getData():ArrayCollection
		{
			return _dataProvider;
		}

		private function dataChanged(currentObj:Object, newObj:Object):Boolean
		{
			return (currentObj.StatusPriority != newObj.StatusPriority) || (currentObj.Result != newObj.Result)
		}

		public function updateData(obj:Object, status:Object):void
		{
			var merged:Object = mergeWithStatusObject(obj, status);
			var i:int = 0;

			while (i < _dataProvider.length && _dataProvider.getItemAt(i).Item != merged.Item) i++;

			if (_dataProvider.getItemAt(i).Item == merged.Item)
			{
				if(dataChanged(_dataProvider.getItemAt(i),merged))
				{
					_dataProvider.getItemAt(i).StatusPriority = merged.StatusPriority;
					_dataProvider.getItemAt(i).StatusMessage = merged.StatusMessage;
					_dataProvider.getItemAt(i).Result = merged.Result;
					_dataProvider.itemUpdated(_dataProvider.getItemAt(i));
				}
			}
			else trace("Something is missing at MainViewMediator's initDataProvider");
		}

		public function mergeWithStatusObject(obj:Object, status:Object):Object
		{
			var merged:Object = new Object();
			var p:String;

			for (p in obj) {
				merged[p] = obj[p];
			}
			for (p in status) {
				merged[p] = status[p];
			}

			return merged;
		}
	}
}
