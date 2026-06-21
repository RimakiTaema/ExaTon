"use client";

import { createContext, useContext } from "react";

type LayoutCtxValue = {
  isServerDetail: boolean;
  setIsServerDetail: (v: boolean) => void;
};

export const LayoutCtx = createContext<LayoutCtxValue>({
  isServerDetail: false,
  setIsServerDetail: () => {},
});

export const useLayoutCtx = () => useContext(LayoutCtx);
