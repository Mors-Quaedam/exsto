--[[
	Exsto
	Copyright (C) 2013  Prefanatic

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

exsto.Animations = {
	Handle = {};
	Styles = {};
	Override = false;
	Math = "smooth";
}

local function storeOldFunctions( obj )
	local getPos = obj.GetPos
	local setPos = obj.SetPos
	local setAlpha = obj.SetAlpha
	local setVisible = obj.SetVisible
	
	obj.OldFuncs = {
		GetPos = getPos;
		SetPos = setPos; 
		SetX = function( obj, x ) obj.OldFuncs.SetPos( obj, x, obj.Anims[ 2 ].Last or obj.OldFuncs.GetPos[2] or 0 ) end;
		SetY = function( obj, y ) obj.OldFuncs.SetPos( obj, obj.Anims[ 1 ].Last or obj.OldFuncs.GetPos[1] or 0, y ) end;
		
		SetVisible = setVisible;
		SetAlpha = function( obj, alpha ) 
			setAlpha( obj, alpha ) 
			setVisible( obj, alpha >= 5 ) 
		end;
	
		SetColor = function( obj, color ) obj.m_bgColor = color end;
		SetRed = function( obj, red ) obj.m_bgColor.r = red end;
		SetGreen = function( obj, green ) obj.m_bgColor.g = green end;
		SetBlue = function( obj, blue ) obj.m_bgColor.b = blue end;
		SetAlphaBG = function( obj, alpha ) obj.m_bgColor.a = alpha end;
	}
end

local function buildAnimTable( obj )
	local x, y = obj:GetPos()
	obj.Anims[ 1 ] = {
		Current = x,
		Last = x,
		Mul = 2,
		Call = "SetX",
	}
	
	obj.Anims[ 2 ] = {
		Current = y,
		Last = y,
		Mul = 2,
		Call = "SetY",
	}

	-- Alpha.
	obj.Anims[ 3 ] = {
		Current = 255,
		Last = 255,
		Mul = 4,
		Call = "SetAlpha"
	}
	
	local col = obj.m_bgColor
	if col then
		-- Color Object
		obj.Anims[ 4 ] = {
			Current = col.r,
			Last = col.r,
			Mul = 4,
			Call = "SetRed"
		}
		obj.Anims[ 5 ] = {
			Current = col.g,
			Last = col.g,
			Mul = 4,
			Call = "SetGreen"
		}
		obj.Anims[ 6 ] = {
			Current = col.b,
			Last = col.b,
			Mul = 4,
			Call = "SetBlue"
		}
		obj.Anims[ 7 ] = {
			Current = col.a,
			Last = col.a,
			Mul = 4,
			Call = "SetAlphaBG"
		}
	end
end

local function createOverrides( obj )
	-- General
	obj.SetPosMul = function( obj, mul )
		obj.Anims[1].Mul = mul
		obj.Anims[2].Mul = mul
	end
	
	obj.SetFadeMul = function( obj, mul ) obj.Anims[3].Mul = mul end
	
	obj.SetColorMul = function( obj, mul )
		for I = 4, 7 do
			obj.Anims[ I ].Mul = mul
		end
	end
	
	obj.DisableAnims = function( obj ) self.Anims.Disabled = true end
	obj.EnableAnims = function( obj ) self.Anims.Disabled = false end
	
	-- Positions
	obj.GetPos = function( obj, bool )
		local x = !bool and ( obj.Anims[ 1 ].Last or 0 ) or ( obj.Anims[ 1 ].Current or 0 )
		local y = !bool and ( obj.Anims[ 2 ].Last or 0 ) or ( obj.Anims[ 2 ].Current or 0 )
		return x, y
	end
	obj.SetPos = function( obj, x, y ) 
		obj.Anims[1].Current = x
		obj.Anims[2].Current = y 
	end
	
	-- Fading
	obj.FadeOnVisible = function( obj, bool ) obj.fadeOnVisible = bool end
	obj.SetFadeMul = function( obj, mul ) obj.Anims[3].Mul = mul end
	
	obj.SetAlpha = function( obj, alpha ) obj.Anims[3].Current = alpha end
	
	obj.SetVisible = function( obj, bool )
		if obj.fadeOnVisible then
			if bool == true then
				obj.SetAlpha( obj, 255 )
				obj.Anims[3].Last = 10
				obj.OldFuncs.SetAlpha( obj, 10 )
			else
				obj.SetAlpha( obj, 0 )
			end
		else
			obj.OldFuncs.SetVisible( obj, bool )
		end
	end
	
	-- Color
	obj.SetColor = function( obj, col )
		obj:SetRed( col.r )
		obj:SetGreen( col.g )
		obj:SetBlue( col.b )
		obj:SetAlpha2( col.a )
	end
	
	obj.SetRed = function( obj, r ) obj.Anims[4].Current = r end
	obj.SetGreen = function( obj, g ) obj.Anims[5].Current = g end
	obj.SetBlue = function( obj, b ) obj.Anims[6].Current = b end
	obj.SetAlpha2 = function( obj, a ) obj.Anims[7].Current = a end
	
end

function exsto.Animations.CreateAnimation( obj )
	obj.Anims = {}
	
	storeOldFunctions( obj )
	buildAnimTable( obj )
	createOverrides( obj )
	
	local think, dist, speed = obj.Think
	obj.Think = function( self )
		if think then think( self ) end
		
		for _, data in ipairs( self.Anims ) do
			if math.Round( data.Last ) != math.Round( data.Current ) then
				if self.Anims.Disabled then
					data.Last = data.Current
					data.Call( self, self.Anims[ _ ].Last )
				else
					dist = data.Current - data.Last
					speed = RealFrameTime() * ( dist / data.Mul  ) * 40

					self.Anims[ _ ].Last = math.Approach( data.Last, data.Current, speed )
					if self.OldFuncs[ data.Call ] then
						self.OldFuncs[ data.Call ]( self, self.Anims[ _ ].Last )
					else
						Error( "ExDerma --> Unknown animation callback '" .. tostring( data.Call ) .. "'" )
					end
				end
			end
		end
	end
	
end