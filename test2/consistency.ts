import { waffle } from "hardhat";
import { TestBokkyPooBahsRedBlackTreeRaw } from "../typechain";
import { createFixture } from "./fixtures";
import { checkConsistency, getKeys } from "./helper";
import { expect } from "chai";
import _ from "lodash";

describe("consistency", () => {
  let loadFixture = waffle.createFixtureLoader(waffle.provider.getWallets());
  let fixture;

  let tree: TestBokkyPooBahsRedBlackTreeRaw;

  beforeEach(async () => {
    fixture = await loadFixture(createFixture());
    tree = fixture.tree;
  });

  describe("insert", () => {
    it("ok", async () => {
      const keys = [1, 2, 3, 8, 5, 4, 7, 6];
      for (let i = 0; i < keys.length; i++) {
        await tree.insert(keys[i]);
      }
      expect(await getKeys(tree)).to.deep.eq(_.sortBy(keys));
      await checkConsistency(tree);
    });
  });

  describe("insert and remove", () => {
    it("ok", async () => {
      const ops = [1, 2, 3, 8, -3, -1, 5, 4, 7, 6, -4];
      for (let i = 0; i < ops.length; i++) {
        if (ops[i] > 0) {
          await tree.insert(ops[i]);
        } else {
          await tree.remove(-ops[i]);
        }
      }
      expect(await getKeys(tree)).to.deep.eq(_.sortBy([2, 8, 5, 7, 6]));
      await checkConsistency(tree);
    });
  });
});
