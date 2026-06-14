<div align="center">

<img width="100%" src="https://capsule-render.vercel.app/api?type=venom&color=0:0d1117,50:001a33,100:0066cc&height=200&section=header&text=SELF-VPN&fontSize=80&fontColor=00aaff&fontAlignY=55&desc=Self-Hosted%20WireGuard%20VPN%20%7C%20Your%20Own%20NordVPN&descSize=16&descAlignY=75&descColor=ffffff&animation=twinkling" />

<br/>

![WireGuard](https://img.shields.io/badge/WireGuard-Powered-88171A?style=for-the-badge&logo=wireguard&logoColor=white&labelColor=0d1117)
![Shell](https://img.shields.io/badge/Shell-Script-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white&labelColor=0d1117)
![Linux](https://img.shields.io/badge/Linux-Compatible-FCC624?style=for-the-badge&logo=linux&logoColor=black&labelColor=0d1117)
![Privacy](https://img.shields.io/badge/Privacy-First-0066cc?style=for-the-badge&logo=protonvpn&logoColor=white&labelColor=0d1117)
![License](https://img.shields.io/badge/License-MIT-00aaff?style=for-the-badge&labelColor=0d1117)

<br/>

```
 ██╗   ██╗██████╗ ███╗   ██╗    ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗
 ██║   ██║██╔══██╗████╗  ██║    ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗
 ██║   ██║██████╔╝██╔██╗ ██║    ███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝
 ╚██╗ ██╔╝██╔═══╝ ██║╚██╗██║    ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗
  ╚████╔╝ ██║     ██║ ╚████║    ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║
   ╚═══╝  ╚═╝     ╚═╝  ╚═══╝    ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝
                        [ Own Your Privacy. Own Your Tunnel. ]
```

[![Stars](https://img.shields.io/github/stars/WHITEDECVIL/self-vpn?style=for-the-badge&color=00aaff&labelColor=0d1117)](https://github.com/WHITEDECVIL/self-vpn/stargazers)
[![Forks](https://img.shields.io/github/forks/WHITEDECVIL/self-vpn?style=for-the-badge&color=00aaff&labelColor=0d1117)](https://github.com/WHITEDECVIL/self-vpn/network)
[![Last Commit](https://img.shields.io/github/last-commit/WHITEDECVIL/self-vpn?style=for-the-badge&color=00aaff&labelColor=0d1117)](https://github.com/WHITEDECVIL/self-vpn/commits)

</div>

---

## 🔐 What is Self-VPN?

**Self-VPN** is a one-script solution to deploy your own private VPN server using [WireGuard](https://www.wireguard.com/) — the fastest, most modern VPN protocol available. No subscriptions. No data logs. No third parties. Just a tunnel you own.

> Think NordVPN, but **you** are Nord.

---

## ✨ Features

<table>
<tr>
<td width="50%">

**⚡ Performance**
- WireGuard — fastest modern VPN protocol
- BBR congestion control + `fq` queueing
- Kernel-level encryption (ChaCha20)
- Low overhead, minimal battery drain

</td>
<td width="50%">

**🔒 Security**
- Auto-generates server & client key pairs
- NAT + packet forwarding firewall rules
- Per-client IP isolation
- Key rotation support

</td>
</tr>
<tr>
<td width="50%">

**📱 Multi-Client**
- Add unlimited clients
- QR code generation for mobile
- Works on Android, iOS, Linux, Windows, macOS
- Each client gets a unique tunnel IP

</td>
<td width="50%">

**🛠️ Automation**
- One-script full server setup
- Auto-configures sysctl for best perf
- Systemd service integration
- Ready-to-use client `.conf` files

</td>
</tr>
</table>

---

## ⚡ Quick Start

### Step 1 — Clone the repo

```bash
git clone https://github.com/WHITEDECVIL/self-vpn.git
cd self-vpn
```

### Step 2 — Run the setup script

```bash
chmod +x setup-vpn-node.sh
sudo ./setup-vpn-node.sh
```

**The script automatically:**

```
┌─ Installs WireGuard & tools
├─ Configures sysctl (BBR, fq, IP forwarding)
├─ Creates /etc/wireguard/wg0.conf (server config)
├─ Generates client key pair
├─ Creates client1.conf (ready to use)
└─ Outputs QR code for mobile import
```

---

## 🔑 Key Generation

The setup script handles this automatically. For manual key creation:

```bash
# ── Server Keys ──────────────────────────────
wg genkey | tee server_private.key | wg pubkey > server_public.key

# ── Client Keys ──────────────────────────────
wg genkey | tee client_private.key | wg pubkey > client_public.key
```

| Key File | Where It Goes |
|---|---|
| `server_private.key` | Server `[Interface]` block |
| `server_public.key` | Client `[Peer]` block |
| `client_private.key` | Client `[Interface]` block |
| `client_public.key` | Server `[Peer]` block |

---

## 📝 Configuration

### Server — `/etc/wireguard/wg0.conf`

```ini
[Interface]
PrivateKey = <server_private.key contents>
Address    = 10.8.0.1/24
ListenPort = 51820
SaveConfig = true

[Peer]
# Client 1
PublicKey  = <client1_public.key contents>
AllowedIPs = 10.8.0.2/32
```

### Client — `client1.conf`

```ini
[Interface]
PrivateKey = <client1_private.key contents>
Address    = 10.8.0.2/24
DNS        = 1.1.1.1

[Peer]
PublicKey         = <server_public.key contents>
Endpoint          = YOUR_SERVER_IP:51820
AllowedIPs        = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
```

---

## 👥 Adding More Clients

Repeat for each new client — change the IP `.3`, `.4`, `.5`... etc.

**① Generate new key pair**
```bash
wg genkey | tee client2_private.key | wg pubkey > client2_public.key
```

**② Add to server config**
```ini
[Peer]
# Client 2
PublicKey  = <client2_public.key>
AllowedIPs = 10.8.0.3/32
```

**③ Create client config**
```ini
[Interface]
PrivateKey = <client2_private.key>
Address    = 10.8.0.3/24
DNS        = 1.1.1.1

[Peer]
PublicKey           = <server_public.key>
Endpoint            = YOUR_SERVER_IP:51820
AllowedIPs          = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
```

**④ Restart WireGuard**
```bash
sudo systemctl restart wg-quick@wg0
```

---

## ▶️ Start / Stop the VPN

### On the Server

```bash
# Enable on boot + start now
sudo systemctl enable --now wg-quick@wg0

# Stop
sudo wg-quick down wg0

# Check status
sudo wg show
```

### On the Client

```bash
# Connect
wg-quick up client1.conf

# Disconnect
wg-quick down client1.conf
```

---

## 📱 Mobile Setup

```bash
# Generate QR code in terminal
qrencode -t ansiutf8 < client1.conf
```

Then on your phone:

```
1. Install WireGuard app (Android / iOS)
2. Tap  +  →  Scan QR Code
3. Point camera at terminal QR
4. Tap  Activate  — done ✅
```

---

## ✅ Verify Your Tunnel

After connecting on the client, run:

```bash
curl ifconfig.me
```

If it returns your **VPS server IP** instead of your home IP — the tunnel is working. 🎯

---

## 🗺️ Network Topology

```
  [ Your Device ]                    [ Your VPS ]
  ┌─────────────┐    WireGuard       ┌──────────────────┐
  │ client1.conf│◄──── tunnel ──────►│  wg0  10.8.0.1   │
  │ 10.8.0.2/24 │    port 51820      │  NAT + Forwarding │
  └─────────────┘                    └────────┬─────────┘
                                              │
                                     ┌────────▼─────────┐
                                     │    The Internet   │
                                     │  (your IP hidden) │
                                     └───────────────────┘
```

---

## ⚠️ Important Notes

> 🔁 **Unique IPs** — Every client must have a different tunnel IP: `10.8.0.2`, `10.8.0.3`, `10.8.0.4`...

> 🌐 **Server IP** — Replace `YOUR_SERVER_IP` in all client configs with your VPS public IP.

> 🔑 **Compromised key?** — Regenerate with `wg genkey` and replace in both server and client configs, then restart.

> 🔓 **Ports** — Make sure UDP port `51820` is open in your VPS firewall / security group.

---

## 👤 Author

<div align="center">

**Sanjay S** — *Red Teamer · Security Researcher · Privacy Advocate*

[![GitHub](https://img.shields.io/badge/GitHub-WHITEDECVIL-181717?style=for-the-badge&logo=github&logoColor=white&labelColor=0d1117)](https://github.com/WHITEDECVIL)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Sanjay_S-0077B5?style=for-the-badge&logo=linkedin&logoColor=white&labelColor=0d1117)](https://linkedin.com/in/sanjay-s)
[![Email](https://img.shields.io/badge/Gmail-sankicju@gmail.com-D14836?style=for-the-badge&logo=gmail&logoColor=white&labelColor=0d1117)](mailto:sankicju@gmail.com)

</div>

---

<div align="center">

*"Privacy is not something that I'm merely entitled to, it's an absolute prerequisite."* — Marlon Brando

<img width="100%" src="https://capsule-render.vercel.app/api?type=waving&color=0:0066cc,100:001a33&height=100&section=footer" />

</div>
