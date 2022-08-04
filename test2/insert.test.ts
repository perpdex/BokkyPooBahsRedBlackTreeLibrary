import { expect } from "chai";
import { waffle } from "hardhat";
import { TestBokkyPooBahsRedBlackTreeRaw } from "../typechain";
import { createFixture } from "./fixtures";

describe("insert", () => {
  let loadFixture = waffle.createFixtureLoader(waffle.provider.getWallets());
  let fixture;

  let tree: TestBokkyPooBahsRedBlackTreeRaw;

  beforeEach(async () => {
    fixture = await loadFixture(createFixture());
    tree = fixture.tree;
  });

  describe("one", () => {
    it("ok", async () => {
      await tree.insert(1);
      expect(await tree.first()).to.eq(1);
    });
  });

  describe("two", () => {
    it("ok", async () => {
      await tree.insert(2);
      await tree.insert(1);
      expect(await tree.first()).to.eq(1);
      expect(await tree.last()).to.eq(2);
    });
  });
});
