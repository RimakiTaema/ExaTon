export type CreditDisplay = "personal" | "pool" | "both";
export type LayoutMode = "sidebar" | "topbar";

const CREDIT_KEY = "exaton_credit_display";
const LAYOUT_KEY = "exaton_layout_mode";
const CREDIT_DEFAULT: CreditDisplay = "both";
const LAYOUT_DEFAULT: LayoutMode = "topbar";

export function loadCreditDisplay(): CreditDisplay {
  try {
    const raw = localStorage.getItem(CREDIT_KEY);
    if (raw === "personal" || raw === "pool" || raw === "both") return raw;
  } catch {
    /* private mode / unavailable */
  }
  return CREDIT_DEFAULT;
}

export function saveCreditDisplay(mode: CreditDisplay): void {
  try {
    localStorage.setItem(CREDIT_KEY, mode);
  } catch {
    /* non-fatal */
  }
}

export function loadLayoutMode(): LayoutMode {
  try {
    const raw = localStorage.getItem(LAYOUT_KEY);
    if (raw === "sidebar" || raw === "topbar") return raw;
  } catch {
    /* private mode / unavailable */
  }
  return LAYOUT_DEFAULT;
}

export function saveLayoutMode(mode: LayoutMode): void {
  try {
    localStorage.setItem(LAYOUT_KEY, mode);
    window.dispatchEvent(new CustomEvent("layout-mode-changed", { detail: mode }));
  } catch {
    /* non-fatal */
  }
}
