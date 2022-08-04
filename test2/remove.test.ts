import { expect } from "chai";
import { waffle } from "hardhat";
import { TestBokkyPooBahsRedBlackTreeRaw } from "../typechain";
import { createFixture } from "./fixtures";
import { checkConsistency, getKeys } from "./helper";

describe("remove", () => {
  let loadFixture = waffle.createFixtureLoader(waffle.provider.getWallets());
  let fixture;

  let tree: TestBokkyPooBahsRedBlackTreeRaw;

  beforeEach(async () => {
    fixture = await loadFixture(createFixture());
    tree = fixture.tree;
  });

  describe("remove all", () => {
    it("ok", async () => {
      await tree.insert(1);
      await tree.remove(1);
      expect(await getKeys(tree)).to.deep.eq([]);
      await checkConsistency(tree);
    });
  });

  describe("one", () => {
    it("ok", async () => {
      await tree.insert(1);
      await tree.insert(2);
      await tree.remove(1);
      expect(await getKeys(tree)).to.deep.eq([2]);
      await checkConsistency(tree);
    });
  });

  describe("empty", () => {
    it("revert", async () => {
      await expect(tree.remove(0)).to.be.revertedWith("RBTL_R: key is empty");
    });
  });

  describe("not exist", () => {
    it("revert", async () => {
      await expect(tree.remove(1)).to.be.revertedWith("RBTL_R: key not exist");
    });
  });
});
