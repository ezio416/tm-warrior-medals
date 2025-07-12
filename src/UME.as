// c 2025-06-27
// m 2025-07-12

#if DEPENDENCY_ULTIMATEMEDALSEXTENDED

class UME_Medal : UltimateMedalsExtended::IMedal {
    UltimateMedalsExtended::Config GetConfig() override {
        UltimateMedalsExtended::Config c;

        c.defaultName = "Warrior";
        c.icon = pluginColor + Icons::Circle;

        return c;
    }

    uint GetMedalTime() override {
        if (false
            or pluginMeta is null
            or !pluginMeta.Enabled
        ) {
            return 0;
        }

        return WarriorMedals::GetWMTime();
    }

    bool HasMedalTime(const string&in uid) override {
        if (false
            or pluginMeta is null
            or !pluginMeta.Enabled
        ) {
            return false;
        }

        return WarriorMedals::GetWMTime(uid) > 0;
    }

    void UpdateMedal(const string&in uid) override { }
}

#endif
