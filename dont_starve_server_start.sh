#!/bin/bash
#-------------------------------------------------------------------------------------------
# fgc0109 	2015.11.15
# Kaguya	2019.09.16
#-------------------------------------------------------------------------------------------
dividing="================================================================================"
commandPath="steamcmd"
gamesPath="Steam/steamapps/common/Don't Starve Together Dedicated Server/bin"
gamesFile="dontstarve_dedicated_server_nullrenderer"

#-------------------------------------------------------------------------------------------
function InputError()
{
    echo -e "\033[31m[warn] Illegal Command, Please Check\033[0m"
}
#-------------------------------------------------------------------------------------------
function SystemPreps()
{
    echo -e "\033[33m[info] System Library Install\033[0m"

    sudo apt update
    sudo apt install screen
    # sudo apt install lib32gcc1
    # sudo apt install libcurl4-gnutls-dev
    #----- libs need by dontstarve_dedicated_server_nullrenderer -----
    sudo apt install lib32stdc++6
    sudo apt install libcurl4-gnutls-dev:i386
    sudo apt install libgcc1
    sudo apt install libstdc++6

    echo -e "\033[33m[info] System Library Install Finished\033[0m"
    echo $dividing
}
#-------------------------------------------------------------------------------------------
function CommandPreps()
{
    echo -e "\033[33m[info] Steam Command Line Files Preparing\033[0m"

    if [ ! -d $commandPath ]; then
        mkdir $commandPath
    fi

    cd $commandPath

    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
    tar -xvzf steamcmd_linux.tar.gz
    rm -f steamcmd_linux.tar.gz

    echo -e "\033[33m[info] Steam Command Line Files Prepare Finished\033[0m"
    echo $dividing
}
#-------------------------------------------------------------------------------------------
function ServerPreps()
{
    commandFile="steamcmd.sh"
    
    echo -e "\033[33m[info] Preparing Server Files\033[0m"

    if [ ! -d $commandPath ]; then
        echo -e "\033[31m[warn] Steam Command Line Not Found\033[0m"
        CommandPreps
    else
        echo -e "\033[33m[info] Steam Command Line Found\033[0m"
        cd $commandPath
    fi

    ./$commandFile +login anonymous +app_update 343050 validate +quit

    cd ..
    echo $dividing
    if [ ! -d ~/.klei ]; then
        echo -e "\033[1;31m[info] Server Preparations FINISHED, plz copy Cluster dir to server\033[0m"
        mkdir -p ~/.klei/DoNotStarveTogether/Cluster_1
        echo -e "\033[1;31m[info] File ~/.klei/DoNotStarveTogether has been created\033[0m"
        echo $dividing
    fi
}
#-------------------------------------------------------------------------------------------
function ServerStart()
{
    cd "$gamesPath"

    echo -e "\033[32m[info] Choose Map [1.surface] [2.caves]\033[0m"
    read input_map

    echo -e "\033[32m[info] Choose Cluster [1-5]\033[0m"
    read input_cluster

    case $input_map in
        1)
            sudo screen -S "world" ./$gamesFile -cluster Cluster_$input_cluster -shard Master
            ;;
        2)
            sudo screen -S "caves" ./$gamesFile -cluster Cluster_$input_cluster -shard Caves
            ;;
        *)
            InputError
            ;;
    esac

    echo $dividing
}
#-------------------------------------------------------------------------------------------
function ServerStartQuick()
{
    cd "$gamesPath"

    echo -e "\033[32m[info] Choose Cluster [1-5]\033[0m"
    read input_cluster

    if [ -d temp_world.sh ]; then
        sudo rm -r temp_world.sh
    fi
    if [ -d temp_cave.sh ]; then
        sudo rm -r temp_cave.sh
    fi

    echo -e "\033[33m[info] Starting World Server, Please Wait\033[0m"
    echo sudo screen -d -m -S "world" ./$gamesFile -cluster Cluster_$input_cluster -shard Master > temp_world.sh
    . ./temp_world.sh
    sleep 10

    echo -e "\033[33m[info] Starting Cave Server, Please Wait\033[0m"
    echo sudo screen -d -m -S "caves" ./$gamesFile -cluster Cluster_$input_cluster -shard Caves > temp_cave.sh
    . ./temp_cave.sh
    sleep 10

    if [ -d temp_world.sh ]; then
        sudo rm -r temp_world.sh
    fi
    if [ -d temp_cave.sh ]; then
        sudo rm -r temp_cave.sh
    fi

    echo -e "\033[33m[info] Current Screen Infomation\033[0m"
    sudo screen -ls
    echo $dividing

    top
}
#-------------------------------------------------------------------------------------------
function FilesBackup()
{
    echo -e "\033[32m[info] Choose Cluster To Backup [1-5]\033[0m"
    read input_backup

    if [ -d .klei/DoNotStarveTogether ]; then
        cd .klei/DoNotStarveTogether
        if [ -d Cluster_$input_backup ]; then
            sudo tar -zcf DSTServer_$input_backup.tar.gz Cluster_$input_backup
            echo -e "\033[33m[info] File Cluster_$input_backup has been backuped\033[0m"
        fi
        cd ..
    fi
}
#-------------------------------------------------------------------------------------------
function FilesRecovery()
{
    echo -e "\033[32m[info] Choose Cluster To Recovery [1-5]\033[0m"
    read input_recovery

    if [ -d .klei/DoNotStarveTogether ]; then
        cd .klei/DoNotStarveTogether
        if [ -f DSTServer_$input_recovery.tar.gz ]; then
            if [ -d DSTServer_$input_recovery ]; then
                sudo rm -r Cluster_$input_recovery
            fi
            sudo tar -zxvf DSTServer_$input_recovery.tar.gz
            echo -e "\033[33m[info] File DSTServer_$input_recovery has been Recovered\033[0m"
        else
            echo -e "\033[31m[warn] Backup file for DSTServer_$input_recovery NOT Found\033[0m"
        fi

        cd ..
    else
        echo -e "\033[31m[warn] Main archive folder NOT found\033[0m"
    fi
}
#-------------------------------------------------------------------------------------------
function FilesDelete()
{
    echo -e "\033[32m[info] Choose File To Delete [1-5]\033[0m"
    read input_delete

    if [ -d .klei/DoNotStarveTogether ]; then
        cd .klei/DoNotStarveTogether
        if [ -d "Cluster_$input_delete" ]; then
            sudo rm -rf Cluster_$input_delete
        fi

        echo -e "\033[33m[info] File Cluster_$input_delete has Deleted\033[0m"
        cd ..
    fi
}
#-------------------------------------------------------------------------------------------
function ModConfig()
{
    modConfigPath="Steam/steamapps/common/Don't Starve Together Dedicated Server/mods"
    modConfigFile="dedicated_server_mods_setup.lua"

    echo $dividing
    echo -e "\033[32m[info] Mod Config Menu\033[0m"
    echo -e "\033[1;31m[1.new] [2.add] [3.delete]\033[0m"
    read modSetInput

    case $modSetInput in
        1)
            ;;
        2)
            echo "\033[32m[info]Please input new mod ID: \033[0m"
            read modId
            echo "\033[32m[info]Please input new mod name: \033[0m"
            read modName

            echo "ServerModSetup(\"$modId\") --$modName" >> $modConfigFile
            ;;
        3)
            sed -ie "/$modId/d" $modConfigFile
            ;;
        *)
            InputError
            ;;
    esac

    cp -a "$modConfigFile" "$modConfigPath"

    echo -e "\033[32m[info] Mod config has been set! \033[0m"
}
#-------------------------------------------------------------------------------------------
function UserList()
{
    echo $dividing

    echo -e "\033[32m[info] User List Set Menu\033[0m"
    echo -e "\033[1;31m[1.add] [2.delete]\033[0m"
    read setType

    echo -e "\033[32m[info] Please input Klei user ID: \033[0m"
    read userId

    echo -e "\033[32m[info] Please input Game Cluster Number: \033[0m"
    read clusterNum

    echo -e "\033[32m[info] Please input user type: \033[0m"
    echo -e "\033[1;31m[1.admin] [2.block] [3.white]\033[0m"
    read userType

    userListFile=".klei/DoNotStarveTogether/Cluster_$clusterNum/"

    case $userType in
        1)
            userListFile+=adminlist.txt
            ;;
        2)
            userListFile+=blocklist.txt
            ;;
        3)
            userListFile+=whitelist.txt
            ;;
    esac

    case $setType in
        1)
            echo $userId >> $userListFile
            ;;
        2)
            sed -ie "/$userId/d" $userListFile
            ;;
        *)
            InputError
            ;;
    esac
}
#-------------------------------------------------------------------------------------------
# clear
echo $dividing

