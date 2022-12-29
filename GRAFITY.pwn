#include <YSI_Coding\y_hooks> 

#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

#define RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

#define COL_GREY "{C3C3C3}" // 1
#define COL_WHITE "{FFFFFF}" // 2
#define COL_RED "{F81414}" // 3
#define COL_GREEN "{00FF22}" // 4
#define COL_LIGHTBLUE "{00CED1}" // 5
#define COL_ORANGE "{FF9900}" // 6
#define COL_BLACK "{000000}"

#define MAXGRAFFS 30
#define Graffitis "/Graffitis/%d.txt"

new sprayammount[MAX_PLAYERS];
new POBJECT[MAX_PLAYERS];
new POBJECTN[MAX_PLAYERS][96];
new POBJECTC[MAX_PLAYERS][24];
new Float:XYZ[MAX_PLAYERS][6];
new GRAVEH[MAX_PLAYERS];
new spraytimer[MAX_PLAYERS];
new spraytimerch[MAX_PLAYERS];
new sprayammountch[MAX_PLAYERS];
new isveh[MAX_PLAYERS] = 0;
new sprays = 0;
new graffmenup[MAX_PLAYERS] = 0;
new gammount;
new spraytimerx[MAX_PLAYERS];

enum graffInfo
{
	graffcreator[MAX_PLAYER_NAME],
	graffname[96],
	Float:Xpos,
	Float:Ypos,
	Float:Zpos,
	Float:XYpos,
	Float:YYpos,
	Float:ZYpos,
	STREAMER_TAG_OBJECT:OBJECTID
}
new gInfo[MAXGRAFFS][graffInfo];

stock nGraffiti()
{
	new ID[64]; for(new h = 0; h <= 200; h++){
	format(ID, sizeof(ID), Graffitis, h);if(!dini_Exists(ID)) return h; }return true;
}

stock LoadGraffitis()
{
	new string[70];
    for(new ID = 0; ID < sizeof(gInfo); ID++)
	{
		format(string, sizeof(string), Graffitis, ID);
	    if(dini_Exists(string))
		{
		    strmid(gInfo[ID][graffcreator], dini_Get(string, "graffcreator"), 0, MAX_PLAYER_NAME, MAX_PLAYER_NAME);
		    strmid(gInfo[ID][graffname], dini_Get(string,"graffname"), 0, 96, 96);
			gInfo[ID][Xpos] =  dini_Float(string, "Xpos");
		   	gInfo[ID][Ypos] =  dini_Float(string, "Ypos");
		    gInfo[ID][Zpos] =  dini_Float(string, "Zpos");
   			gInfo[ID][XYpos] =  dini_Float(string, "XYpos");
		   	gInfo[ID][YYpos] =  dini_Float(string, "YYpos");
		    gInfo[ID][ZYpos] =  dini_Float(string, "ZYpos");
   		}
	}
	return 1;
}

stock SaveGraffitis()
{
	new string[50];
 	for(new ID = 0; ID < sizeof(gInfo); ID++)
	{
	    format(string, sizeof(string), Graffitis, ID);
	    if(dini_Exists(string))
	    {
	        dini_Set(string, "graffcreator",gInfo[ID][graffcreator]);
	        dini_Set(string, "graffname",gInfo[ID][graffname]);
		 	dini_FloatSet(string, "Xpos", gInfo[ID][Xpos]);
		  	dini_FloatSet(string, "Ypos", gInfo[ID][Ypos]);
		   	dini_FloatSet(string, "Zpos", gInfo[ID][Zpos]);
		   	dini_FloatSet(string, "XYpos", gInfo[ID][XYpos]);
		  	dini_FloatSet(string, "YYpos", gInfo[ID][YYpos]);
		   	dini_FloatSet(string, "ZYpos", gInfo[ID][ZYpos]);
	    }
    }
	return 1;
}

forward loadgraffs();
forward spraying(playerid);
forward sprayingch(playerid);
forward killgr(playerid);
forward creategraff(playerid);

