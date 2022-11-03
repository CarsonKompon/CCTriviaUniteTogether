--Trivia Unite Together Installer

--Create folder structure
if not fs.exists(".triviaunite/") then
  shell.run("mkdir .triviaunite")
  shell.run("mkdir .triviaunite/dependencies")
  shell.run("mkdir .triviaunite/images")

  --Download required APIs
  shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUniteTogether/main/.triviaunite/dependencies/bigfont.lua .triviaunite/dependencies/bigfont")
  shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUniteTogether/main/.triviaunite/dependencies/json.lua .triviaunite/dependencies/json")

  --Download Trivia Unite Images
  shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUniteTogether/main/.triviaunite/images/logo.nfp .triviaunite/images/logo.nfp")
  shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUniteTogether/main/.triviaunite/images/diamond1.nfp .triviaunite/images/diamond1.nfp")
  shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUniteTogether/main/.triviaunite/images/diamond2.nfp .triviaunite/images/diamond2.nfp")
  shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUniteTogether/main/.triviaunite/images/diamond3.nfp .triviaunite/images/diamond3.nfp")
  shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUniteTogether/main/.triviaunite/images/diamond4.nfp .triviaunite/images/diamond4.nfp")
end

--Download Trivia Unite
shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUniteTogether/main/triviaunitetogether.lua triviaunitetogether")

--Reboot Computer
print("Trivia Unite Together installed successfully!")