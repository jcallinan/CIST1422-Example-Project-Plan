<#
  setup-example-project.ps1
  Builds the "Lantern Keeper" example GitHub Project for CIST 1422:
    - pushes the README (sample GDD summary + how-to for students) to YOUR EXISTING repo
    - labels, five dated milestones, and ~26 issues with acceptance criteria
    - a GitHub Project (v2) linked to the repo, with Scope / Estimate / Target date
      fields filled in and a realistic mix of Todo / In Progress / Done

  Requirements: GitHub CLI (https://cli.github.com) and git, logged in as the repo owner.
  Put this script and README.md in your cloned repo folder, then run from that folder:
      gh auth refresh -s project        # one time: lets gh create Projects
      .\setup-example-project.ps1

  The repo is detected from the folder you run it in (its GitHub remote).
  Safe to re-run: anything that already exists (milestones, the project, issues
  with the same title) is reused or skipped instead of duplicated.

  Afterwards (GitHub's API can't create views — about one minute in the browser):
    1. Open the project, rename the default view to "Board", and switch its layout to Board.
    2. New view -> Roadmap, set dates to "Target date", group by Milestone.
    3. New view -> Table, group by Scope, show the Estimate (hrs) field sum.
#>

# ---------- Settings: edit these ----------
$ProjectTitle = 'Lantern Keeper - Example Project Plan'
$Milestones = [ordered]@{
  'Plan Approved' = @{ Due = '2026-10-27'; Desc = 'GDD and project board submitted and approved' }
  'Prototype'     = @{ Due = '2026-11-10'; Desc = 'Core loop playable with greybox art' }
  'Alpha'         = @{ Due = '2026-11-24'; Desc = 'Every Must-have feature implemented' }
  'Beta'          = @{ Due = '2026-12-01'; Desc = 'Content complete, playtested, bug fixing' }
  'Final Build'   = @{ Due = '2026-12-08'; Desc = 'Windows build, presentation, credits' }
}
# ------------------------------------------

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Invoke-Gh {
  # Runs gh and stops the script if it fails.
  $out = & gh @args
  if ($LASTEXITCODE -ne 0) { throw "gh $($args -join ' ') failed (exit $LASTEXITCODE)" }
  return $out
}
function Invoke-GhJson { ((Invoke-Gh @args) -join "`n") | ConvertFrom-Json }

$Labels = @(
  @{ Name = 'gameplay'; Color = '1D76DB'; Desc = 'Mechanics and game logic' }
  @{ Name = 'ui';       Color = '5319E7'; Desc = 'Menus, HUD, screens' }
  @{ Name = 'art';      Color = 'E99695'; Desc = 'Sprites, tiles, animation' }
  @{ Name = 'audio';    Color = 'F9D0C4'; Desc = 'Music and sound effects' }
  @{ Name = 'tech';     Color = '0E8A16'; Desc = 'Project setup, builds, tooling' }
  @{ Name = 'testing';  Color = 'FBCA04'; Desc = 'Playtesting and bug fixing' }
  @{ Name = 'docs';     Color = 'C5DEF5'; Desc = 'GDD, plan, presentation' }
  @{ Name = 'risk';     Color = 'B60205'; Desc = 'Something that could derail the schedule' }
)

# Status: Todo / In Progress / Done.  Scope: Must / Should / Nice.
$Tasks = @(
  @{ T='Write the Game Design Document'; L='docs'; S='Must'; E=4; M='Plan Approved'; St='Done'
     D='Describe Lantern Keeper using MDA: concept, core loop, controls, look and feel, win/lose conditions, and technical scope.'
     AC=@('At least 500 words','Covers every section listed in the assignment','Includes a sketch of the coastline level') }
  @{ T='Build the project board and task breakdown'; L='docs'; S='Must'; E=2; M='Plan Approved'; St='Done'
     D='Turn the GDD into issues with estimates, scope tiers, milestones, and acceptance criteria.'
     AC=@('Every Must-have feature has at least one issue','No task estimated over 6 hours','Milestones have due dates') }
  @{ T='Set up the Unity project and Git repository'; L='tech'; S='Must'; E=1; M='Plan Approved'; St='Done'
     D='Create a Unity 2D (URP) project, add the Unity .gitignore, and push the first commit.'
     AC=@('Project opens on a lab PC after cloning','Library/ and Temp/ are not committed') }

  @{ T='Player movement (WASD, top-down)'; L='gameplay'; S='Must'; E=3; M='Prototype'; St='In Progress'
     D='The keeper moves in 8 directions using a Rigidbody2D and collides with rocks and walls.'
     AC=@('Diagonal movement is not faster than straight movement','Player cannot walk through cliffs or the lighthouse') }
  @{ T='Lamps with fuel that drains over time'; L='gameplay'; S='Must'; E=3; M='Prototype'; St='In Progress'
     D='A Lamp prefab holds a fuel value from 0 to 100 that drains each second. At 0 the light turns off.'
     AC=@('Drain rate is adjustable in the Inspector','Light visibly dims as fuel drops','Lamp reports when it goes dark') }
  @{ T='Refuel a lamp with the E key'; L='gameplay'; S='Must'; E=2; M='Prototype'; St='Todo'
     D='Standing near a lamp and holding E transfers fuel from the keeper into the lamp.'
     AC=@('Only works within a set range of the lamp','A prompt appears when in range') }
  @{ T='Ships spawn and sail past the coast'; L='gameplay'; S='Must'; E=4; M='Prototype'; St='Todo'
     D='Ships spawn off-screen on a timer and travel along the coast past each lamp.'
     AC=@('Spawn interval is adjustable','Ships are destroyed after leaving the screen') }
  @{ T='Ships wreck at dark lamps and cost a life'; L='gameplay'; S='Must'; E=3; M='Prototype'; St='Todo'
     D='When a ship passes a lamp with no fuel, it wrecks and the player loses one life.'
     AC=@('Wreck plays a placeholder effect','Lives counter decreases by exactly one per wreck') }
  @{ T='Greybox the coastline level'; L='art'; S='Must'; E=2; M='Prototype'; St='Todo'
     D='Block out the level with simple shapes: the lighthouse, five lamps, rocks, and the shipping lane.'
     AC=@('Every lamp is reachable','A full lap of all lamps takes about 20 seconds') }

  @{ T='Win and lose conditions (dawn timer, 3 lives)'; L='gameplay'; S='Must'; E=2; M='Alpha'; St='Todo'
     D='Survive until the dawn timer reaches zero to win. Lose all three lives and the night ends.'
     AC=@('Win and lose each load the correct screen','Timer length is adjustable in the Inspector') }
  @{ T='HUD: lives, dawn timer, and lamp fuel bars'; L='ui'; S='Must'; E=3; M='Alpha'; St='Todo'
     D='Show lives and time remaining at the top of the screen, and a small fuel bar above each lamp.'
     AC=@('Readable at 1280x720','Fuel bars turn red under 25 percent') }
  @{ T='Main menu, pause menu, and game-over screen'; L='ui'; S='Must'; E=3; M='Alpha'; St='Todo'
     D='Main menu with Play and Quit, Esc to pause, and a game-over screen with Retry.'
     AC=@('Every button works with the mouse','Pausing stops fuel drain and ship movement') }
  @{ T='Oil barrel pickups'; L='gameplay'; S='Should'; E=2; M='Alpha'; St='Todo'
     D='Barrels wash up on the shore at random spots and refill the fuel the keeper carries.'
     AC=@('At most two barrels on screen at once','Pickup plays a sound') }
  @{ T='Storms that ramp up difficulty'; L='gameplay'; S='Should'; E=4; M='Alpha'; St='Todo'
     D='Every two minutes a storm wave increases fuel drain and ship frequency.'
     AC=@('At least three escalating waves','A visual warning before each storm') }
  @{ T='Replace the greybox with pixel art'; L='art'; S='Should'; E=6; M='Alpha'; St='Todo'
     D='16x16 tiles for the coast plus sprites for the keeper, lamps, ships, and barrels. Use a credited free pack if time is short.'
     AC=@('Consistent palette (dark blue and amber)','Keeper has a 4-frame walk cycle') }

  @{ T='Sound effects'; L='audio'; S='Should'; E=3; M='Beta'; St='Todo'
     D='Footsteps, refueling, ship horn, wreck, and UI clicks.'
     AC=@('No clip louder than the music','All sounds are royalty-free and credited') }
  @{ T='Background music and volume settings'; L='audio'; S='Nice'; E=2; M='Beta'; St='Todo'
     D='A looping storm track with a volume slider in the pause menu.'
     AC=@('Volume setting persists between scenes') }
  @{ T='Playtest with three classmates'; L='testing'; S='Must'; E=2; M='Beta'; St='Todo'
     D='Watch three people play without helping them, then log every problem as a new issue.'
     AC=@('At least three playtest sessions recorded in comments','Every problem found becomes an issue labeled testing') }
  @{ T='Fix the top playtest issues'; L='testing'; S='Must'; E=4; M='Beta'; St='Todo'
     D='Fix the most serious problems found during playtesting.'
     AC=@('Every crash and blocker fixed','Remaining issues triaged into Should or Nice') }
  @{ T='Sprint ability'; L='gameplay'; S='Nice'; E=3; M='Beta'; St='Todo'
     D='Hold Shift to run faster at the cost of spilling a little fuel.'
     AC=@('Sprint has a stamina meter','Balanced so it is useful but not always on') }

  @{ T='Windows build tested on a lab PC'; L='tech'; S='Must'; E=2; M='Final Build'; St='Todo'
     D='Produce a Windows build and run it on a VR Lab machine that does not have Unity open.'
     AC=@('Runs from a zip file with no errors','Build attached to a GitHub Release') }
  @{ T='Credits screen with asset attribution'; L='ui'; S='Must'; E=1; M='Final Build'; St='Todo'
     D='List the team and every third-party asset with its license.'
     AC=@('Reachable from the main menu','Every asset in the project is listed') }
  @{ T='Final presentation slides'; L='docs'; S='Must'; E=2; M='Final Build'; St='Todo'
     D='A short deck: pitch, a demo, what changed from the GDD and why, and lessons learned.'
     AC=@('Fits in 5 minutes','Shows the final board next to the original plan') }
  @{ T='One-minute gameplay trailer'; L='docs'; S='Nice'; E=2; M='Final Build'; St='Todo'
     D='Record and trim gameplay footage into a short trailer.'
     AC=@('60 seconds or less','Ends with the title and team names') }

  @{ T='RISK: Ship movement may take longer than planned'; L='risk'; S='Must'; E=1; M='Prototype'; St='Todo'
     D='Steering ships around rocks could be harder than estimated. Fallback: ships follow fixed paths. Decide by Nov 3.'
     AC=@('Decision recorded in a comment by Nov 3') }
  @{ T='RISK: Pixel art may not be finished in time'; L='risk'; S='Should'; E=1; M='Alpha'; St='Todo'
     D='Hand-made art is slow. Fallback: keep the greybox and use a credited free asset pack.'
     AC=@('Decision recorded in a comment by Nov 17') }
)
$ScopeName = @{ Must = 'Must have'; Should = 'Should have'; Nice = 'Nice to have' }

# ---------- 0. Preflight ----------
Write-Host 'Checking GitHub CLI login...' -ForegroundColor Cyan
& gh auth status | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Run "gh auth login" first.' }

# Older GitHub CLI versions are missing some of the project commands this script uses.
$prevEap = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
$linkHelp = (& gh project link --help 2>&1 | Out-String)
$ErrorActionPreference = $prevEap
if ($linkHelp -notmatch '--owner') {
  $ver = (& gh --version | Select-Object -First 1)
  throw "Your GitHub CLI ($ver) is too old for this script. Update it with:  winget upgrade --id GitHub.cli   then open a new PowerShell window and run the script again."
}

$prevEap = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
$RepoRoot = (& git rev-parse --show-toplevel 2>$null)
$ErrorActionPreference = $prevEap
if ($LASTEXITCODE -ne 0 -or -not $RepoRoot) { throw 'Run this script from inside your cloned repo folder.' }
$RepoRoot = (Resolve-Path $RepoRoot).Path
Push-Location $RepoRoot
try { $repoInfo = Invoke-GhJson repo view --json 'nameWithOwner,url' } finally { Pop-Location }
$FullRepo = $repoInfo.nameWithOwner
$Owner = $FullRepo.Split('/')[0]
$RepoName = $FullRepo.Split('/')[1]
Write-Host "Using repo $FullRepo" -ForegroundColor Cyan

& gh project list --owner $Owner --limit 1 | Out-Null
if ($LASTEXITCODE -ne 0) {
  Write-Host 'gh needs the "project" scope; opening the browser to grant it...' -ForegroundColor Yellow
  Invoke-Gh auth refresh -s project
}
$work = Join-Path ([IO.Path]::GetTempPath()) ("lantern-keeper-" + [guid]::NewGuid().ToString('N').Substring(0,8))
New-Item -ItemType Directory -Path $work | Out-Null

# ---------- 1. README ----------
Write-Host 'Adding the README to the repo...' -ForegroundColor Cyan
$srcReadme = Join-Path $ScriptDir 'README.md'
$dstReadme = Join-Path $RepoRoot 'README.md'
if ((Resolve-Path $ScriptDir).Path -ne $RepoRoot -and (Test-Path $srcReadme)) {
  if ((Test-Path $dstReadme) -and ((Get-Content $dstReadme).Count -gt 5)) {
    # Don't overwrite a README you already wrote; put the example next to it.
    $dstReadme = Join-Path $RepoRoot 'PROJECT-PLAN.md'
  }
  Copy-Item $srcReadme $dstReadme -Force
}
Push-Location $RepoRoot
try {
  git add -- (Split-Path -Leaf $dstReadme)
  $scriptPath = (Resolve-Path $MyInvocation.MyCommand.Path).Path
  if ($scriptPath.StartsWith($RepoRoot)) { git add -- $scriptPath }
  git diff --cached --quiet
  if ($LASTEXITCODE -ne 0) {
    git commit -q -m 'Add example project plan README and setup script'
    if ($LASTEXITCODE -ne 0) { throw 'git commit failed - is git user.name/user.email set?' }
    git push -q origin HEAD
    if ($LASTEXITCODE -ne 0) { throw 'git push failed - check that you can push to this repo.' }
  } else { Write-Host '  README already up to date.' }
} finally { Pop-Location }

# ---------- 2. Labels and milestones ----------
Write-Host 'Creating labels and milestones...' -ForegroundColor Cyan
foreach ($l in $Labels) {
  Invoke-Gh label create $l.Name --repo $FullRepo --color $l.Color --description $l.Desc --force | Out-Null
}
$existingMs = @(Invoke-Gh api "repos/$FullRepo/milestones?state=all&per_page=100" --jq '.[].title')
foreach ($name in $Milestones.Keys) {
  if ($existingMs -contains $name) { Write-Host "  Milestone '$name' already exists"; continue }
  $m = $Milestones[$name]
  Invoke-Gh api "repos/$FullRepo/milestones" -f "title=$name" -f "due_on=$($m.Due)T23:00:00Z" -f "description=$($m.Desc)" | Out-Null
}

# ---------- 3. Project and custom fields ----------
Write-Host 'Setting up the GitHub Project...' -ForegroundColor Cyan
$proj = (Invoke-GhJson project list --owner $Owner --limit 100 --format json).projects | Where-Object { $_.title -eq $ProjectTitle } | Select-Object -First 1
if ($proj) { Write-Host "  Reusing existing project #$($proj.number)" }
else { $proj = Invoke-GhJson project create --owner $Owner --title $ProjectTitle --format json }
$num = $proj.number
# Link the project to the repo (harmless if it's already linked, so errors are ignored here).
$prevEap = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
& gh project link $num --owner $Owner --repo $RepoName 2>&1 | Out-Null
$ErrorActionPreference = $prevEap
Invoke-Gh project edit $num --owner $Owner --visibility PUBLIC --description 'Example plan for the CIST 1422 Game Design Document and Project Plan assignment' | Out-Null

$fields = (Invoke-GhJson project field-list $num --owner $Owner --limit 50 --format json).fields
$fieldNames = @($fields | ForEach-Object { $_.name })
if ($fieldNames -notcontains 'Scope') { Invoke-Gh project field-create $num --owner $Owner --name 'Scope' --data-type SINGLE_SELECT --single-select-options 'Must have,Should have,Nice to have' | Out-Null }
if ($fieldNames -notcontains 'Estimate (hrs)') { Invoke-Gh project field-create $num --owner $Owner --name 'Estimate (hrs)' --data-type NUMBER | Out-Null }
if ($fieldNames -notcontains 'Target date') { Invoke-Gh project field-create $num --owner $Owner --name 'Target date' --data-type DATE | Out-Null }

$fields = (Invoke-GhJson project field-list $num --owner $Owner --limit 50 --format json).fields
function FieldId($name) { ($fields | Where-Object { $_.name -eq $name }).id }
function OptionId($field, $opt) { (($fields | Where-Object { $_.name -eq $field }).options | Where-Object { $_.name -eq $opt }).id }
$statusId = FieldId 'Status'; $scopeId = FieldId 'Scope'; $estId = FieldId 'Estimate (hrs)'; $dateId = FieldId 'Target date'

# ---------- 4. Issues -> project items ----------
$bodyFile = Join-Path $work 'body.md'
$existingIssues = @((Invoke-GhJson issue list --repo $FullRepo --state all --limit 500 --json title) | ForEach-Object { $_.title })
$i = 0
foreach ($t in $Tasks) {
  $i++
  if ($existingIssues -contains $t.T) { Write-Host ("[{0}/{1}] {2} (already exists, skipped)" -f $i, $Tasks.Count, $t.T); continue }
  Write-Host ("[{0}/{1}] {2}" -f $i, $Tasks.Count, $t.T)
  $body = "## Description`n$($t.D)`n`n## Acceptance criteria`n" + (($t.AC | ForEach-Object { "- [ ] $_" }) -join "`n") +
          "`n`n**Scope:** $($ScopeName[$t.S]) | **Estimate:** $($t.E) hrs | **Milestone:** $($t.M)"
  if ($t.St -eq 'Done') { $body = $body -replace '- \[ \]', '- [x]' }
  Set-Content -Path $bodyFile -Value $body -Encoding utf8

  $url = (Invoke-Gh issue create --repo $FullRepo --title $t.T --body-file $bodyFile --label $t.L --milestone $t.M) | Select-Object -Last 1
  $item = Invoke-GhJson project item-add $num --owner $Owner --url $url --format json

  Invoke-Gh project item-edit --id $item.id --project-id $proj.id --field-id $statusId --single-select-option-id (OptionId 'Status' $t.St) | Out-Null
  Invoke-Gh project item-edit --id $item.id --project-id $proj.id --field-id $scopeId  --single-select-option-id (OptionId 'Scope' $ScopeName[$t.S]) | Out-Null
  Invoke-Gh project item-edit --id $item.id --project-id $proj.id --field-id $estId    --number $t.E | Out-Null
  Invoke-Gh project item-edit --id $item.id --project-id $proj.id --field-id $dateId   --date $Milestones[$t.M].Due | Out-Null
  if ($t.St -eq 'Done') { Invoke-Gh issue close $url --reason completed | Out-Null }
}

Remove-Item -Recurse -Force $work
Write-Host ''
Write-Host 'Done!' -ForegroundColor Green
Write-Host "Repo:    $($repoInfo.url)"
Write-Host "Project: $($proj.url)"
Write-Host 'Last step: in the project, switch the default view to Board, and add Roadmap (by Target date) and Table (grouped by Scope) views.'
