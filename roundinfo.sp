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
//cont String bracketText = "QUINDALI PUGS";

//Variables for game info
ConVar g_RedTeamName;
ConVar g_BlueTeamName;
ConVar g_Tournament;
ConVar g_TimeLimit;
bool roundLive = false;
int currentRound = 0;

public void OnPluginStart() {
	//yeet
	g_RedTeamName = FindConVar("mp_tournament_redteamname");
	g_BlueTeamName = FindConVar("mp_tournament_blueteamname");
	g_Tournament = FindConVar("mp_tournament");
	g_TimeLimit = FindConVar("mp_timelimit");

	HookEvent("teamplay_round_start", Event_RoundStart);
}

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

	if (roundLive) {
		//inner yeet
		//Get Team Names
		char redName[256];
		g_RedTeamName.GetString(redName, sizeof(redName));
		char bluName[256];
		g_BlueTeamName.GetString(bluName, sizeof(bluName));

		//Print Round Info
		CPrintToChatAll("{mediumpurple}[Quindali Pugs]{default} Current score: {blue}%s{default} %i, {red}%s{default} %i.", bluName, GetTeamScore(BLU_ID), redName, GetTeamScore(RED_ID));

		//Print Timeleft and Round number IF NOT KOTH
		//TODO: Current Round visible if KOTH?
		currentRound++;
		int timeleft = RoundToFloor(GetTimeLeft());
		if (g_TimeLimit.IntValue != 0) {
			//double inner yeet
			CPrintToChatAll("{mediumpurple}[Quindali Pugs]{default} %i:%02i remaining; starting round %i.", timeleft / 60, timeleft % 60, currentRound);
		}
	}
}

public void OnMapStart() {
	//yeet
	roundLive = false;
	currentRound = 0;
}

//Get "Accurate" time left
//Shamelessly borrowed from tsc and compctrl
float GetTimeLeft() {
	float startTime = GameRules_GetPropFloat("m_flMapResetTime");
	float timeLimit = float(g_TimeLimit.IntValue * 60);
	float currentTime = GetGameTime();

	return (startTime + timeLimit) - currentTime;
}
