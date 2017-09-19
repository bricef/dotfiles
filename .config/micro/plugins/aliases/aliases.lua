

function MakeAlias(arg)
	messenger:Message("Command was: " .. arg)
end

MakeCommand("alias", "aliases.MakeAlias", 0)