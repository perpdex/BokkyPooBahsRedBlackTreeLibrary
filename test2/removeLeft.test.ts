import { expect } from "chai";
import { waffle } from "hardhat";
import { TestBokkyPooBahsRedBlackTreeRaw } from "../typechain";
import { createFixture } from "./fixtures";
import _ from "lodash";
import { checkConsistency, getKeys } from "./helper";

describe("removeLeft", () => {
  let loadFixture = waffle.createFixtureLoader(waffle.provider.getWallets());
  let fixture;

  let tree: TestBokkyPooBahsRedBlackTreeRaw;

  beforeEach(async () => {
    fixture = await loadFixture(createFixture());
    tree = fixture.tree;
  });

  describe("normal", () => {
    it("ok", async () => {
      const keys = _.range(1, 100);
      await tree.insertBulk(keys);
      await tree.removeLeft(10);
      expect(await getKeys(tree)).to.deep.eq(_.range(11, 100));
      await checkConsistency(tree);
    });
  });
});