cd ~

if [ ! -d "$gamesPath" ]; then
    echo -e "\033[31m[warn] Server Files Not Found\033[0m"
    echo $dividing
    SystemPreps
    ServerPreps
else
    echo -e "\033[32m[info] Server Files Found\033[0m"
    echo $dividing

    echo -en "\033[1;31m"
    echo -e "Choose An Action To Perform"
    echo -e "SysLib Set    [0.Prepare]"
    echo -e "Game Server   [1.start]   [2.update]  [3.quick]"
    echo -e "Unix Screen   [4.info]    [5.attach]  [6.kill]"
    echo -e "Save Files    [7.backup]  [8.recover] [9.delete]"
    echo -e "Game Config   [a.mod]     [b.user]"
    echo -en "\033[0m"
    read input_update

    case $input_update in
        0)
            SystemPreps
            ;;
        1)
            ServerStart
            ;;
        2)
            ServerPreps
            ;;
        3)
            ServerStartQuick
            ;;
        4)
            sudo screen -ls
            ;;
        5)
            sudo screen -r world
            sudo screen -r caves
            ;;
        6)
            sudo killall screen
            echo -e "\033[32m[info] All Screens have been killed\033[0m"
            ;;
        7)
            FilesBackup
            ;;
        8)
            FilesRecovery
            ;;
        9)
            FilesDelete
            ;;
        a)
            ModConfig
            ;;
        b)
            UserList
            ;;
        *)
            InputError
            ;;
    esac
fi
