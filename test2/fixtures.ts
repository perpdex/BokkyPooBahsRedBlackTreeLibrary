import { ethers } from "hardhat";
import { TestBokkyPooBahsRedBlackTreeRaw } from "../typechain";

export interface Fixture {
  tree: TestBokkyPooBahsRedBlackTreeRaw;
}

interface Params {}

export function createFixture(
  params: Params = {}
): (wallets, provider) => Promise<Fixture> {
  return async ([], provider): Promise<Fixture> => {
    const factory = await ethers.getContractFactory(
      "TestBokkyPooBahsRedBlackTreeRaw"
    );
    const tree = (await factory.deploy()) as TestBokkyPooBahsRedBlackTreeRaw;

    return {
      tree,
    };
  };
}
