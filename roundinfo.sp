#include <sourcemod>
#include <sdktools>
#include <morecolors>

/*
 * Plugin Info
 */
public Plugin myinfo = {
	name = "RoundInfo",
	description = "Displays round info similarly to CompCtrl on PugChamp",
	author = "Squidamtron",
	version = "6.9",
	url = "https://something.com"
}

//Constants for identifying teams
const int BLU_ID = 3;
const int RED_ID = 2;

//Variables for game info
ConVar g_RedTeamName;
ConVar g_BlueTeamName;
ConVar g_Tournament;
ConVar g_TimeLimit;
ConVar g_BracketText;
ConVar g_BracketColor;
ConVar g_MiscColor;
ConVar g_TextEnable;
bool roundLive = false;
int currentRound = 0;

/* OnPluginStart()
 * 
 * Called when plugin is loaded
 * Sets up literally whatever
 * PSST START HERE FOR MOST THINGS
 *
 */
public void OnPluginStart() {
	//yeet
	g_RedTeamName = FindConVar("mp_tournament_redteamname");
	g_BlueTeamName = FindConVar("mp_tournament_blueteamname");
	g_Tournament = FindConVar("mp_tournament");
	g_TimeLimit = FindConVar("mp_timelimit");

	g_BracketText = CreateConVar("sm_roundinfo_btext", "Round Info", "Overrides the plugin name in the bracketed text.");
	g_BracketColor = CreateConVar("sm_roundinfo_bcolor", "green", "Changes the color of the bracketed text.");
	g_MiscColor = CreateConVar("sm_roundinfo_mcolor", "olive", "Changes the color of scores, timeleft, and round number.");
	g_TextEnable = CreateConVar("sm_roundinfo_enable", "1", "Enables/Disables the text output.", FCVAR_NONE, true, 0.0, true, 1.0);

	RegAdminCmd("sm_roundinfo_test", Test_Output, ADMFLAG_GENERIC, "Tests the output of the plugin to test colors, etc.");
	RegAdminCmd("sm_roundinfo_rc", Console_Output, ADMFLAG_GENERIC, "Prints round info in the console; for use with rcon.");

	HookEvent("teamplay_round_start", Event_RoundStart);
}

/* Event_RoundStart()
 *
 * Called when round starts
 * Displays text about score, timeleft and round number
 *
 */
public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
	//yeet
	//Get team ready status
	new redReady = GameRules_GetProp("m_bTeamReady", 1, RED_ID);
	new bluReady = GameRules_GetProp("m_bTeamReady", 1, BLU_ID);

	//Check if both teams are ready AND tournament mod is active
	//before putting any text into chat
	if (bluReady && redReady && g_Tournament) {
		roundLive = true;
		currentRound = 0;
	}

	//TODO Modularize most of the text? (More cvars?)
	if (roundLive && g_TextEnable) {
		//inner yeet
		//Get Team Names
		char redName[256];
		g_RedTeamName.GetString(redName, sizeof(redName));
		char bluName[256];
		g_BlueTeamName.GetString(bluName, sizeof(bluName));

		//Get cvar values
		char btext[128];
		g_BracketText.GetString(btext, sizeof(btext));
		char bcolor[128];
		g_BracketColor.GetString(bcolor, sizeof(bcolor));
		char mcolor[128];
		g_MiscColor.GetString(mcolor, sizeof(mcolor));

		//Print Round Info
		CPrintToChatAll("{%s}[%s]{default} Current score: {blue}%s{default} {%s}%i{default}, {red}%s{default} {%s}%i{default}.", bcolor, btext, bluName, mcolor, GetTeamScore(BLU_ID), redName, mcolor, GetTeamScore(RED_ID));

		//Print Timeleft and Round number IF NOT KOTH
		//TODO Current Round visible if KOTH?
		currentRound++;
		int timeleft = RoundToFloor(GetTimeLeft());
		if (g_TimeLimit.IntValue != 0) {
			//double inner yeet
			CPrintToChatAll("{%s}[%s]{default} {%s}%i:%02i{default} remaining; starting round {%s}%i{default}.", bcolor, btext, mcolor, timeleft / 60, timeleft % 60, mcolor, currentRound);
		}
	}
}

/* OnMapStart()
 * 
 * Called when map starts
 * Resets roundLive and currentRound
 * Stops from displaying RoundInfo text on map change
 * 
 */
public void OnMapStart() {
	//yeet
	roundLive = false;
	currentRound = 0;
}

/* Test_Output()
 * 
 * Called when `sm_roundinfo_test` is run in console
 * Outputs dummy info to test visuals
 *
 */
public Action Test_Output(int client, int args) {
	//yeeet
	if(roundLive) {
		//inneryeet
		CPrintToChat(client, "Round is live! Should you really be doing this right now?");

		return Plugin_Handled;
	}

	//Get cvar values
	char btext[128];
	g_BracketText.GetString(btext, sizeof(btext));
	char bcolor[128];
	g_BracketColor.GetString(bcolor, sizeof(bcolor));
	char mcolor[128];
	g_MiscColor.GetString(mcolor, sizeof(mcolor));

	CPrintToChat(client, "{%s}[%s]{default} Current score: {blue}BLU{default} {%s}4{default}, {red}RED{default} {%s}3{default}.", bcolor, btext, mcolor, mcolor);
	CPrintToChat(client, "{%s}[%s]{default} {%s}13:37{default} remaining; starting round {%s}8{default}.", bcolor, btext, mcolor, mcolor);

	return Plugin_Handled;
	
}

/* Console_Output()
 *
 * Called when `sm_roundinfo_rc` is run in console
 * Puts score and timeleft into console for rcon and whatnot
 *
 */
public Action Console_Output(int client, int args) {
	//yeet
	if(roundLive) {
		//inneryeet
		int timeleft = RoundToFloor(GetTimeLeft());
		PrintToConsole(client, "BLU: %i", GetTeamScore(BLU_ID));
		PrintToConsole(client, "RED: %i", GetTeamScore(RED_ID));
		PrintToConsole(client, "Time: %i:%02i", timeleft / 60, timeleft % 60);
		return Plugin_Handled;
	}
	
	PrintToConsole(client, "Game hasn't started yet.");
	return Plugin_Handled;
}

/* GetTimeLeft()
 *
 * Gets accurate round time remaining
 * Shamelessly borrowed from tsc and CompCtrl
 * Does not like `mp_timelimit 0`
 * 
 */
float GetTimeLeft() {
	float startTime = GameRules_GetPropFloat("m_flMapResetTime");
	float timeLimit = float(g_TimeLimit.IntValue * 60);
	float currentTime = GetGameTime();

	return (startTime + timeLimit) - currentTime;
}
