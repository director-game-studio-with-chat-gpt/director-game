# Local development setup

## Requirements

- **Godot 4.4 or later** — download from https://godotengine.org/download
- **Git** — for cloning the repo
- **A GitHub account** with collaborator access to `director-game-studio-with-chat-gpt/director-game`

## Setup steps

### 1. Clone the repo

```bash
git clone https://github.com/director-game-studio-with-chat-gpt/director-game.git
cd director-game
```

### 2. Open in Godot

- Launch Godot 4.4
- Click **Import** in the project manager
- Select the `project.godot` file in this folder
- Click **Import & Edit**

### 3. (Optional) Run the project

Press **F5** in the Godot editor, or:

```bash
godot --path .
```

### 4. Run tests

We use [GUT (Godot Unit Test)](https://github.com/bitwes/Gut) for testing.

```bash
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests/ -gexit
```

Or in the Godot editor: open the GUT panel and click **Run All**.

## For Devin sessions

If you are a Devin session running on a fresh VM:
- The blueprint should install Godot 4.4 automatically.
- If it doesn't, install manually:
  ```bash
  wget https://github.com/godotengine/godot/releases/download/4.4-stable/Godot_v4.4-stable_linux.x86_64.zip
  unzip Godot_v4.4-stable_linux.x86_64.zip
  sudo mv Godot_v4.4-stable_linux.x86_64 /usr/local/bin/godot
  ```
- Headless mode (no UI) for CI:
  ```bash
  godot --headless --import   # imports assets
  godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests/ -gexit   # runs tests
  ```
