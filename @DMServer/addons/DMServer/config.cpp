class CfgPatches {
    class DMServer {
        units[] = {"C_man_1"};
        weapons[] = {};
        requiredAddons[] = {"A3_Data_F","A3_Soft_F","A3_Soft_F_Offroad_01","A3_Characters_F"};
        fileName = "DMServer.pbo";
        author = "kst | IslandProject";
    };
};

class CfgFunctions {
    class DMServer {
        class Bootstrap {
            file = "DMServer\bootstrap";
            
            class PreInit {
                preInit = 1;
            };
        };
    };
};