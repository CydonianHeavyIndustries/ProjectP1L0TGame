const { REST, Routes, SlashCommandBuilder } = require('discord.js');

const DISCORD_TOKEN = process.env.DISCORD_TOKEN;
const DISCORD_CLIENT_ID = process.env.DISCORD_CLIENT_ID;
const GUILD_ID = process.env.DISCORD_GUILD_ID;

if (!DISCORD_TOKEN || !DISCORD_CLIENT_ID) {
  console.error('Missing DISCORD_TOKEN or DISCORD_CLIENT_ID env vars.');
  process.exit(1);
}

const command = new SlashCommandBuilder()
  .setName('lorekeeper')
  .setDescription('Start a lorekeeper session in this channel.')
  .addStringOption((opt) =>
    opt
      .setName('repo')
      .setDescription('Wiki repo URL override')
      .setRequired(false)
  );

const rest = new REST({ version: '10' }).setToken(DISCORD_TOKEN);
const body = [command.toJSON()];

(async () => {
  try {
    if (GUILD_ID) {
      await rest.put(Routes.applicationGuildCommands(DISCORD_CLIENT_ID, GUILD_ID), { body });
      console.log('Registered guild commands.');
    } else {
      await rest.put(Routes.applicationCommands(DISCORD_CLIENT_ID), { body });
      console.log('Registered global commands.');
    }
  } catch (err) {
    console.error(err.message || err);
    process.exit(1);
  }
})();
