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
bool roundLive = false;
int currentRound = 0;

//const String bracketText = "QUINDALI PUGS";

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
	if (roundLive) {
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
		g_MiscColor.GetString(mcolor, sizeof(bcolor));

		//Print Round Info
		//CPrintToChatAll("{mediumpurple}[Quindali Pugs]{default} Current score: {blue}%s{default} %i, {red}%s{default} %i.", bluName, GetTeamScore(BLU_ID), redName, GetTeamScore(RED_ID));
		CPrintToChatAll("{%s}[%s]{default} Current score: {blue}%s{default} {%s}%i{default}, {red}%s{default} {%s}%i{default}.", bcolor, btext, bluName, mcolor, GetTeamScore(BLU_ID), redName, mcolor, GetTeamScore(RED_ID));

		//Print Timeleft and Round number IF NOT KOTH
		//TODO Current Round visible if KOTH?
		currentRound++;
		int timeleft = RoundToFloor(GetTimeLeft());
		if (g_TimeLimit.IntValue != 0) {
			//double inner yeet
			//CPrintToChatAll("{mediumpurple}[Quindali Pugs]{default} %i:%02i remaining; starting round %i.", timeleft / 60, timeleft % 60, currentRound);
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
