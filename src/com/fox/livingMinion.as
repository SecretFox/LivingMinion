import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.Dynel;
import com.GameInterface.Quest;
import com.GameInterface.QuestsBase;
import com.GameInterface.VicinitySystem;
import com.Utils.ID32;
import com.Utils.WeakList;
import mx.utils.Delegate;
/*
* ...
* @author SecretFox
*/
class com.fox.livingMinion 
{
	public var Looks:DistributedValue;
	public var Doppel:DistributedValue;
	public var Invoke:DistributedValue;
	
	public static function main(swfRoot:MovieClip):Void
	{
		var mod = new livingMinion(swfRoot);
		swfRoot.onLoad = function(){mod.Load()};
		swfRoot.onUnload = function(){mod.Unload()};
	}

	public function livingMinion() {
		Looks = DistributedValue.Create("LivingMinion_Looks");
		Doppel = DistributedValue.Create("LivingMinion_Doppel");
		Invoke = DistributedValue.Create("LivingMinion_Invoke");
		Looks.SignalChanged.Connect(FindMinion, this);
	}
	
	private function FindMinion()
	{
        var ls:WeakList = Dynel.s_DynelList;
        for (var num = 0; num < ls.GetLength(); num++)
        {
            var dyn:Character = ls.GetObject(num);
			SlotEnteredVicinity(dyn.GetID());
        }
	}
	
	private function SlotEnteredVicinity(id:ID32)
	{
		if ( !id.IsNpc())
		{
			return;
		}
		var dynel:Character = Character.GetCharacter(id);
		var stat = dynel.GetStat(112);
		switch (stat) 
		{
			case 38404:
				var lookstring = Looks.GetValue();
				if ( lookstring )
				{
					ApplyLooks(dynel, lookstring);
				}
				break;
			case 38361:
				var lookstring = Invoke.GetValue();
				if ( lookstring )
				{
					setTimeout(Delegate.create(this, ApplyLooks), 250, dynel, lookstring, true);
					// needs delay to make sure lookspackages have time to load before removal
				}
				break;
			case 36813:
				var lookstring = Doppel.GetValue();
				if ( lookstring )
				{
					setTimeout(Delegate.create(this, ApplyLooks), 250, dynel, lookstring, false);
					// needs delay to make sure lookspackages have time to load before removal
				}
				break;
		}
	}
	
	private function ApplyLooks(dyn:Dynel, lookstring:String, namerequired:Boolean)
	{
		if ( namerequired && dyn.GetName() != Character.GetClientCharacter().GetName()){
			return;
		}
		dyn.RemoveAllLooksPackages();
		dyn.AddLooksPackage(7752815); // make invisible
		// dyn.RemoveLooksPackage(7691854); // Removes fur coat
		var looks:Array = lookstring.split(";");
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