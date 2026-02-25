<div align="center">

<br>

<pre>
<b>
██████╗ ███████╗ ██████╗ ██╗██╗   ██╗███████╗
██╔══██╗██╔════╝██╔════╝ ██║██║   ██║██╔════╝
██████╔╝█████╗  ██║  ███╗██║██║   ██║███████╗
██╔══██╗██╔══╝  ██║   ██║██║██║   ██║╚════██║
██║  ██║███████╗╚██████╔╝██║╚██████╔╝███████║
╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝ ╚═════╝ ╚══════╝
</b>
</pre>

<h3>
<b>R</b>eal-mode · <b>E</b>xecution · <b>G</b>round · <b>I</b>nitialization · <b>U</b>nified · <b>S</b>ystem
</h3>

*The royal gateway to your operating environment.*

<br>

[![License: MIT](https://img.shields.io/badge/license-MIT-gold.svg?style=for-the-badge)](#license)
&nbsp;&nbsp;
[![Architecture: x86](https://img.shields.io/badge/arch-x86_real_mode-blue.svg?style=for-the-badge)](#anatomy)
&nbsp;&nbsp;
[![Stage: 0](https://img.shields.io/badge/stage-0%20%2F%20MBR-crimson.svg?style=for-the-badge)](#roadmap)
&nbsp;&nbsp;
[![Zero Dependencies](https://img.shields.io/badge/deps-zero-brightgreen.svg?style=for-the-badge)](#build)

<br>

───────  ·  ✦  ·  ───────

<br>

</div>

## 👑 &nbsp; What is REGIUS?

<br>

<div align="center">
<table>
<tr>
<td>

> A bare-metal x86 bootloader built from **absolute zero** —
> no compiler, no assembler, no external tools.
> Just raw machine code forged through `printf` and `dd`.

</td>
</tr>
</table>
</div>

<br>

REGIUS is a minimal, hand-crafted **MBR bootstrap** that aims to become a fully functional multi-stage boot loader for x86 systems. The name means *"royal"* in Latin — because every operating system deserves a proper entrance.

<br>

<a name="boot-chain"></a>

<div align="center">

<pre>

                ┌─────────────────────────────────────┐
                │            B  I  O  S               │
                │     Power-On Self Test (POST)       │
                └────────────────┬────────────────────┘
            │
            ▼
                ┌─────────────────────────────────────┐
                │                                     │
                │  ██  STAGE 0 — MBR  (512 bytes)  ██ │
                │  ██  ← you are here              ██ │
                │                                     │
                │  Address:    0x7C00                  │
                │  Signature:  0x55AA                  │
                │                                     │
                └────────────────┬────────────────────┘
            │
            ▼
                ┌─────────────────────────────────────┐
                │                                     │
                │  ░░  STAGE 1 — VBR / Loader      ░░ │
                │                                     │
                │  Partition table parsing             │
                │  Filesystem-aware sector reads       │
                │                                     │
                └────────────────┬────────────────────┘
            │
            ▼
                ┌─────────────────────────────────────┐
                │                                     │
                │  ░░  STAGE 2 — Kernel Handoff    ░░ │
                │                                     │
                │  Protected mode transition           │
                │  Kernel loading &amp; execution          │
                │                                     │
                └─────────────────────────────────────┘

</pre>

</div>

<br>

---

## ⚡ &nbsp; Quick Start

<br>

```bash
# clone the repository
git clone https://github.com/ichxtenebra/regius.git
cd regius

# build the MBR image — no toolchain needed
./fiat.sh

# boot it
qemu-system-x86_64 regius.img
```

> [!TIP]
> The build script requires **nothing** beyond a standard POSIX shell.
> No NASM. No GCC. No Make. Just `printf` and `dd`.

<br>

---

<a name="build"></a>

## 🔧 &nbsp; Build

<br>

The entire bootloader is forged with a **single line**:

```bash
{ printf '\xEB\xFE'; dd if=/dev/zero bs=1 count=508 2>/dev/null; printf '\x55\xAA'; } > regius.img
```

<br>

<div align="center">

| &nbsp; Requirement &nbsp; | &nbsp; Version &nbsp; | &nbsp; Purpose &nbsp; |
|:---:|:---:|:---:|
| `sh` | Any POSIX | Script execution |
| `printf` | coreutils | Emit raw bytes |
| `dd` | coreutils | Zero-fill padding |
| **That's all** | — | **Zero extras** |

</div>

<br>

---

<a name="anatomy"></a>

## 🧬 &nbsp; Anatomy of the MBR

<br>

<div align="center">

<pre>
┌────────────┬───────┬──────────────────────────────────────┐
│ Offset     │ Bytes │ Content                              │
├────────────┼───────┼──────────────────────────────────────┤
│ 0x000      │   2   │ <b>EB FE</b> — jmp short $ (infinite loop)  │
│ 0x002      │ 508   │ 00 .. 00  (reserved for boot code)   │
│ 0x1FE      │   2   │ <b>55 AA</b> — MBR boot signature           │
├────────────┼───────┼──────────────────────────────────────┤
│ Total      │ 512   │ Valid Master Boot Record              │
└────────────┴───────┴──────────────────────────────────────┘
</pre>

</div>

<br>

> [!NOTE]
> **Why `EB FE`?** &nbsp; It encodes `jmp short $` — the CPU calculates
> the jump offset as −2 (back to itself) and loops forever.
> Two bytes. Nothing wasted. The smallest valid bootloader possible.

<br>

---

<a name="roadmap"></a>

## 🗺️ &nbsp; Roadmap

<br>

<table>
<tr><th>Phase</th><th>Task</th><th>Status</th></tr>

<tr>
<td rowspan="5"><b>Stage 0</b><br><sub>MBR</sub></td>
<td>Valid 512-byte MBR with halt-loop stub</td>
<td>✅</td>
</tr>
<tr>
<td>Segment register setup (<code>DS</code>, <code>ES</code>, <code>SS:SP</code>)</td>
<td>⬜</td>
</tr>
<tr>
<td>MBR self-relocation from <code>0x7C00</code></td>
<td>⬜</td>
</tr>
<tr>
<td>Partition table parsing (MBR / GPT)</td>
<td>⬜</td>
</tr>
<tr>
<td>Disk I/O via BIOS <code>INT 13h</code></td>
<td>⬜</td>
</tr>

<tr>
<td rowspan="3"><b>Stage 1</b><br><sub>VBR</sub></td>
<td>Load VBR from active partition</td>
<td>⬜</td>
</tr>
<tr>
<td>A20 gate enable</td>
<td>⬜</td>
</tr>
<tr>
<td>GDT setup &amp; switch to Protected Mode</td>
<td>⬜</td>
</tr>

<tr>
<td><b>Stage 2</b><br><sub>Kernel</sub></td>
<td>Kernel loading &amp; handoff</td>
<td>⬜</td>
</tr>

</table>

<br>

---

## 📐 &nbsp; Design Principles

<br>

<div align="center">

|  | Principle | Meaning |
|:---:|:---|:---|
| **1** | Zero external dependencies | Build with what every Unix already has |
| **2** | Every byte justified | No filler, no bloat, no waste |
| **3** | BIOS-first, bare-metal always | Real hardware is the only truth |
| **4** | Readable build, raw execution | Human-friendly source → machine-perfect binary |
| **5** | One commit — one capability | Each step traceable and atomic |

</div>

<br>

---

<a name="license"></a>

## 📜 &nbsp; License

<br>

This project is licensed under the [MIT License](LICENSE).

> ```
> MIT License — do whatever you want.
> Just don't blame us if it formats your disk.
> It won't. It literally does nothing. Yet.
> ```

<br>

---

<br>

<div align="center">

<pre>
╔═════════════════════════════════════════════════╗
║                                                 ║
║     Built from nothing.  Byte by byte.          ║
║                                                 ║
╚═════════════════════════════════════════════════╝
</pre>

<br>

**REGIUS** — *because every OS deserves a royal entrance.*

<br>

<sub>Made with raw bytes and bare metal. No frameworks were harmed.</sub>

</div>
