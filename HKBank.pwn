/*
HKBank - An advanced bank system which uses Dialogs and Clickable Textdraws.

Credits - [HK]Ryder[AN]
		  Y_Less
		  ZeeX
		  iPLEOMAX
*/
#include <a_samp>
#include <YSI\y_ini>
#include <zcmd>
//Textdraws
new PlayerText:Textdraw0[MAX_PLAYERS];
new PlayerText:Textdraw1[MAX_PLAYERS];
new PlayerText:Textdraw2[MAX_PLAYERS];
//Defines
#define PATH "HKBank/%s.ini"
#define DIALOG_LOGIN 998
#define DIALOG_REGISTER 999
#define DIALOG_MAIN 1000
#define DIALOG_WITHDRAW 1001
#define DIALOG_DEPOSIT 1002
#define DIALOG_STATS 1003
//Whirlpool
native WP_Hash(buf[], len, const str[]);
//Player Bank Info
enum bInfo {
	bPass[129],
	bWealth,
}
new BankInfo[MAX_PLAYERS][bInfo];
public OnFilterScriptInit()
{
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}
public OnPlayerConnect(playerid)
{
    Textdraw0[playerid] = CreatePlayerTextDraw(playerid, 403.600006, 148.593338, "usebox");
	PlayerTextDrawLetterSize(playerid, Textdraw0[playerid], 0.000000, 13.952963);
	PlayerTextDrawTextSize(playerid, Textdraw0[playerid], 228.400009, 0.000000);
	PlayerTextDrawAlignment(playerid, Textdraw0[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw0[playerid], 0);
	PlayerTextDrawUseBox(playerid, Textdraw0[playerid], true);
	PlayerTextDrawBoxColor(playerid, Textdraw0[playerid], 102);
	PlayerTextDrawSetShadow(playerid, Textdraw0[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw0[playerid], 0);
	PlayerTextDrawFont(playerid, Textdraw0[playerid], 0);
	
	Textdraw1[playerid] = CreatePlayerTextDraw(playerid, 240.000015, 167.253311, "Create a New Account");
	PlayerTextDrawLetterSize(playerid, Textdraw1[playerid], 0.289999, 1.622400);
	PlayerTextDrawAlignment(playerid, Textdraw1[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw1[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Textdraw1[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw1[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw1[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw1[playerid], 2);
	PlayerTextDrawSetProportional(playerid, Textdraw1[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, Textdraw1[playerid], true);
	
	Textdraw2[playerid] = CreatePlayerTextDraw(playerid, 233.599975, 218.026733, "Login to an Existing Account");
	PlayerTextDrawLetterSize(playerid, Textdraw2[playerid], 0.245199, 1.719465);
	PlayerTextDrawAlignment(playerid, Textdraw2[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw2[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Textdraw2[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw2[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw2[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw2[playerid], 2);
	PlayerTextDrawSetProportional(playerid, Textdraw2[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, Textdraw2[playerid], true);
	
	if(!fexist(pBankAccount(playerid)))
	{
	    SendClientMessage(playerid, -1, "You don't have a bank account yet. Please use /bank to register one");
	}
	else if(fexist(pBankAccount(playerid)))
	{
	    INI_ParseFile(pBankAccount(playerid), "LoadUser_%s", .bExtra = true, .extra = playerid);
	}
	return 1;
}
CMD:bank(playerid, params[])
{
	PlayerTextDrawShow(playerid, Textdraw0[playerid]);
	PlayerTextDrawShow(playerid, Textdraw1[playerid]);
	PlayerTextDrawShow(playerid, Textdraw2[playerid]);
	SelectTextDraw(playerid, 0x00FF00FF);
	return 1;
}
public OnPlayerDisconnect(playerid, reason)
{
    if(fexist(pBankAccount(playerid)))
    {
        new INI:file = INI_Open(pBankAccount(playerid));
        INI_WriteInt(file, "BankCash", BankInfo[playerid][bWealth]);
		INI_Close(file);
	}
	return 1;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_REGISTER)
	{
	    if(!response)
	    {
	        SendClientMessage(playerid, -1, "You cancelled bank registration");
		}
		else
		{
		    if(!fexist(pBankAccount(playerid)))
		    {
		    	if(strlen(inputtext) < 4) return SendClientMessage(playerid, -1, "Your password must be atleast 4 characters");
		    	new Hash[129], PassString[128];
		    	new INI:file = INI_Open(pBankAccount(playerid));
		    	WP_Hash(Hash, sizeof(Hash), inputtext);
		    	INI_WriteString(file, "BankPassword", Hash);
		    	INI_WriteInt(file, "BankCash", 0);
		    	INI_Close(file);
		    	INI_ParseFile(pBankAccount(playerid), "LoadUser_%s", .bExtra = true, .extra = playerid);
		    	format(PassString, sizeof(PassString), "Thank You For Registering. You bank password is %s", inputtext);
		   		SendClientMessage(playerid, -1, PassString);
		   		ShowPlayerDialog(playerid, DIALOG_MAIN, DIALOG_STYLE_LIST, "HKBank", "Withdraw\nDeposit\nStats", "Ok", "Cancel");
			}
			else
			{
			    SendClientMessage(playerid, -1, "You already have a bank account");
			    return 0;
			}
		}
	}
	if(dialogid == DIALOG_LOGIN)
	{
	    if(!response)
	    {
	        SendClientMessage(playerid, -1, "You cancelled the option");
		}
		else
		{
		    if(!fexist(pBankAccount(playerid)))
		    {
		        SendClientMessage(playerid, -1, "You don't have a bank account");
			}
			else
			{
			    if(!strcmp(inputtext, BankInfo[playerid][bPass], true))
			    {
			        ShowPlayerDialog(playerid, DIALOG_MAIN, DIALOG_STYLE_LIST, "HKBank", "Withdraw\nDeposit\nStats", "Ok", "Cancel");
				}
				else
				{
				    SendClientMessage(playerid, -1, "Wrong Password. Please try again.");
				    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "HKBank", "Please type your password to login into your bank account", "Login", "Cancel");
				}
			}
		}
	}
	if(dialogid == DIALOG_MAIN)
	{
	    if(!response)
	    {
			SendClientMessage(playerid, -1, "You cancelled the selection");
		}
		else
		{
		    if(listitem == 0)
		    {
		        ShowPlayerDialog(playerid, DIALOG_WITHDRAW, DIALOG_STYLE_INPUT, "HKBank", "Enter the amount of money you want to withdraw", "OK", "Cancel");
			}
			if(listitem == 1)
			{
			    ShowPlayerDialog(playerid, DIALOG_DEPOSIT, DIALOG_STYLE_INPUT, "HKBank", "Enter the amount of money you want to deposit", "OK", "Cancel");
			}
			if(listitem == 2)
			{
			    new string[128];
			    format(string, sizeof(string), "You Have $%i on your account", BankInfo[playerid][bWealth]);
			    ShowPlayerDialog(playerid, DIALOG_STATS, DIALOG_STYLE_MSGBOX, "HKBank", string, "OK", "");
			}
		}
	}
	if(dialogid == DIALOG_WITHDRAW)
	{
	    if(!response)
	    {
	        SendClientMessage(playerid, -1, "You cancelled the selection");
	        ShowPlayerDialog(playerid, DIALOG_MAIN, DIALOG_STYLE_LIST, "HKBank", "Withdraw\nDeposit\nStats", "Ok", "Cancel");
		}
		else
		{
		    if(!isnumeric(inputtext)) return SendClientMessage(playerid, -1, "Please enter a valid amount");
		    if(strval(inputtext) > BankInfo[playerid][bWealth]) return SendClientMessage(playerid, -1, "You dont have that much money in your bank account");
		    BankInfo[playerid][bWealth] = (BankInfo[playerid][bWealth] - strval(inputtext));
		    GivePlayerMoney(playerid, strval(inputtext));
			new String[128];
			format( String, sizeof String, "You withdrew $%i from your bank", strval(inputtext));
			SendClientMessage(playerid, -1, String);
			ShowPlayerDialog(playerid, DIALOG_MAIN, DIALOG_STYLE_LIST, "HKBank", "Withdraw\nDeposit\nStats", "Ok", "Cancel");
		}
	}
	if(dialogid == DIALOG_DEPOSIT)
	{
	    if(!response)
	    {
	        SendClientMessage(playerid, -1, "You cancelled the selection");
	        ShowPlayerDialog(playerid, DIALOG_MAIN, DIALOG_STYLE_LIST, "HKBank", "Withdraw\nDeposit\nStats", "Ok", "Cancel");
		}
		else
		{
		    if(!isnumeric(inputtext)) return SendClientMessage(playerid, -1, "Please enter a valid amount");
		    if(GetPlayerMoney(playerid) < strval(inputtext)) return SendClientMessage(playerid, -1, "You don't have that much money");
			BankInfo[playerid][bWealth] = (BankInfo[playerid][bWealth] + strval(inputtext));
			GivePlayerMoney(playerid, -strval(inputtext));
			new string[128];
			format(string, sizeof(string), "You deposited $%i to your bank account", strval(inputtext));
			SendClientMessage(playerid, -1, string);
			ShowPlayerDialog(playerid, DIALOG_MAIN, DIALOG_STYLE_LIST, "HKBank", "Withdraw\nDeposit\nStats", "Ok", "Cancel");
		}
	}
	return 1;
}
public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if(playertextid == Textdraw1[playerid])
    {
   		if(!fexist(pBankAccount(playerid)))
        {
       		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "HKBank", "Enter a password to register your bank account", "Enter", "Cancel");
       		PlayerTextDrawHide(playerid, Textdraw0[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw1[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw2[playerid]);
         	CancelSelectTextDraw(playerid);
		}
		else if(fexist(pBankAccount(playerid)))
		{
		    SendClientMessage(playerid, -1, "You already have a bank account.");

		}
    }
    if(playertextid == Textdraw2[playerid])
    {
        if(fexist(pBankAccount(playerid)))
        {
			ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "HKBank", "Please type your password to login into your bank account", "Login", "Cancel");
            PlayerTextDrawHide(playerid, Textdraw0[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw1[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw2[playerid]);
			CancelSelectTextDraw(playerid);
		}
		else if(!fexist(pBankAccount(playerid)))
		{
		    SendClientMessage(playerid, -1, "You don't have a bank account. Please register first");

		}
	}
    return 1;
}
public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
//Loaduser Public
forward LoadUser_data(playerid, name[], value[]);
public LoadUser_data(playerid, name[], value[])
{
	INI_Int("BankCash", BankInfo[playerid][bWealth]);
	INI_String("BankPassword", BankInfo[playerid][bPass], 129);
	return 1;
}
//Stocks
stock pBankAccount(playerid)
{
    new string[50];
    format(string, sizeof(string), PATH, GetName(playerid));
    return string;
}

stock GetName(playerid)
{
    new name[24];
    GetPlayerName(playerid, name, sizeof(name));
    return name;
}
