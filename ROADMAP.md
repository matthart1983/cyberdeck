# ROADMAP — the operations layer

Where this rice goes next: a workstation for running infrastructure, not just
one that looks like it could. Written down before any of it is built, because
the ordering is the part that matters — three of the seven phases only get
cheap if the one before them extracted the right library.

Scope, decided up front and deliberately narrow:

| | |
|---|---|
| **Shape** | Dotfiles plus an opt-in `ops/` layer. Not a bootc image, not an ISO. |
| **First-class** | Kubernetes, fleet SSH, observability. |
| **Out** | Cloud CLIs, Terraform, Ansible. Not forever — just not the first thing. |
| **Platforms** | Linux-first. macOS keeps what it has and gets what comes free. |

---

## What's already here

Four primitives carry every phase below, and none of them need inventing. This
is the whole reason the plan is seven phases and not a rewrite.

- **The palette engine** — `common/bin/theme` renders 16 surfaces from 54 slots
  in nine colour notations, and `theme --check` fails when they drift. One
  source of truth fanning out to every surface at once is exactly the machine
  the ops layer needs; it just needs feeding from somewhere other than a
  palette.
- **The idempotent installer** — `link`, `copy` and `render` in
  `common/lib.sh` write only on difference, stash what they displace into the
  attic, and `test/idempotent.sh` proves the second run is a no-op instead of
  asserting it in a comment.
- **The doctor pattern** — pass/fail lines, an exit code, and the remediation
  written into the failure itself. Already duplicated across two files, which
  is the argument for extracting it before there is a third.
- **A Prometheus-fed bar** — `linux/waybar/scripts/netwatch_lib.sh` scrapes a
  metrics endpoint with a 1.5s ceiling and a cached last-good value. The README
  already brags about this. It is also, unmodified, the seam the entire ops
  layer bolts onto.

## The thesis: context is the spine

What separates an operations workstation from a terminal with `kubectl`
installed is that it always knows, and always shows, **which cluster, which
fleet, which environment** the next command lands on.

So: one resolver writes one file, every surface subscribes, and the environment
classification drives an accent overlay. Pointing at production changes the
colour of the bar, the prompt, the tmux status line and the window focus ring —
not as decoration, as the readout.

```
  SOURCES                    RESOLVER                  SUBSCRIBERS

  kubeconfig       ─┐                             ┌─ waybar  custom/ctx
  ops/fleet/*.yaml ─┤                             ├─ tmux    status-right
  ssh destination  ─┼──▶  ops/bin/ctx             ├─ zsh     prompt segment
    (tmux pane)     │     classify against        ├─ niri    focus ring
  git HEAD         ─┘     environments.toml       ├─ theme   --accent
                               │                  └─ hud / incident
                               ▼
                          context.json
                       $XDG_RUNTIME_DIR
```

An unmatched context classifies as `unknown`, and `unknown` is styled like
production. The classification is the safety property, so the failure mode has
to be caution rather than a green light.

---

## Phase 0 — Pay down what the ops layer will lean on

*~1 weekend. Three shared libraries and a green CI, so nothing after this is
written twice or merged blind.*

- **new** · `.github/workflows/ci.yml` — there is no CI at all today. Run
  shellcheck over every script, plus `test/idempotent.sh` and `test/theme.sh`,
  in a Fedora container on every push. The ops layer roughly doubles the shell
  surface; doing that without CI is how a rice stops booting.
- **refactor** · `common/lib-prom.sh` — generalise `netwatch_lib.sh` into
  `prom_scrape URL` / `prom_value` / `prom_emit`, keeping the ceiling and the
  runtime-dir cache. netwatch becomes its first caller rather than its only
  one. **This is the unlock**: every later bar module becomes a config line
  instead of a new script.
- **refactor** · `common/lib-doctor.sh` — extract `pass`/`fail`/summary from the
  two rice-doctors, which currently duplicate them. `ops-doctor` is the third
  caller.
- **refactor** · `docs/parts/*.html` + `docs/build.py` — the field manual is
  1,438 lines of hand-written HTML. Split it into fragments with a small
  generator, so the ops layer can document itself without a conflict on every
  edit.

## Phase 1 — Context, the spine

*~1–2 weeks. Every surface on the machine agrees, continuously, about which
environment the next command hits.*

- **new** · `ops/bin/ctx` — the resolver. Writes `context.json` (kube context
  and namespace, fleet group and host, git repo and branch, environment class)
  into `$XDG_RUNTIME_DIR/cyberdeck/`. Reads files and env vars only. It must
  never shell out to `kubectl`, because it runs on every prompt and every bar
  tick.
