import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.Dynel;
import com.GameInterface.Quest;
import com.GameInterface.QuestsBase;
import com.GameInterface.VicinitySystem;
import com.Utils.ID32;
import com.Utils.WeakList;
/*
* ...
* @author SecretFox
*/
class com.fox.livingMinion 
{
	public var Looks:DistributedValue;
	public static function main(swfRoot:MovieClip):Void
	{
		var mod = new livingMinion(swfRoot);
		swfRoot.onLoad = function(){mod.Load()};
		swfRoot.onUnload = function(){mod.Unload()};
	}

	public function livingMinion() {
		Looks = DistributedValue.Create("LivingMinion_Looks");
		Looks.SignalChanged.Connect(FindMinion, this);
	}
	
	private function FindMinion()
	{
        var ls:WeakList = Dynel.s_DynelList;
        for (var num = 0; num < ls.GetLength(); num++)
        {
            var dyn:Character = ls.GetObject(num);
			if ( dyn.GetStat(112) == 38404)
			{
				ApplyLooks(dyn);
			}
        }
	}
	
	private function SlotEnteredVicinity(id:ID32)
	{
		if ( !id.IsNpc())
		{
			return;
		}
		var dynel:Dynel = new Dynel(id);
		if (dynel.GetStat(112) == 38404) ApplyLooks(dynel);
	}
	
	private function ApplyLooks(dyn:Dynel)
	{
		dyn.RemoveAllLooksPackages();
		var looks:Array = string(Looks.GetValue()).split(";");
		for (var i = 0; i < looks.length; i++)
		{
			dyn.AddLooksPackage(looks[i]);
		}
	}
	
	public function Load()
	{
		if (!Looks.GetValue())
		{
			var faction = Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_PlayerFaction);
			switch(faction)
			{
				case _global.Enums.Factions.e_FactionDragon:
					var quests = QuestsBase.GetAllActiveQuests();
					var Daimon:Boolean;
					for ( var i in quests)
					{
						if (Quest(quests[i]).m_ID == 4078){
							Looks.SetValue("8320658");
							Daimon = true;
							break;
						}
					}
					if (!Daimon) Looks.SetValue("7691920;6960538");
					break;
				case _global.Enums.Factions.e_FactionIlluminati:
					Looks.SetValue("8907654;9040671");
					break;
				case _global.Enums.Factions.e_FactionTemplar:
					Looks.SetValue("7691920;9418823");
					break;
				default:
					Looks.SetValue();
					break;
			}
		}
		VicinitySystem.SignalDynelEnterVicinity.Connect(SlotEnteredVicinity, this);
		FindMinion();
	}
	
	public function Unload()
	{
		VicinitySystem.SignalDynelEnterVicinity.Disconnect(SlotEnteredVicinity, this);
	}
}