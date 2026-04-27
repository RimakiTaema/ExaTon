export type CreditDisplay = "personal" | "pool" | "both";

const STORAGE_KEY = "exaton_credit_display";
const DEFAULT: CreditDisplay = "both";

export function loadCreditDisplay(): CreditDisplay {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw === "personal" || raw === "pool" || raw === "both") return raw;
  } catch {
    /* private mode / unavailable */
  }
  return DEFAULT;
}

export function saveCreditDisplay(mode: CreditDisplay): void {
  try {
    localStorage.setItem(STORAGE_KEY, mode);
  } catch {
    /* non-fatal */
  }
}