- **new** · `ops/environments.toml` — patterns to classes. `prod-*` → prod,
  `*.stg` → stage, everything else `unknown`. See the note above about why
  `unknown` is not `dev`.
- **extend** · `common/bin/theme --accent` — a live overlay beside the existing
  `--render`. Re-tints only the four surfaces that hot-reload (waybar CSS,
  tmux, the niri focus ring, Ghostty) and leaves the 16-surface render alone.
  Switching accents must never rewrite the working tree; that is the whole
  reason it is a separate verb.
- **new** · `linux/waybar` `custom/ctx` — the bar's leftmost ops item: cluster,
  namespace, env, coloured by class. Signal-driven, so `ctx` pushes rather than
  the bar polling.
- **extend** · `tmux.conf.tmpl`, `cyberpunk.zsh.tmpl` — a context segment in the
  status line and the prompt, both reading the same cached JSON. Both are
  already template-rendered, so they inherit the palette for free.

## Phase 2 — Kubernetes

*~1–2 weeks. A cluster you can read from the bar and drive from a HUD, with a
destructive-command guardrail that is advisory and auditable.*

- **new** · `ops/packages-k8s.sh` — kubectl, k9s, helm, stern, kubectx/kubens,
  kustomize, yq. Opt-in exactly like `linux/packages.sh`; `install.sh` never
  calls it.
- **refactor** · `common/bin/hud` → `ops/hud/*.layout` — turn the one hard-coded
  four-pane grid into named layouts. `hud` with no argument keeps meaning
  exactly what it means today; `hud k8s` gives you k9s, a stern tail, events
  and node pressure.
- **new** · `linux/waybar` `custom/k8s` — nodes ready, pods pending, alerts
  firing, scraped from the cluster's own Prometheus and Alertmanager through
  `lib-prom`. The same shape as `custom/net`, which is the point.
- **new** · `ops/bin/kubectl-guard` — a PATH-shadowing wrapper. On a
  prod-classified context, destructive verbs print the context in the alarm
  accent and require typing the cluster's short name. It never rewrites a
  command, and everything it lets through is appended to
  `~/.local/state/cyberdeck/ops.log`.
- **extend** · `linux/niri/config.kdl.tmpl` — window rules pinning k9s and the
  HUD to the `infra` workspace, which already exists and is already labelled.

## Phase 3 — Fleet SSH

*~1–2 weeks. One inventory file drives the resolver, the SSH config, a
parallel-exec command and a per-host HUD.*

- **new** · `ops/fleet/<group>.yaml` — groups, hosts, jump host, env class. One
  file, four consumers: the inventory is to hosts what `palette.sh` is to
  colour.
- **new** · `ops/bin/fleet` — `fleet ls`, `fleet ssh <host>`,
  `fleet run <group> -- <cmd>` with bounded parallelism, `fleet ping <group>`.
  Sets the fleet fields in `context.json` on entry and clears them on exit.
- **new** · `ops/bin/fleet-ssh-config` — renders `~/.ssh/config.d/cyberdeck`
  from the inventory through the existing `render()` helper, so it is
  idempotent and stashes to the attic like every other managed file.
- **new** · `hud fleet <group>` — one tmux pane per host, pane borders coloured
  by env class, `synchronize-panes` off by default with a toggle that announces
  itself loudly.

## Phase 4 — Observability and network

*~1 week. The bar's right-hand side becomes a configured stack of endpoints
rather than hand-written modules.*

- **new** · `ops/dashboards.toml` — named Prometheus, Alertmanager and Loki
  endpoints with their env classes. `lib-prom` reads it; adding a readout stops
  being a scripting job.
- **new** · `linux/waybar` `custom/alerts` — firing alerts by severity, coloured
  with the semantic slots the palette already defines. Click opens `hud alerts`.
- **new** · `ops/packages-net.sh` — mtr, dig, tcpdump, termshark, ss, iperf3,
  bpftrace. The diagnostic toolbelt, opt-in like the rest.
- **extend** · `hud net` — today's four *watch* panes plus an alerts pane. The
  *watch* tools already read the palette, so the new pane inherits it through
  the same template pass.

## Phase 5 — Incident mode

*~3–4 days. One command puts the whole machine into incident posture and hands
you a timeline at the end. Almost pure composition: every mechanism it needs
exists by now.*

