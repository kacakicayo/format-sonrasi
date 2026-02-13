const packages = [
  { id: "vc", name: "Visual C++ Redistributables", desc: "Uygulama uyumluluk paketleri" },
  { id: "netfx", name: ".NET Framework", desc: "Eski uygulama desteği" },
  { id: "net", name: ".NET Desktop Runtime", desc: "Modern masaüstü uygulamalar" },
  { id: "dx", name: "DirectX Runtime", desc: "Grafik ve multimedya" },
  { id: "driver", name: "Ekran Kartı Sürücüsü", desc: "AMD veya NVIDIA seçimi" },
  { id: "java", name: "Java Runtime", desc: "Java tabanlı uygulamalar" },
  { id: "winrar", name: "WinRAR", desc: "Arşiv yöneticisi" },
  { id: "chrome", name: "Google Chrome", desc: "Eski / Yeni sürüm seçimi" }
];

const packageState = Object.fromEntries(
  packages.map((pkg) => [pkg.id, { profile: "", fileName: "Dosya seçilmedi" }])
);
packageState.driver.profile = "nvidia";
packageState.chrome.profile = "yeni";

const list = document.getElementById("packageList");
const statusLine = document.getElementById("statusLine");
const barFill = document.getElementById("barFill");
const installBtn = document.getElementById("installBtn");
const selectAllBtn = document.getElementById("selectAll");
const editBtn = document.getElementById("editBtn");
const logs = document.getElementById("logs");
const logo = document.getElementById("logo");
const logoFallback = document.getElementById("logoFallback");
const logoFull = document.getElementById("logoFull");

let selected = new Set(packages.map((pkg) => pkg.id));
let editMode = false;

logo.addEventListener("error", () => {
  logo.style.display = "none";
  if (logoFull) {
    logoFull.classList.remove("hidden");
  } else {
    logoFallback.style.display = "block";
  }
});

if (logoFull) {
  logoFull.addEventListener("error", () => {
    logoFull.style.display = "none";
    logoFallback.style.display = "block";
  });
}

function logLine(message) {
  const time = new Date().toLocaleTimeString("tr-TR", { hour12: false });
  logs.textContent += `[${time}] ${message}\n`;
  logs.scrollTop = logs.scrollHeight;
}

function controlsTemplate(pkg) {
  const state = packageState[pkg.id];
  const profileControl = pkg.id === "driver"
    ? `<select data-role="profile" data-id="driver" class="pill"><option value="nvidia" ${state.profile === "nvidia" ? "selected" : ""}>NVIDIA</option><option value="amd" ${state.profile === "amd" ? "selected" : ""}>AMD</option></select>`
    : pkg.id === "chrome"
      ? `<select data-role="profile" data-id="chrome" class="pill"><option value="yeni" ${state.profile === "yeni" ? "selected" : ""}>Yeni Sürüm</option><option value="eski" ${state.profile === "eski" ? "selected" : ""}>Eski Sürüm</option></select>`
      : "";

  return `
    <div class="right-tools ${editMode ? "" : "hidden"}">
      ${profileControl}
      <button class="file-btn pill" data-role="file" data-id="${pkg.id}">Dosya Seç</button>
      <input type="file" accept=".exe,.msi" data-role="input" data-id="${pkg.id}" style="display:none" />
    </div>
  `;
}

function render() {
  list.innerHTML = "";

  packages.forEach((pkg) => {
    const active = selected.has(pkg.id);
    const card = document.createElement("article");
    card.className = `pkg ${active ? "active" : ""} ${editMode ? "editable" : ""}`;
    card.innerHTML = `
      <div class="left-content">
        <div class="pkg-title">${pkg.name}</div>
        <div class="pkg-desc">${pkg.desc}</div>
        <div class="file-name" title="${packageState[pkg.id].fileName}">Seçili dosya: ${packageState[pkg.id].fileName}</div>
      </div>
      <div class="right-content">
        ${controlsTemplate(pkg)}
        <div class="check">${active ? "✓" : ""}</div>
      </div>
    `;

    card.addEventListener("click", (event) => {
      if (event.target.closest("[data-role]")) return;
      if (selected.has(pkg.id)) selected.delete(pkg.id);
      else selected.add(pkg.id);
      render();
    });

    list.appendChild(card);
  });

  list.querySelectorAll('[data-role="file"]').forEach((btn) => {
    btn.addEventListener("click", (event) => {
      const id = event.currentTarget.dataset.id;
      const input = list.querySelector(`[data-role="input"][data-id="${id}"]`);
      if (input) input.click();
    });
  });

  list.querySelectorAll('[data-role="input"]').forEach((input) => {
    input.addEventListener("change", (event) => {
      const id = event.currentTarget.dataset.id;
      const file = event.currentTarget.files?.[0];
      if (!file) return;
      packageState[id].fileName = file.name;
      logLine(`${packages.find((p) => p.id === id).name} için dosya seçildi: ${file.name}`);
      render();
    });
  });

  list.querySelectorAll('[data-role="profile"]').forEach((select) => {
    select.addEventListener("change", (event) => {
      const id = event.currentTarget.dataset.id;
      packageState[id].profile = event.currentTarget.value;
      logLine(`${packages.find((p) => p.id === id).name} seçeneği: ${event.currentTarget.value.toUpperCase()}`);
    });
  });

  installBtn.textContent = `Seçilenleri Kur (${selected.size})`;
  editBtn.textContent = editMode ? "Düzenlemeyi Kapat" : "Düzenle";
}

function wait(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function packageDetail(pkg) {
  const state = packageState[pkg.id];
  if (pkg.id === "driver") return ` [${state.profile.toUpperCase()}]`;
  if (pkg.id === "chrome") return ` [${state.profile === "eski" ? "ESKİ" : "YENİ"}]`;
  return "";
}

async function install() {
  if (selected.size === 0) {
    statusLine.textContent = "Durum: Lütfen en az bir paket seç.";
    logLine("Kurulum başlatılamadı: seçim yok.");
    return;
  }

  installBtn.disabled = true;
  selectAllBtn.disabled = true;
  statusLine.textContent = "Durum: Kurulum başlatıldı...";

  const selectedPackages = packages.filter((pkg) => selected.has(pkg.id));
  let done = 0;

  for (const pkg of selectedPackages) {
    const fileInfo = packageState[pkg.id].fileName !== "Dosya seçilmedi"
      ? ` | Dosya: ${packageState[pkg.id].fileName}`
      : " | Dosya: varsayılan";

    logLine(`Kuruluyor: ${pkg.name}${packageDetail(pkg)}${fileInfo}`);
    await wait(550);
    done += 1;
    barFill.style.width = `${Math.round((done / selectedPackages.length) * 100)}%`;
    logLine(`Kuruldu: ${pkg.name}${packageDetail(pkg)}`);
  }

  statusLine.textContent = "Durum: Kurulum tamamlandı ✔";
  logLine("Tüm seçili paketlerin kurulumu tamamlandı.");
  installBtn.disabled = false;
  selectAllBtn.disabled = false;
}

selectAllBtn.addEventListener("click", () => {
  selected = new Set(packages.map((pkg) => pkg.id));
  render();
  logLine("Tüm paketler seçildi.");
});

editBtn.addEventListener("click", () => {
  editMode = !editMode;
  render();
  logLine(editMode ? "Düzenleme modu açıldı." : "Düzenleme modu kapatıldı.");
});

installBtn.addEventListener("click", install);

render();
logLine("Arayüz hazır.");
logLine("Not: Tarayıcı güvenliği nedeniyle doğrudan installers klasörü okunamaz; dosya seçim butonuyla eşleştirme yapılır.");
