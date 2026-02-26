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
                │  Address:    0x7C00                 │
                │  Signature:  0x55AA                 │
                │  Output:     "REGIUS" via INT 10h   │
                │                                     │
                └────────────────┬────────────────────┘
            │
            ▼
                ┌─────────────────────────────────────┐
                │                                     │
                │  ░░  STAGE 1 — VBR / Loader      ░░ │
                │                                     │
                │  Partition table parsing            │
                │  Filesystem-aware sector reads      │
                │                                     │
                └────────────────┬────────────────────┘
            │
            ▼
                ┌─────────────────────────────────────┐
                │                                     │
                │  ░░  STAGE 2 — Kernel Handoff    ░░ │
                │                                     │
                │  Protected mode transition          │
                │  Kernel loading &amp; execution         │
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

# boot it — "REGIUS" appears on screen
qemu-system-x86_64 -drive format=raw,file=regius.img
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
{ printf '\x31\xC0\x8E\xD8\x31\xDB\xBE\x16\x7C\xB4\x0E\xAC\x84\xC0\x74\x04\xCD\x10\xEB\xF7\xEB\xFE\x52\x45\x47\x49\x55\x53\x00'; dd if=/dev/zero bs=1 count=481 2>/dev/null; printf '\x55\xAA'; } > regius.img
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
┌────────────┬───────┬──────────────────────────────────────────┐
│ Offset     │ Bytes │ Content                                  │
├────────────┼───────┼──────────────────────────────────────────┤
│ 0x000      │   4   │ <b>31 C0 8E D8</b> — xor ax,ax / mov ds,ax      │
│ 0x004      │   2   │ <b>31 DB</b> — xor bx,bx  (page 0)              │
│ 0x006      │   3   │ <b>BE 16 7C</b> — mov si, 0x7C16  (→ string)    │
│ 0x009      │   2   │ <b>B4 0E</b> — mov ah, 0x0E  (teletype func)    │
│ 0x00B      │   9   │ Print loop: <b>AC 84 C0 74 04 CD 10 EB F7</b>   │
│ 0x014      │   2   │ <b>EB FE</b> — jmp $  (halt)                    │
│ 0x016      │   7   │ <b>52 45 47 49 55 53 00</b> — "REGIUS\0"        │
│ 0x01D      │ 481   │ 00 .. 00  (reserved for boot code)       │
│ 0x1FE      │   2   │ <b>55 AA</b> — MBR boot signature               │
├────────────┼───────┼──────────────────────────────────────────┤
│ Total      │  512  │ Valid MBR — prints "REGIUS", then halts  │
└────────────┴───────┴──────────────────────────────────────────┘
</pre>

</div>

<br>

### Disassembly — 29 bytes of machine code

```
 Addr   Hex            ASM                 ; Comment
─────── ────────────── ─────────────────── ──────────────────
 0x000  31 C0          xor    ax, ax       ; AX = 0
 0x002  8E D8          mov    ds, ax       ; DS = 0 (flat)
 0x004  31 DB          xor    bx, bx       ; BH = page 0
 0x006  BE 16 7C       mov    si, 0x7C16   ; SI → "REGIUS"
 0x009  B4 0E          mov    ah, 0x0E     ; BIOS teletype
 .loop:
 0x00B  AC             lodsb              ; AL = [DS:SI++]
 0x00C  84 C0          test   al, al       ; null terminator?
 0x00E  74 04          jz     .halt        ; → done
 0x010  CD 10          int    0x10         ; print char
 0x012  EB F7          jmp    .loop        ; next char
 .halt:
 0x014  EB FE          jmp    $            ; infinite halt
 .msg:
 0x016  52 45 47 49    "REGI"
 0x01A  55 53 00       "US\0"
```
</div>

<br>

> [!NOTE]
> **INT 10h / AH=0Eh** — BIOS Teletype Output.
> Prints one character in AL to the current cursor position, advances the cursor automatically.
> No framebuffer writes. No segment tricks. Six `int 0x10` calls — one per letter.

<br>

---

<a name="roadmap"></a>

## 🗺️ &nbsp; Roadmap

<br>

<table>
<tr><th>Phase</th><th>Task</th><th>Status</th></tr>

<tr>
<td rowspan="6"><b>Stage 0</b><br><sub>MBR</sub></td>
<td>Valid 512-byte MBR with halt-loop stub</td>
<td>✅</td>
</tr>
<tr>
<td>BIOS text output — <code>"REGIUS"</code> via <code>INT 10h</code> AH=0Eh</td>
<td>✅</td>
</tr>
<tr>
<td>Segment register setup (<code>DS</code>, <code>ES</code>, <code>SS:SP</code>)</td>
<td>✅ <sub>partial</sub></td>
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
> It won't. It just prints REGIUS and halts.
> ```

<br>

---

<br>

<div align="center">

<pre>
╔═════════════════════════════════════════════════╗
║                                                 ║
║     Built from nothing.  Byte by byte.          ║
║     Now it speaks.                              ║
║                                                 ║
╚═════════════════════════════════════════════════╝
</pre>

<br>

**REGIUS** — *because every OS deserves a royal entrance.*

<br>

<sub>Made with raw bytes and bare metal. No frameworks were harmed.</sub>

</div>
