import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.Dynel;
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
		VicinitySystem.SignalDynelEnterVicinity.Connect(SlotEnteredVicinity, this);
		FindMinion();
	}
	
	public function Unload()
	{
		VicinitySystem.SignalDynelEnterVicinity.Disconnect(SlotEnteredVicinity, this);
	}
}