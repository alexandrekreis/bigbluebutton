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

package org.bigbluebutton.clientcheck.view.mainview
{
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.system.System;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.events.MouseEvent

	import mx.events.FlexEvent;
	import mx.resources.ResourceManager;

	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.List;

	public class MainView extends MainViewBase implements IMainView
	{
		public function MainView():void
		{
			super.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}

		protected function creationCompleteHandler(event:Event):void
		{
			var generalContextMenu:ContextMenu=new ContextMenu();
			generalContextMenu.hideBuiltInItems();
			var copyAllResultsButton:ContextMenuItem=new ContextMenuItem(resourceManager.getString('resources', 'bbbsystemcheck.copyAllResultsText'));
			copyAllResultsButton.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemHandler);
			generalContextMenu.customItems.push(copyAllResultsButton);
			this.contextMenu=generalContextMenu;

			var checkResultContextMenu:ContextMenu=new ContextMenu();
			checkResultContextMenu.hideBuiltInItems();
			var checkResultButton:ContextMenuItem=new ContextMenuItem(resourceManager.getString('resources', 'bbbsystemcheck.copyCheckResultText'));
			checkResultButton.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemHandler);
			checkResultContextMenu.customItems.push(checkResultButton);
			this.resultImg.contextMenu=checkResultContextMenu;
			this.resultTitleLabel.contextMenu=checkResultContextMenu;
			this.resultDescriptionLabel.contextMenu=checkResultContextMenu;

			var itemResultContextMenu:ContextMenu=new ContextMenu();
			itemResultContextMenu.hideBuiltInItems();
			var copyItemResultButton:ContextMenuItem=new ContextMenuItem(resourceManager.getString('resources', 'bbbsystemcheck.copyItemResultText'));
			copyItemResultButton.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemHandler);
			itemResultContextMenu.customItems.push(copyItemResultButton);
			this.itemResultLabel.contextMenu=itemResultContextMenu;

			this.checkList.addEventListener(MouseEvent.CLICK,clickHandler);


		}

		private function menuItemHandler(e:ContextMenuEvent):void
		{
			if (e.target.caption == resourceManager.getString('resources', 'bbbsystemcheck.copyAllResultsText'))
			{
				System.setClipboard(getAllInfoAsString());
			}

			else if (e.target.caption == resourceManager.getString('resources', 'bbbsystemcheck.copyCheckResultText'))
			{
				System.setClipboard(getClientCheckResultInfoAsString());
			}

			else if (e.target.caption == resourceManager.getString('resources', 'bbbsystemcheck.copyItemResultText'))
			{
				System.setClipboard(getResultInfoAsString());
			}
		}

		private function getAllInfoAsString():String
		{
			var info:String="";

			for (var i:int=0; i < checkList.dataProvider.length; i++)
			{
				info+=checkList.dataProvider.getItemAt(i).Item + ":  " + checkList.dataProvider.getItemAt(i).Result + "  :  " + checkList.dataProvider.getItemAt(i).StatusMessage + "\n";
			}

			return info;
		}

		private function getClientCheckResultInfoAsString():String
		{
			var info:String="";

			info = this.resultTitleLabel.text + ":  " + this.resultDescriptionLabel.text;

			return info;
		}

		private function getResultInfoAsString():String
		{
			var info:String="";

			if(checkList.selectedIndex>=0 && checkList.selectedIndex < checkList.dataProvider.length) {
				var i:int = checkList.selectedIndex;
				info = checkList.dataProvider.getItemAt(i).Item + ":  " + checkList.dataProvider.getItemAt(i).Result + "  :  " + checkList.dataProvider.getItemAt(i).StatusMessage;
			}

			return info;
		}

		private function clickHandler(event:MouseEvent):void
		{
			updateItemLabels();
		}

		public function updateItemLabels():void
		{
			if(checkList.selectedIndex>=0)
			{
				var checkListItem:Object = checkList.dataProvider.getItemAt(checkList.selectedIndex);

				var downloadSpeedItem:String = ResourceManager.getInstance().getString('resources', 'bbbsystemcheck.test.name.downloadSpeed');
				if(checkListItem.Item != downloadSpeedItem && checkListItem.StatusPriority == StatusENUM.LOADING.StatusPriority)
					itemResultLabel.text = checkListItem.Item + ": " + StatusENUM.LOADING.StatusMessage;
				else
					itemResultLabel.text = checkListItem.Item + ": " + checkListItem.Result;

			}
		}

		public function setCheckResult(checkResult:int):void {
			switch (checkResult) {
				case StatusENUM.CLIENT_CHECK_SUCCEEDED:
					resultTitleLabel.text = resourceManager.getString('resources', 'bbbsystemcheck.clientcheck.result.success.title');
					resultDescriptionLabel.text = resourceManager.getString('resources', 'bbbsystemcheck.clientcheck.result.success.description');
					resultImg.source = images.ok_icon;
					break;
				case StatusENUM.CLIENT_CHECK_FAILED:
					resultTitleLabel.text = resourceManager.getString('resources', 'bbbsystemcheck.clientcheck.result.failed.title');
					resultDescriptionLabel.text = resourceManager.getString('resources', 'bbbsystemcheck.clientcheck.result.failed.description');
					resultImg.source = images.error_icon;
					break;
				case StatusENUM.CLIENT_CHECK_WARNING:
					resultTitleLabel.text = resourceManager.getString('resources', 'bbbsystemcheck.clientcheck.result.warning.title');
					resultDescriptionLabel.text = resourceManager.getString('resources','bbbsystemcheck.clientcheck.result.warning.description');
					resultImg.source = images.warning_icon;
					break;
			}
		}

		public function get checkList():List
		{
			return _checkList;
		}

		public function get view():BorderContainer
		{
			return super;
		}
	}
}
