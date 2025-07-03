// c 2025-06-27
// m 2025-07-03

#if DEPENDENCY_ULTIMATEMEDALSEXTENDED

UltimateMedalsExtended::Config@ UME_Config;

class UME_Medal : UltimateMedalsExtended::IMedal {
    UME_Medal() {
        @UME_Config = UltimateMedalsExtended::Config();
        UME_Config.defaultName = "Warrior";
        UME_Config.icon = pluginColor + Icons::Circle;
    }

    UltimateMedalsExtended::Config GetConfig() override {
        return UME_Config;
    }

    uint GetMedalTime() override {
        Meta::Plugin@ plugin = Meta::GetPluginFromID("WarriorMedals");
        if (plugin is null or !plugin.Enabled) {
            return 0;
        }
        return WarriorMedals::GetWMTime();
    }

    bool HasMedalTime(const string&in uid) override {
        return WarriorMedals::GetWMTime(uid) > 0;
    }

    void UpdateMedal(const string&in uid) override { }
}

#endif
