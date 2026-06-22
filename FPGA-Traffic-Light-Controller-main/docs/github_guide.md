# GitHub Upload Guide — FPGA Traffic Light Controller

A complete, step-by-step guide to publishing this project as proof-of-work on GitHub.

---

## 1. Repository Setup

### Repository Name
```
FPGA-Traffic-Light-Controller
```

### Description
```
Moore FSM-based traffic light controller in Verilog | Simulated and synthesized
in Vivado 2024.2 | FPGA-ready for Basys3 (Artix-7) | VLSI Course Project
```

### Topics / Tags
Add these under "About → Topics" on the GitHub repo page:
```
verilog
fpga
fsm
digital-design
vlsi
traffic-light-controller
xilinx
vivado
basys3
rtl-design
finite-state-machine
hardware-description-language
testbench
verification
```

### Visibility
Choose **Public** — required for it to count as visible proof-of-work for recruiters/professors.

### Initialize Options
When creating the repo on github.com, **uncheck/skip**:
- ❌ Add a README
- ❌ Add .gitignore
- ❌ Choose a license

You already have all three locally — adding them on GitHub first will cause a merge conflict when you push.

---

## 2. Local Folder Check (Before Pushing)

Confirm your project folder looks like this before initializing git:

```
FPGA-Traffic-Light-Controller/
├── .gitignore
├── README.md
├── rtl/
│   ├── traffic_light_controller.v
│   ├── clock_divider.v
│   └── top_traffic_light.v
├── tb/
│   └── tb_traffic_light_controller.v
├── constraints/
│   └── traffic_light_basys3.xdc
├── simulation/
│   ├── run_sim.sh
│   └── edaplayground_guide.md
├── waveforms/
│   └── traffic_light_sim.vcd
├── images/
│   ├── vivado_project_part_selection.png
│   ├── simulation_tcl_console_pass_results.png
│   ├── waveform_full_cycle.png
│   ├── waveform_full_cycle_clean.png
│   ├── synthesis_schematic.png
│   ├── synthesis_utilization.png
│   ├── synthesis_timing_summary.png
│   ├── synthesis_power_summary.png
│   ├── synthesis_device_view.png
│   └── bitstream_generation_success.png
├── reports/
│   └── project_report.md
└── docs/
    ├── interview_prep.md
    ├── github_guide.md
    └── vivado_2024_2_guide.md
```

If anything is missing, copy it in before continuing.

---

## 3. Check Git is Installed

Open **Git Bash** (Windows) or terminal (Linux/macOS) and run:

```bash
git --version
```

Expected output (version may differ):
```
git version 2.43.0.windows.1
```

If you get `command not found` — download Git from [git-scm.com](https://git-scm.com/downloads) and install with default options, then reopen the terminal.

---

## 4. Configure Git (One-Time Only)

If this is your first time using Git on this machine:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

Use the same email associated with your GitHub account.

---

## 5. Initialize and Push

Navigate to your project folder, then run these commands **one at a time**:

```bash
cd "D:/Links/FPGA-Traffic-Light-Controller"
```

```bash
git init
```

```bash
git add .
```

```bash
git status
```
Check the output — confirm all expected files are listed in green (staged). If `simulation/traffic_light_sim` (a binary file) shows up, that's fine — `.gitignore` should exclude it, but if it appears, run:
```bash
git rm --cached simulation/traffic_light_sim
```

```bash
git commit -m "feat: Complete FSM design, testbench, simulation results, and Vivado synthesis"
```

```bash
git branch -M main
```

```bash
git remote add origin https://github.com/YOUR_USERNAME/FPGA-Traffic-Light-Controller.git
```
Replace `YOUR_USERNAME` with your actual GitHub username.

```bash
git push -u origin main
```

A browser window may open asking you to authenticate — sign in with your GitHub credentials.

---

## 6. Verify the Upload

Go to:
```
https://github.com/YOUR_USERNAME/FPGA-Traffic-Light-Controller
```

Confirm:
- [ ] README.md renders on the front page with all images visible
- [ ] All folders (`rtl`, `tb`, `constraints`, `images`, etc.) are present
- [ ] Click into `images/synthesis_schematic.png` — it should open and display correctly
- [ ] Click into `rtl/traffic_light_controller.v` — syntax highlighting should appear

---

## 7. Recommended Commit Strategy (If Starting Fresh / Want Clean History)

Instead of one big commit, you can split it into a clean progression — useful if you want your commit history itself to look professional:

```bash
git add rtl/ tb/ .gitignore
git commit -m "feat: Add RTL modules and self-checking testbench"

git add constraints/
git commit -m "feat: Add Basys3 XDC pin constraints"

git add simulation/ waveforms/
git commit -m "test: Add simulation scripts and verified VCD waveform"

git add images/
git commit -m "docs: Add Vivado simulation and synthesis screenshots"

git add reports/ docs/
git commit -m "docs: Add project report and interview preparation notes"

git add README.md
git commit -m "docs: Add complete README with architecture and results"

git push -u origin main
```

---

## 8. Common Errors and Fixes

| Error | Cause | Fix |
|---|---|---|
| `fatal: remote origin already exists` | You ran `git remote add` twice | `git remote remove origin` then re-add |
| `failed to push some refs` | Remote has commits you don't have locally (e.g., you initialized with a README on GitHub) | `git pull origin main --allow-unrelated-histories`, resolve conflicts, then push |
| `Permission denied (publickey)` | Using SSH URL without configured SSH key | Use the **HTTPS** URL instead (`https://github.com/...`) or set up SSH keys |
| Images don't render in README | Wrong relative path or filename mismatch | Confirm `images/filename.png` matches exactly (case-sensitive) |
| `git: command not found` | Git not installed | Install from git-scm.com |
| Large file warning (`.bit` file) | Bitstream files are large | Already excluded via `.gitignore` — don't force-add them |

---

## 9. After Upload — Polish Checklist

- [ ] Pin this repository on your GitHub profile (Profile → Customize pins)
- [ ] Add the repo link to your resume / LinkedIn projects section
- [ ] Add a one-line summary to your GitHub profile README if you have one
- [ ] Star your own repo (optional, cosmetic)
- [ ] Share the repo link in interviews when asked "tell me about a project"

---

## 10. Future Updates (Adding More Features Later)

When you add pedestrian button support, emergency preemption, etc.:

```bash
git add .
git commit -m "feat: Add pedestrian crossing button support"
git push
```

Each new feature should be its own commit with a clear `feat:`, `fix:`, `docs:`, or `test:` prefix — this is standard industry convention (Conventional Commits) and looks strong on a portfolio repo.