public loadgraffs()
{

	for(new ID = 0; ID < MAXGRAFFS; ID++)
	{
		gInfo[ID][OBJECTID] = CreateDynamicObject( 19482, gInfo[ID][Xpos],gInfo[ID][Ypos],gInfo[ID][Zpos], gInfo[ID][XYpos], gInfo[ID][YYpos], gInfo[ID][ZYpos], -1, 0, -1, 200 ); //Creating the object
		SetDynamicObjectMaterialText( gInfo[ID][OBJECTID], 0, gInfo[ID][graffname], OBJECT_MATERIAL_SIZE_256x256, "Diploma", 25, 0, 0xFFFFFFFF, 0, 1 ); // Setting the object text with our choosen graffiti text
		gammount ++;
	}
	return 1;
}
public creategraff( playerid )
{
	GetPlayerPos(playerid, XYZ[playerid][0], XYZ[playerid][1], XYZ[playerid][2]);
    DestroyDynamicObject( POBJECT[playerid] ); // Destroying old sprayobject
    POBJECT[playerid] = CreateDynamicObject( 19482, XYZ[playerid][0], XYZ[playerid][1], XYZ[playerid][2], 0.0, 0.0, 0.0, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), -1, 200 ); //Creating the object
	SetDynamicObjectMaterialText( POBJECT[playerid], 0, POBJECTN[playerid], OBJECT_MATERIAL_SIZE_256x256, "Diploma", 25, 0, 0xFFFFFFFF, 0, 1 ); 
	GameTextForPlayer( playerid, "~w~Sprayed",5000,5 ); 
	new id = nGraffiti();
	sprayammount[playerid] = 0;
	GRAVEH[playerid] = 0;
	isveh[playerid] = 0;
	sprays ++;
	new string[20];
	format(string, sizeof(string),Graffitis, id);
	dini_Create(string);
	strmid(gInfo[id][graffname] , POBJECTN[playerid], 0, strlen(POBJECTN[playerid]), 32);
	gInfo[id][graffcreator] = pData[playerid][pName];
	gInfo[id][OBJECTID] = POBJECT[playerid];
	gInfo[id][Xpos] = XYZ[playerid][0];
	gInfo[id][Ypos] = XYZ[playerid][1];
	gInfo[id][Zpos] = XYZ[playerid][2];
	gInfo[id][XYpos] = 0.0;
	gInfo[id][YYpos] = 0.0;
	gInfo[id][ZYpos] = 0.0;
	EditDynamicObject(playerid, gInfo[id][OBJECTID]);
	GetPVarInt( playerid, "GraffitiCreating" );
	SaveGraffitis();
	return 1;
}
public killgr(playerid)
{
    sprayammount[playerid] = 0;
   	DeletePVar( playerid,"GraffitiCreating" );
	sprayammountch[playerid] = 0;
	graffmenup[playerid] = 0;
	return 1;
}

