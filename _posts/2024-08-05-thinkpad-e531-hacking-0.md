---
title:  "Hacking my Thinkpad Edge E531<br>Part 0: Make someone else do the hard work"
date:   2024-08-05 18:00:00 +0200
tags: 
  - electronics 
  - repair
---

Lenovo is infamously known for building all kinds of hardware allowlists and checks for 'genuine' spare parts into their products.

So when I switched to a newer Wi-Fi card last year the laptop greeted me with a message that it detected a Wi-Fi card that is not allowed and prevented booting.
After the first frustration went away I searched for this problem on the internet and found some shady forum where people could post a request to have this allowlist removed.

I gave it a try and after some minutes I received a message from someone on the forum asking me for product details and what I wanted to be done. Then I was asked for a memory dump of the two BIOS flash chips.
So I disassembled the laptop using a [video on youtube](https://youtube.com/watch?v=Y5mAJS_8cBU) to get access to those chips and read the memory using my FT232H flash programmer.

After sending the dumps it took only a few hours and I received a modified binary back. I flashed it and the laptop booted even with the new Wi-Fi card without problems! Then I sent some bucks their way and could have stopped there.
But then I thought to myself: 'What exactly did they do and did they maybe include some kind of rootkit or backdoor?!'

So how to check that? When comparing the modified binary to the original one many parts were totally different and that made me suspicious.

But what exactly are those binaries? The E531 is equipped with two flash chips. One containing 4 MiB and the other 8 MiB of memory. For modifying the BIOS I only had to flash the smaller one.

When running the `file` command on the two binaries this is what I got:

{% highlight shell %}

>>> file w25q32.bin
w25q32.bin: data
>>> file w25q64.bin
w25q64.bin: Intel serial flash for PCH ROM

{% endhighlight %}

Unfortunately not that much information. The smaller one only got detected as data and the larger one has something to do with Intel.

Next let's see what `binwalk` has to say:


{% highlight shell %}

>>> binwalk w25q32.bin

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             UEFI PI Firmware Volume, volume size: 2818048, header size: 0, revision: 0, EFI Firmware File System, GUID: 7A9354D9-0468-444A-CE81-0BF617D890DF
2818048       0x2B0000        UEFI PI Firmware Volume, volume size: 397312, header size: 0, revision: 0, Variable Storage, GUID: FFF12B8D-7696-4C8B-85A9-2747075B4F50
2822144       0x2B1000        Intel x86 or x64 microcode, sig 0x000206a7, pf_mask 0x12, 2018-04-10, rev 0x002e, size 12288
2834432       0x2B4000        Intel x86 or x64 microcode, sig 0x000306a4, pf_mask 0x12, 2011-09-08, rev 0x0007, size 9216
2843648       0x2B6400        Intel x86 or x64 microcode, sig 0x000306a5, pf_mask 0x12, 2011-09-09, rev 0x0007, size 9216
2852864       0x2B8800        Intel x86 or x64 microcode, sig 0x000306a6, pf_mask 0x12, 2011-08-31, rev 0x0002, size 6144
2852883       0x2B8813        ESP Image (ESP32): segment count: 1, flash mode: QUIO, flash speed: 40MHz, flash size: 1MB, entry address: 0x1200
2859008       0x2BA000        Intel x86 or x64 microcode, sig 0x000306a8, pf_mask 0x12, 2012-02-20, rev 0x0010, size 10240
2869248       0x2BC800        Intel x86 or x64 microcode, sig 0x000306a9, pf_mask 0x12, 2018-04-10, rev 0x0020, size 13312
2987430       0x2D95A6        Certificate in DER format (x509 v3), header length: 4, sequence length: 1495
...

{% endhighlight %}

This is much more interesting! UEFI sounds familiar.

Of course I knew about the high level difference between UEFI and BIOS from an end-user perspective.
And from a bit of research I learned that **U**nified **E**xtensible **F**irmware **I**nterface is just a specification of the firmware architecture and the interface to the operating system.
Then I stumbled upon a powerful utility called [UEFITool](https://github.com/LongSoft/UEFITool) that is able to open UEFI firmware files, extract parts and even change stuff and repack it again.

After opening the firmware file I was greeted by some kind of tree view.

![Screenshot of UEFItool where you can see a tree view where an element labeled 'Compressed section' is highlighted](/assets/images/uefitool_screenshot_overview.png)

Alright, compression! That's why there were that much differences between the modified and the original firmware file.
So after decompression of both files and another go at comparing the two there where only a few bytes different.

In the end I was quite sure that there was no hidden malware inside the modified firmware image.

So I was happy and got on with my life but it did not last for long!

Stay tuned for **Part 1: An evil battery**.
