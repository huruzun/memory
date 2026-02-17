const galleryEl = document.getElementById("gallery");
const emptyStateEl = document.getElementById("emptyState");
const photoCountEl = document.getElementById("photoCount");
const lastUpdatedEl = document.getElementById("lastUpdated");

const lightbox = document.getElementById("lightbox");
const lightboxImg = document.getElementById("lightboxImg");
const lightboxCaption = document.getElementById("lightboxCaption");
const lightboxClose = document.getElementById("lightboxClose");

function formatDate(value) {
  if (!value) return "—";
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) return String(value);
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

function normalizeCaption(photo) {
  if (photo.caption && String(photo.caption).trim()) return String(photo.caption).trim();
  if (!photo.src) return "";
  const name = String(photo.src).split("/").pop() ?? "";
  const base = name.replace(/\.[a-z0-9]+$/i, "");
  return base.replace(/[_-]+/g, " ").trim();
}

function openLightbox(photo) {
  const caption = normalizeCaption(photo);
  lightboxImg.src = photo.src;
  lightboxImg.alt = caption || "照片";
  lightboxCaption.textContent = caption || "";
  if (typeof lightbox.showModal === "function") {
    lightbox.showModal();
  } else {
    window.open(photo.src, "_blank", "noopener,noreferrer");
  }
}

function closeLightbox() {
  if (typeof lightbox.close === "function") lightbox.close();
  lightboxImg.removeAttribute("src");
  lightboxImg.alt = "";
  lightboxCaption.textContent = "";
}

function buildCard(photo) {
  const button = document.createElement("button");
  button.type = "button";
  button.className = "card";
  button.setAttribute("role", "listitem");

  const img = document.createElement("img");
  img.className = "card__img";
  img.loading = "lazy";
  img.decoding = "async";
  img.src = photo.src;
  img.alt = normalizeCaption(photo) || "照片";

  const body = document.createElement("div");
  body.className = "card__body";

  const caption = document.createElement("p");
  caption.className = "card__caption";
  caption.textContent = normalizeCaption(photo) || " ";

  const meta = document.createElement("div");
  meta.className = "card__meta";

  const date = document.createElement("span");
  date.textContent = formatDate(photo.date);

  const place = document.createElement("span");
  place.textContent = photo.place ? String(photo.place) : "";

  meta.append(date, place);
  body.append(caption, meta);
  button.append(img, body);

  button.addEventListener("click", () => openLightbox(photo));
  return button;
}

async function loadGallery() {
  const res = await fetch("./gallery.json", { cache: "no-store" });
  if (!res.ok) throw new Error(`加载 gallery.json 失败：${res.status}`);
  return res.json();
}

function renderGallery(data) {
  const photos = Array.isArray(data?.photos) ? data.photos : [];
  const updatedAt = data?.updated_at ?? data?.updatedAt ?? null;

  photoCountEl.textContent = String(photos.length);
  lastUpdatedEl.textContent = formatDate(updatedAt);

  galleryEl.replaceChildren();

  if (photos.length === 0) {
    emptyStateEl.hidden = false;
    return;
  }
  emptyStateEl.hidden = true;

  const sorted = [...photos].sort((a, b) => {
    const ad = a?.date ? new Date(a.date).getTime() : 0;
    const bd = b?.date ? new Date(b.date).getTime() : 0;
    return bd - ad;
  });

  const cards = sorted.map(buildCard);
  galleryEl.append(...cards);
}

async function main() {
  try {
    const data = await loadGallery();
    renderGallery(data);
  } catch (e) {
    photoCountEl.textContent = "—";
    lastUpdatedEl.textContent = "—";
    emptyStateEl.hidden = false;
  }
}

lightboxClose.addEventListener("click", closeLightbox);
lightbox.addEventListener("click", (e) => {
  if (e.target === lightbox) closeLightbox();
});
document.addEventListener("keydown", (e) => {
  if (e.key === "Escape") closeLightbox();
});

main();