public sprayingch( playerid )
{
	graffmenup[playerid] ++;

	if( graffmenup[playerid] == 5 )
	{
		KillTimer( spraytimerch[playerid] );
	    ShowPlayerDialog(playerid, DIALOG_SELECT, DIALOG_STYLE_LIST, "Graffiti Menu", "Enter Graffiti Text", "Select", "Exit");
	 	return 1;
	}
	new string[64];
	format( string, sizeof(string),"Spraying ~r~%d/5", graffmenup[playerid]);
	InfoTD_MSG(playerid, 1000, string);
	return 1;
}
forward startgraff(playerid);
public startgraff (playerid)
{
	new	Float:X[3];
	GetPlayerPos( playerid, X[0], X[1], X[2] );
	POBJECT[playerid] = CreateDynamicObject( 19482, X[0], X[1], X[2], 0.0, 0.0, 0.0, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), playerid, 200 );
	SetDynamicObjectMaterialText( POBJECT[playerid], 0, POBJECTN[playerid], OBJECT_MATERIAL_SIZE_256x256, "Diploma", 26, 0, 0xFFFFFFFF, 0, 1 );
	SetPVarInt( playerid, "GraffitiCreating",1 );
	return 1;
}
CMD:tags(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_GOMENU, DIALOG_STYLE_LIST, "Graffiti Menu", "Edit Text (Soon)\nDelete Text", "Select", "Exit");
	return 1;
}
CMD:dtag(playerid)
{
    DestroyDynamicObject(POBJECT[playerid]);
    InfoTD_MSG(playerid, 4000, "Text ~r~Removed");
    return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	//graf
	if(dialogid == DIALOG_SELECT)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0: ShowPlayerDialog(playerid, DIALOG_INPUTGRAFF, DIALOG_STYLE_INPUT, "Graffiti", "Please Enter Graffiti text", "Continue", "Cancel");
            }
        }
        return 1;
    }
    if(dialogid == BUY_SPRAYCAN)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0: GivePlayerMoneyEx(playerid, -70), GivePlayerWeaponEx(playerid, 41, 300);
                case 1: GivePlayerMoneyEx(playerid, -120), GivePlayerWeaponEx(playerid, 41, 500);
                case 2: GivePlayerMoneyEx(playerid, -200), GivePlayerWeaponEx(playerid, 41, 900);
            }
        }
        return 1;
    }
    if(dialogid == DIALOG_LIST)
    {
        if(response)
        {
            new id = listitem;
           	new string[128];
			format(string, sizeof(string),"/Graffitis/%d.ini",id);
			if(!IsPlayerAdmin(playerid)) return GameTextForPlayer( playerid, "~r~You are not authorized \nto delete Graffitis!]",10000,5);
			if(!fexist(string))
			{
				format(string,sizeof(string),"~y~]~r~Something went wrong, try again~y~]",id);
				GameTextForPlayer(playerid, string,7000,3);
				return 1;
			}
    		fremove(string);
    		format(string,sizeof(string),"~y~]~g~Graffiti ~r~%d ~g~Succefully removed!~y~]",id);
    		GameTextForPlayer(playerid, string,7000,3);
    		DestroyDynamicObject( gInfo[id][OBJECTID] );
        }
        else return ShowPlayerDialog(playerid, DIALOG_SELECT, DIALOG_STYLE_LIST, "Graffiti Menu", "Enter Graffiti Text\nGraffiti List", "Select", "Exit");
        return 1;
    }


    if(dialogid == DIALOG_COLOR)
    {
        if(response)
        {

            switch(listitem)
            {

                case 0: POBJECTC[playerid] = "000000";// BLACK

                case 1: POBJECTC[playerid] = "FFFFFF"; // WHITE

                case 2: POBJECTC[playerid] = "F81414"; // RED

                case 3: POBJECTC[playerid] = "00FF22"; // GREEN

                case 4: POBJECTC[playerid] = "00CED1"; // LIGHTBLUE

                case 5: POBJECTC[playerid] = "C3C3C3";  // GREY


            }
			new string[128];
   			new string2[96];
			format(string2, sizeof(string2),"{%s}%s", POBJECTC[playerid], POBJECTN[playerid]);
   			POBJECTN[playerid] = string2;
			format(string,sizeof(string), ""COL_WHITE"Are you happy with your Color?\n"COL_ORANGE"%s (Points to spray %d)1 point/second", string2, sprayammountch[playerid]);
 			ShowPlayerDialog(playerid, DIALOG_HAPPY, DIALOG_STYLE_MSGBOX, "Graffiti Menu", string, "Yes", "No");
        }
        else return ShowPlayerDialog(playerid, DIALOG_INPUTGRAFF, DIALOG_STYLE_INPUT, "Graffiti", "Please Enter Graffiti text", "Continue", "Cancel");
        return 1;
    }
    if(dialogid == DIALOG_GDOBJECT)
	{
	    if(response)
	    {
	        DestroyDynamicObject(POBJECT[playerid]);
    		InfoTD_MSG(playerid, 4000, "Text ~r~Removed");
	   	}
	}
   	if(dialogid == DIALOG_GOMENU)
	{
	    if(response)
	    {
	   		switch (listitem)
			{
			    case 0:
			    {

			    }
			    case 1:
			    {
			    	DestroyDynamicObject(POBJECT[playerid]);
    				InfoTD_MSG(playerid, 4000, "Text ~r~Removed");
			    }
			}
	   	}
	}
    if(dialogid == DIALOG_HAPPY)
    {
        if(response)
        {
            creategraff(playerid);
        }
        else
        {
			ShowPlayerDialog(playerid, DIALOG_INPUTGRAFF, DIALOG_STYLE_INPUT, "Graffiti", "Please Enter Graffiti text", "Continue", "Cancel");
        }
        return 1;
    }


	if(dialogid == DIALOG_INPUTGRAFF)
    {
        if(!response) return ShowPlayerDialog(playerid, DIALOG_SELECT, DIALOG_STYLE_LIST, "Graffiti Menu", "Enter Graffiti Text", "Select", "Exit");

       	if(isnull(inputtext)) return ShowPlayerDialog(playerid, DIALOG_INPUTGRAFF, DIALOG_STYLE_INPUT, ""COL_WHITE"Graffiti", ""COL_RED"ERROR: No text was written \nPlease try again!", "Continue", "Cancel");
       	else
       	{
       	    new string[96];
       	    format(string, sizeof(string),"%s",inputtext);
       	    POBJECTN[playerid] = string;
       	    sprayammountch[playerid] = strlen(string);
       	    ShowPlayerDialog(playerid, DIALOG_COLOR, DIALOG_STYLE_LIST, "Color Menu", "{000000}Black\n{FFFFFF}White\n{F81414}Red\n{00FF22}Green\n{00CED1}Lightblue\n{C3C3C3}Grey", "Select", "Exit");
		}
        return 1;
    }
    //end
    return 1;
}
