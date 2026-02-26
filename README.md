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
                │  Load:       0x7C00                 │
                │  Relocate:   0x0600                 │
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

# boot it — screen clears, "REGIUS" appears
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
{ printf '\xFA\x31\xC0\x8E\xD8\x8E\xC0\x8E\xD0\xBC\x00\x7C\xFB\xBE\x00\x7C\xBF\x00\x06\xB9\x00\x01\xFC\xF3\xA5\xEA\x1E\x06\x00\x00\xB8\x03\x00\xCD\x10\x31\xDB\xBE\x35\x06\xB4\x0E\xAC\x84\xC0\x74\x04\xCD\x10\xEB\xF7\xEB\xFE\x52\x45\x47\x49\x55\x53\x00'; dd if=/dev/zero bs=1 count=450 2>/dev/null; printf '\x55\xAA'; } > regius.img
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
│ 0x000      │   1   │ <b>FA</b> — cli                                 │
│ 0x001      │   4   │ <b>31 C0 8E D8</b> — xor ax,ax / mov ds,ax      │
│ 0x005      │   2   │ <b>8E C0</b> — mov es,ax                        │
│ 0x007      │   2   │ <b>8E D0</b> — mov ss,ax                        │
│ 0x009      │   3   │ <b>BC 00 7C</b> — mov sp, 0x7C00                │
│ 0x00C      │   1   │ <b>FB</b> — sti                                 │
│ 0x00D      │  12   │ Relocation: <b>rep movsw</b> 0x7C00 → 0x0600    │
│ 0x019      │   5   │ <b>EA 1E 06 00 00</b> — far jmp to 0x0600+0x1E  │
│ 0x01E      │   5   │ <b>B8 03 00 CD 10</b> — clear screen (mode 3)   │
│ 0x023      │   5   │ Setup: <b>xor bx</b> / <b>mov si</b> / <b>mov ah,0Eh</b>      │
│ 0x02A      │   9   │ Print loop: <b>AC 84 C0 74 04 CD 10 EB F7</b>   │
│ 0x033      │   2   │ <b>EB FE</b> — jmp $  (halt)                    │
│ 0x035      │   7   │ <b>52 45 47 49 55 53 00</b> — "REGIUS\0"        │
│ 0x03C      │ 450   │ 00 .. 00  (reserved for boot code)       │
│ 0x1FE      │   2   │ <b>55 AA</b> — MBR boot signature               │
├────────────┼───────┼──────────────────────────────────────────┤
│ Total      │  512  │ Valid MBR — relocates, clears, prints    │
└────────────┴───────┴──────────────────────────────────────────┘
</pre>

</div>

<br>

### Memory layout after relocation

<div align="center">

<pre>
 0x0000 ┌──────────────────────┐
        │  IVT + BDA           │
 0x0500 ├──────────────────────┤
        │  free                │
                        0x0600 ├──────────────────────┤ ◄── MBR relocated here
        │  REGIUS (512 bytes)  │
 0x0800 ├──────────────────────┤
        │  free for VBR/Stage1 │
                    0x7C00 ├──────────────────────┤ ◄── SP (stack top)
        │  ↓ stack grows down  │
 0x7FFF └──────────────────────┘
</pre>

</div>

<br>

### Disassembly — 60 bytes of machine code

```
 Addr   Hex               ASM                    ; Comment
─────── ───────────────── ────────────────────── ──────────────────────
 0x000  FA                cli                    ; protect SS:SP setup
 0x001  31 C0             xor    ax, ax          ; AX = 0
 0x003  8E D8             mov    ds, ax          ; DS = 0
 0x005  8E C0             mov    es, ax          ; ES = 0
 0x007  8E D0             mov    ss, ax          ; SS = 0
 0x009  BC 00 7C          mov    sp, 0x7C00      ; stack below load addr
 0x00C  FB                sti                    ; interrupts back on
 .reloc:
 0x00D  BE 00 7C          mov    si, 0x7C00      ; source
 0x010  BF 00 06          mov    di, 0x0600      ; destination
 0x013  B9 00 01          mov    cx, 0x0100      ; 256 words
 0x016  FC                cld                    ; forward
 0x017  F3 A5             rep    movsw           ; copy 512 bytes
 0x019  EA 1E 06 00 00    jmp    0x0000:0x061E   ; far jump to copy
 .clear:
 0x01E  B8 03 00          mov    ax, 0x0003      ; mode 3 (80×25)
 0x021  CD 10             int    0x10            ; clear screen
 .print:
 0x023  31 DB             xor    bx, bx          ; page 0
 0x025  BE 35 06          mov    si, 0x0635      ; → "REGIUS\0"
 0x028  B4 0E             mov    ah, 0x0E        ; teletype
 .loop:
 0x02A  AC                lodsb                  ; AL = [DS:SI++]
 0x02B  84 C0             test   al, al          ; null?
 0x02D  74 04             jz     .halt           ; → done
 0x02F  CD 10             int    0x10            ; print
 0x031  EB F7             jmp    .loop           ; next
 .halt:
 0x033  EB FE             jmp    $               ; infinite halt
 .msg:
 0x035  52 45 47 49       "REGI"
 0x039  55 53 00          "US\0"
```

<br>

> [!NOTE]
> **Self-relocation** frees `0x7C00` for loading a VBR or Stage 1 from disk.
> Standard MBR pattern — same approach used by MS-DOS, GRUB stage0, and FreeBSD `boot0`.

<br>

---

<a name="roadmap"></a>

## 🗺️ &nbsp; Roadmap

<br>

<table>
<tr><th>Phase</th><th>Task</th><th>Status</th></tr>

<tr>
<td rowspan="7"><b>Stage 0</b><br><sub>MBR</sub></td>
<td>Valid 512-byte MBR with halt-loop stub</td>
<td>✅</td>
</tr>
<tr>
<td>BIOS text output — <code>"REGIUS"</code> via <code>INT 10h</code> AH=0Eh</td>
<td>✅</td>
</tr>
<tr>
<td>Segment register setup (<code>DS</code>, <code>ES</code>, <code>SS:SP</code>)</td>
<td>✅</td>
</tr>
<tr>
<td>MBR self-relocation <code>0x7C00 → 0x0600</code></td>
<td>✅</td>
</tr>
<tr>
<td>Screen clear via <code>INT 10h</code> AH=00h mode 3</td>
<td>✅</td>
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
║     Now it moves.  Now it speaks.               ║
║                                                 ║
╚═════════════════════════════════════════════════╝
</pre>

<br>

**REGIUS** — *because every OS deserves a royal entrance.*

<br>

<sub>Made with raw bytes and bare metal. No frameworks were harmed.</sub>

</div>
