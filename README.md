<div align="center">

<pre>
██████╗ ███████╗ ██████╗ ██╗██╗   ██╗███████╗
██╔══██╗██╔════╝██╔════╝ ██║██║   ██║██╔════╝
██████╔╝█████╗  ██║  ███╗██║██║   ██║███████╗
██╔══██╗██╔══╝  ██║   ██║██║██║   ██║╚════██║
██║  ██║███████╗╚██████╔╝██║╚██████╔╝███████║
╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝ ╚═════╝ ╚══════╝
</pre>

**R**eal-mode · **E**xecution · **G**round · **I**nitialization · **U**nified · **S**ystem

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

*The royal gateway to your operating environment.*

[![License: MIT](https://img.shields.io/badge/license-MIT-gold.svg)](#LICENSE)
[![Architecture: x86](https://img.shields.io/badge/arch-x86_realmode-blue.svg)](#)
[![Stage: 0](https://img.shields.io/badge/stage-0%20%2F%20MBR-crimson.svg)](#boot-chain)
[![Zero Dependencies](https://img.shields.io/badge/dependencies-zero-brightgreen.svg)](#build)

</div>

---

## 👑 What is REGIUS?

> A bare-metal x86 bootloader built from absolute zero —
> no compiler, no assembler, no external tools.
> Just raw machine code forged through `printf` and `dd`.

REGIUS is a minimal, hand-crafted MBR bootstrap that aims to become
a fully functional multi-stage boot loader for x86 systems.

<div align="center">

<pre>
┌──────────────────────────────────────────────┐
│               B  I  O  S                     │
│         Power-On Self Test (POST)            │
└──────────────────┬───────────────────────────┘
                   ▼
┌──────────────────────────────────────────────┐
│  ██  STAGE 0 — MBR (512 bytes)           ██  │
│  ██  ← you are here                      ██  │
│  Loaded at 0x7C00 by BIOS                    │
│  Signature: 0x55AA                           │
└──────────────────┬───────────────────────────┘
                   ▼
┌──────────────────────────────────────────────┐
│  ░░  STAGE 1 — VBR / Extended Loader     ░░  │
│  Partition table parsing                     │
│  Filesystem-aware sector reads               │
└──────────────────┬───────────────────────────┘
                   ▼
┌──────────────────────────────────────────────┐
│  ░░  STAGE 2 — Kernel Handoff            ░░  │
│  Protected mode transition                   │
│  Kernel loading & execution                  │
└──────────────────────────────────────────────┘
</pre>

</div>

---

## ⚡ Quick Start

```bash
# clone
git clone https://github.com/ichxtenebra/regius.git
cd regius

# build — that's it, no toolchain needed
./fiat.sh

# run
qemu-system-x86_64 regius.img
```

---

## 🔧 Build

The entire build is a single shell command:

```bash
{ printf '\xEB\xFE'; dd if=/dev/zero bs=1 count=508 2>/dev/null; printf '\x55\xAA'; } > regius.img
```

| Requirement    | Version          |
|----------------|------------------|
| Shell          | Any POSIX sh     |
| `printf`       | coreutils        |
| `dd`           | coreutils        |
| **That's all** | **Zero extras**  |

---

## 🧬 Anatomy of the MBR

```
Offset (hex)     Bytes   Content
─────────────────────────────────────────────
0x000            2       EB FE — jmp short $ (infinite loop)
0x002          508       00 .. 00 (reserved for boot code)
0x1FE            2       55 AA (MBR boot signature)
─────────────────────────────────────────────
Total          512       Valid Master Boot Record
```

> **Why `EB FE`?**
> It encodes `jmp short $` — a 2-byte infinite loop.
> The CPU jumps back to itself forever.
> Smallest possible valid bootloader.

---

## 🗺️ Roadmap

- [x] **Stage 0** — Valid MBR with halt-loop stub
- [ ] Real-mode segment register setup (`DS`, `ES`, `SS:SP`)
- [ ] MBR self-relocation from `0x7C00`
- [ ] Partition table parsing (MBR / GPT)
- [ ] Disk I/O via BIOS `INT 13h`
- [ ] **Stage 1** — Load VBR from active partition
- [ ] A20 gate enable
- [ ] GDT setup & switch to Protected Mode
- [ ] **Stage 2** — Kernel loading & handoff

---

## 📐 Design Principles

<div align="center">

<pre>
┌──────────────────────────────────────┐
│  1. Zero external dependencies       │
│  2. Every byte justified             │
│  3. BIOS-first, bare-metal always    │
│  4. Readable build, raw execution    │
│  5. One commit — one capability      │
└──────────────────────────────────────┘
</pre>

</div>

---

## 📜 License

```
MIT License — do whatever you want.
Just don't blame us if it formats your disk.
It won't. It literally does nothing. Yet.
```

---

<div align="center">

<pre>
╔═══════════════════════════════════════╗
║                                       ║
║   Built from nothing. Byte by byte.   ║
║                                       ║
╚═══════════════════════════════════════╝
</pre>

**REGIUS** — *because every OS deserves a royal entrance.*

</div>