- **new** · `ops/bin/incident start <slug>` — flips the accent to alarm (the
  reds in `blood-dragon` are already a rendered theme), opens `hud incident`,
  starts `asciinema rec` and `tmux pipe-pane` logging, opens a timestamped log
  under `~/incidents/`, and focuses `infra`.
- **new** · `incident note`, `incident end` — `note` appends a timestamped line;
  `end` renders commands, notes and alert transitions into one markdown
  timeline you can paste straight into a postmortem.

## Phase 6 — Hardening and portability

*~1 week. The ops layer becomes as checkable, as idempotent and as safe to
publish as the rice already is.*

- **new** · `ops/bin/ops-doctor` — the third `lib-doctor` caller: kube contexts
  reachable, credential and certificate expiry, SSH agent loaded, VPN route
  present, clock skew, container runtime, every configured endpoint answering.
- **new** · gitleaks in CI, plus `.gitignore` rules — this repo is public and
  the ops config names real hosts. Inventories ship as `*.example.yaml`; the
  real ones are ignored, and CI enforces it rather than trusting discipline.
- **extend** · `test/idempotent.sh` — ops cases in the fake-`$HOME` run, plus a
  container smoke test that installs the ops layer on clean Fedora.
- **extend** · `macos/` (best-effort) — `ctx`, `hud`, `fleet`, `incident` and
  `ops-doctor` are POSIX shell and work as-is. Only the waybar modules do not;
  SketchyBar gets `ctx` and `alerts` if those ports are cheap, and the doctor
  says so plainly if they are not.

---

## Repo shape after

The README documents three top-level directories with one rule each. This adds
a fourth under the same rule: opt-in, idempotent, and it never touches system
state without being asked.

```
  common/     configs and executables that work on both platforms
  macos/      AeroSpace, SketchyBar, JankyBorders, launchd
  linux/      niri, Waybar, systemd user units
  ops/        the operations layer — opt-in, never called by install.sh
    bin/        ctx  fleet  incident  ops-doctor  kubectl-guard
    hud/        k8s.layout  fleet.layout  net.layout  incident.layout
    fleet/      <group>.example.yaml
    environments.toml   patterns -> dev | stage | prod
    dashboards.toml     prometheus / alertmanager / loki endpoints
    packages-k8s.sh  packages-net.sh
```

`palette.sh` stays at the root as the single source of truth for colour.
`ops/environments.toml` becomes the second one, for environment class.

## Where this can go wrong

**A guardrail that lies is worse than none.** The `kubectl` wrapper is advisory
and auditable, never silently rewriting or reordering a command. If it cannot
classify a context it treats it as production. The moment an operator learns it
sometimes mangles input they alias around it, and then both the guardrail and
the audit log are gone.

**The bar must never block.** Every ops module inherits `lib-prom`'s ceiling and
its cached last-good value. A dead cluster endpoint reads `k8s off`, exactly
the way `netwatch off` already does. An incident is the worst possible time for
a hung bar.

**Context resolution is a hot path.** It runs on every prompt and every bar
tick. Cache to `$XDG_RUNTIME_DIR`, invalidate on kubeconfig mtime, and never
fork `kubectl` from the prompt — that is how a shell acquires a 300ms stutter
nobody can find six months later.

**Public repo, private fleet.** Inventory and dashboard files name real hosts
and real endpoints, which is structurally unlike anything this repo has
published so far. Examples tracked, real ones not, and CI checking rather than
memory.

**Excluded scope stays cheap to add.** If cloud CLIs and Terraform arrive later
they should arrive as another `ops/packages-*.sh` and another field in
`context.json` — not as a redesign. Keeping the resolver's schema open to that
now costs nothing.

## Order

| Phase | Size | Unlocks |
|---|---|---|
| 0 · Foundations | 1 weekend | Everything. `lib-prom` alone turns 2 and 4 from scripting into configuration. |
| 1 · Context | 1–2 weeks | The spine. Phases 2, 3 and 5 are all consumers of it. |
| 2 · Kubernetes | 1–2 weeks | The first real payoff, and the first test of the guardrail design. |
| 3 · Fleet SSH | 1–2 weeks | Independent of phase 2 — can run alongside it, or first if bare metal is the daily driver. |
| 4 · Observability | 1 week | Cheap once `lib-prom` and `dashboards.toml` exist. |
| 5 · Incident mode | 3–4 days | Nearly free, and the most visible thing in the plan. |
| 6 · Hardening | 1 week | What lets other people run it. |

Phases 2 and 3 are the only pair that genuinely parallelise. Everything else is
a chain, because each phase adds a caller to a library the previous one
extracted. Sizes assume evenings and weekends.
