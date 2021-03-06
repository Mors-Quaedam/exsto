-- Clear plugin
local PLUGIN = exsto.CreatePlugin()

PLUGIN:SetInfo({
	Name = "Clear",
	ID = "clear",
	Desc = "Clear's players crap.",
	Owner = "Hobo",
} )

function PLUGIN:Clear( owner, targ, clr, show )
	local Return = {}

    targ = string.lower(targ)
	
	if( targ == "map" or targ == "world") then
		game.CleanUpMap()
		Return = { COLOR.NAME,owner,COLOR.NORM, " cleaned the map!" }
		
	elseif (targ == "all") then
		cleanup.CC_AdminCleanup(owner, nil, {clr != "" and clr or nil} )
		if clr == "" then
			Return = { COLOR.NAME,owner,COLOR.NORM, " removed everything!" }			
		else
			Return = { COLOR.NAME,owner,COLOR.NORM, " removed ",COLOR.NAME, "all ".. clr, COLOR.NORM, "!" }		
		end
		
	elseif (targ == "that" or targ == "that+") then
            local e = owner:GetEyeTraceNoCursor().Entity
            if targ == "that" then
                if ValidEnt(e) then
                    e:Remove()
                else
                    return { owner,COLOR.NORM,"Invalid object." }           
                end
            else
                for _,const in pairs (constraint.GetAllConstrainedEntities(e)) do
                    if ValidEnt(const) then
                        const:Remove()          
                    end
                end
            end
		Return = { COLOR.NAME,owner,COLOR.NORM, " removed ",COLOR.NAME,tostring(e) }	
		
	else
		ply = exsto.FindPlayer(targ)
		if ply then
			cleanup.CC_Cleanup(ply, nil, {clr != "" and clr or nil} )
			if clr == "" then
				Return = { COLOR.NAME,owner,COLOR.NORM, " removed all ",COLOR.NAME, ply, COLOR.NORM, "'s property!" }			
			else
				Return = { COLOR.NAME,owner,COLOR.NORM, " removed ",COLOR.NAME, ply, COLOR.NORM, "'s ", COLOR.NAME, clr, COLOR.NORM, "!" }	
			end
		else
			return { owner,COLOR.NAME, targ, COLOR.NORM, " is not a valid player!" }
		end
		
	end
	
	if show > 0 then
		return Return
	end
end

PLUGIN:AddCommand( "clear", {
	Call = PLUGIN.Clear,
	Desc = "Clears objects and other things. Exmpl: !clear Hobo, !clear map, !clear all, !clear that.", 
	FlagDesc = "Allows a user to clear someone's stuff.",
	Console = { "cleanup","clear" },
	Chat = { "!cleanup","!clear" },
	ReturnOrder = "Player-Clearing-Show",
	Args = { Player = "STRING", Clearing = "STRING", Show = "NUMBER" },
    Optional = { Player = "all", Clearing = "", Show = 1},
	Category = "Administration",
})

local Included = {
    "prop_",
    "gmod_",
    "3dtext",
	"gib",
	"item_",
}
        
function ValidEnt( entity )
       -- Exlcludes essentials
    if entity:IsValid() then
        cl = entity:GetClass()
                
        for I in pairs(Included) do
            if string.find(cl,Included[I]) then return 1 end
        end
        return false
    end
end

PLUGIN:Register()