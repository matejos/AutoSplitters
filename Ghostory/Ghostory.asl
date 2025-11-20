/*
 * Ghostory has intentional support for Autosplitters built into the game. The data is exposed
 * through the static class "AutosplitData", which has the following fields:

    /// <summary>
	/// The current state of the game in human readable format.
	/// 
	/// Possible values are: 
	/// "Main Menu", "Entering Level", "Playing", "Exiting Level", "Cutscene", "Menu", "Victory", or null.
	/// </summary>
	public static string gameState = null;

	/// <summary>
	/// The index of the level the player is in. -1 if not in a level.
	/// </summary>
	public static int levelIndex = -1;

	/// <summary>
	/// The in-game time for the current attempt on this level.
	/// </summary>
	public static float attemptTime = 0f;

	/// <summary>
	/// The total playtime of this game session.
	/// </summary>
	public static float totalPlaytime = 0f;

	/// <summary>
	/// The number of chalices that you have collected.
	/// </summary>
	public static int chaliceCount = 0;

	/// <summary>
	/// The total number of jumps in this game session.
	/// </summary>
	public static int jumpCount = 0;

 *
 * If you have an idea for a new speedrun category that can't be autosplit with these values,
 * jump into Ghostory Steam discussion forum and let the game's developer (me!) know.
 */

state("Ghostory") {}

startup
{
    vars.Unity = Assembly.Load(File.ReadAllBytes(@"Components\UnityASL.bin")).CreateInstance("UnityASL.Unity");
}

init
{
    vars.Unity.TryOnLoad = (Func<dynamic, bool>)(helper => {
        var myClass = helper.GetClass("Assembly-CSharp", "AutosplitData");
        vars.Unity.MakeString(myClass.Static, myClass["gameState"]).Name = "gameState";
        vars.Unity.Make<int>(myClass.Static, myClass["levelIndex"]).Name = "levelIndex";
        vars.Unity.Make<float>(myClass.Static, myClass["attemptTime"]).Name = "attemptTime";
        vars.Unity.Make<float>(myClass.Static, myClass["totalPlaytime"]).Name = "totalPlaytime";
        vars.Unity.Make<int>(myClass.Static, myClass["chaliceCount"]).Name = "chaliceCount";
        vars.Unity.Make<int>(myClass.Static, myClass["jumpCount"]).Name = "jumpCount";
        return true;
    });

    vars.Unity.Load(game);
}

update
{
    if (!vars.Unity.Loaded) return false;
    vars.Unity.Update();
}

start
{
    // Start the timer when you start to control the character.
    if (vars.Unity["gameState"].Changed && vars.Unity["gameState"].Current == "Playing") {
        return true;
    }
}

split
{
    // 0 is main menu, 1-40 are playable levels, 41 is credits scene.
    if (
      vars.Unity["levelIndex"].Changed &&
      vars.Unity["levelIndex"].Current > 0 &&
      vars.Unity["levelIndex"].Current < 41
    ) {
      return true;
    }
    
    // Hitting the Victory game state is the final split
    if (vars.Unity["gameState"].Changed && vars.Unity["gameState"].Current == "Victory") {
        return true;
    }  
}

isLoading
{
    // Pause the timer any time when you're not controlling the character.
    return vars.Unity["gameState"].Current != "Playing";
}

reset 
{
    // Reset when returned to menu.
    if (vars.Unity["levelIndex"].Changed && vars.Unity["levelIndex"].Current == 0) {
        return true;
    }
}

exit
{
    vars.Unity.Reset();
}

shutdown
{
    vars.Unity.Reset();
}