--Trivia Unite Together Installer

--Download required APIs
shell.run("pastebin get 3LfWxRWh bigfont")
shell.run("pastebin get 4nRg9CHU json")

--Download Trivia Unite Images
shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUniteTogether/main/logo.nfp logo.nfp")
shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUniteTogether/main/diamond.nfp diamond.nfp")
shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUniteTogether/main/diamond1.nfp diamond1.nfp")
shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUniteTogether/main/diamond2.nfp diamond2.nfp")
shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUniteTogether/main/diamond3.nfp diamond3.nfp")

--Download Trivia Unite Together
shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUniteTogether/main/startup.lua startup.lua")

--Reboot Computer
shell.run("reboot")