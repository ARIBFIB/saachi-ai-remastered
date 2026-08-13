import type { ThemeConfig } from "antd";
import { tokens } from "./tokens";

/**
 * Ant Design theme -- fully derived from tokens.ts.
 * Do NOT hardcode colors here. Change tokens.ts instead.
 */
export const antdTheme: ThemeConfig = {
  token: {
    colorPrimary: tokens.color.primary,
    colorPrimaryHover: tokens.color.primaryHover,
    colorSuccess: tokens.color.success,
    colorError: tokens.color.error,
    colorWarning: tokens.color.warning,
    colorText: tokens.color.ink,
    colorTextSecondary: tokens.color.inkSoft,
    colorTextTertiary: tokens.color.textMuted,
    colorBgBase: tokens.color.surface,
    colorBgLayout: tokens.color.bg,
    colorBorder: tokens.color.border,
    borderRadius: parseInt(tokens.radius.md),
    borderRadiusLG: parseInt(tokens.radius.lg),
    borderRadiusSM: parseInt(tokens.radius.sm),
    fontFamily: tokens.font.family,
    fontSize: parseInt(tokens.font.size.sm)
  },
  components: {
    Button: {
      borderRadius: parseInt(tokens.radius.md),
      controlHeight: 44,
      fontWeight: tokens.font.weight.semibold
    },
    Input: {
      borderRadius: parseInt(tokens.radius.md),
      controlHeight: 44
    },
    Card: {
      borderRadiusLG: parseInt(tokens.radius.xl)
    },
    Tag: {
      borderRadiusSM: parseInt(tokens.radius.sm)
    }
  }
};