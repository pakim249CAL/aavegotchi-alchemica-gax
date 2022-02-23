import { BigNumber } from "ethers";

export const GWEI = BigNumber.from(1e9);
export const ETHER = GWEI.mul(GWEI);
export const YEAR = 60 * 60 * 24 * 365;

export const FUD_MAX_SUPPLY = BigNumber.from(1e11).mul(ETHER);
export const FOMO_MAX_SUPPLY = BigNumber.from(5e10).mul(ETHER);
export const ALPHA_MAX_SUPPLY = BigNumber.from(25e9).mul(ETHER);
export const KEK_MAX_SUPPLY = BigNumber.from(1e10).mul(ETHER);