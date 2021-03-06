
function SetItemButtonCount(button, count, abbreviate)
	if ( not button ) then
		return;
	end

	if ( not count ) then
		count = 0;
	end

	button.count = count;
	local countString = button.Count or _G[button:GetName().."Count"];
	if ( count > 1 or (button.isBag and count > 0) ) then
		if ( abbreviate ) then
			count = AbbreviateNumbers(count);
		elseif ( count > (button.maxDisplayCount or 9999) ) then
			count = "*";
		end
		countString:SetText(count);
		countString:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		countString:Show();
	else
		countString:Hide();
	end
end

function SetItemButtonStock(button, numInStock)
	if ( not button ) then
		return;
	end

	if ( not numInStock ) then
		numInStock = "";
	end

	button.numInStock = numInStock;
	if ( numInStock > 0 ) then
		_G[button:GetName().."Stock"]:SetFormattedText(MERCHANT_STOCK, numInStock);
		_G[button:GetName().."Stock"]:Show();
	else
		_G[button:GetName().."Stock"]:Hide();
	end
end

function SetItemButtonTexture(button, texture)
	if ( not button ) then
		return;
	end
	local icon = button.Icon or button.icon or _G[button:GetName().."IconTexture"];
	if ( texture ) then
		icon:Show();
	else
		icon:Hide();
	end
	icon:SetTexture(texture);
end

function SetItemButtonTextureVertexColor(button, r, g, b)
	if ( not button ) then
		return;
	end
	
	local icon = button.Icon or button.icon or _G[button:GetName().."IconTexture"];
	icon:SetVertexColor(r, g, b);
end

function SetItemButtonDesaturated(button, desaturated)
	if ( not button ) then
		return;
	end
	local icon = button.Icon or button.icon or _G[button:GetName().."IconTexture"];
	if ( not icon ) then
		return;
	end
	
	icon:SetDesaturated(desaturated);
end

function SetItemButtonNormalTextureVertexColor(button, r, g, b)
	if ( not button ) then
		return;
	end
	
	_G[button:GetName().."NormalTexture"]:SetVertexColor(r, g, b);
end

function SetItemButtonNameFrameVertexColor(button, r, g, b)
	if ( not button ) then
		return;
	end
	
	local nameFrame = button.NameFrame or _G[button:GetName().."NameFrame"];
	nameFrame:SetVertexColor(r, g, b);
end

function SetItemButtonSlotVertexColor(button, r, g, b)
	if ( not button ) then
		return;
	end
	
	_G[button:GetName().."SlotTexture"]:SetVertexColor(r, g, b);
end

function SetItemButtonQuality(button, quality, itemIDOrLink, suppressOverlays)
	if itemIDOrLink then
		if IsArtifactRelicItem(itemIDOrLink) then
			button.IconBorder:SetTexture([[Interface\Artifacts\RelicIconFrame]]);
		else
			button.IconBorder:SetTexture([[Interface\Common\WhiteIconFrame]]);
		end
		
		if not suppressOverlays and C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(itemIDOrLink) then
			button.IconOverlay:SetAtlas([[AzeriteIconFrame]]);
			button.IconOverlay:Show();
		else
			button.IconOverlay:Hide();
		end
	else
		button.IconBorder:SetTexture([[Interface\Common\WhiteIconFrame]]);
		button.IconOverlay:Hide();
	end

	if quality then
		if quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality] then
			button.IconBorder:Show();
			button.IconBorder:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
		else
			button.IconBorder:Hide();
		end
	else
		button.IconBorder:Hide();
	end
end

function HandleModifiedItemClick(link)
	if ( not link ) then
		return false;
	end
	if ( IsModifiedClick("CHATLINK") ) then
		local linkType = string.match(link, "|H([^:]+)");
		if ( linkType == "instancelock" ) then	--People can't re-link instances that aren't their own.
			local guid = string.match(link, "|Hinstancelock:([^:]+)");
			if ( not string.find(UnitGUID("player"), guid) ) then
				return true;
			end
		end
		if ( ChatEdit_InsertLink(link) ) then
			return true;
		elseif ( SocialPostFrame and Social_IsShown() ) then
			Social_InsertLink(link);
			return true;
		end
	end
	if ( IsModifiedClick("DRESSUP") ) then
		return DressUpItemLink(link) or DressUpBattlePetLink(link) or DressUpMountLink(link)
	end
	if ( IsModifiedClick("EXPANDITEM") ) then
		if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(link) then
			OpenAzeriteEmpoweredItemUIFromLink(link);
			return true;
		end
	end
	return false;
end

ItemButtonMixin = {};

function ItemButtonMixin:GetItemLocation()
	-- TODO: Item locations for item button mixins are currently only supported for bag items.
	return ItemLocation:CreateFromBagAndSlot(self:GetParent():GetID(), self:GetID());
end

function ItemButtonMixin:SetMatchesSearch(matchesSearch)
	self.matchesSearch = matchesSearch;
	self:UpdateItemContextOverlay(self);
end

function ItemButtonMixin:GetMatchesSearch()
	return self.matchesSearch;
end

function ItemButtonMixin:SetItemMatchesItemContext(matchesContext)
	self.matchesItemContext = matchesContext;
	self:UpdateItemContextOverlay(self);
end

function ItemButtonMixin:GetItemContextMatch()
	return self.matchesItemContext;
end

function ItemButtonMixin:UpdateItemContextMatching()
	local itemLocation = self:GetItemLocation();
	if C_Item.DoesItemExist(itemLocation) then
		-- Ideally we'd only have 1 context active at a time, perhaps with a priority system.
		if ItemButtonUtil.GetItemContext() == ItemButtonUtil.ItemContextEnum.Scrapping then
			self:SetItemMatchesItemContext(C_Item.CanScrapItem(itemLocation));
		else
			self:SetItemMatchesItemContext(nil);
		end
	else
		self:SetItemMatchesItemContext(nil);
	end
end

function ItemButtonMixin:UpdateItemContextOverlay()
	local matchesSearch = self.matchesSearch == nil or self.matchesSearch;
	local matchesContext = self.matchesItemContext == nil or self.matchesItemContext;
	self.ItemContextOverlay:SetShown(not matchesSearch or not matchesContext);
end
