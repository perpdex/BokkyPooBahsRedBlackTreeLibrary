import { waffle } from "hardhat";
import { TestBokkyPooBahsRedBlackTreeRaw } from "../typechain";
import { createFixture } from "./fixtures";
import { checkConsistency, getKeys } from "./helper";
import { expect } from "chai";
import _ from "lodash";
import MersenneTwister from "mersenne-twister";

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

  describe("random", () => {
    it("ok", async () => {
      const generator = new MersenneTwister(1);

      let keys = [];
      for (let i = 0; i < 100; i++) {
        const op = generator.random_int() % 100;
        if (op < 40) {
          const key = 1 + generator.random_int();
          if (_.includes(keys, key)) continue;
          keys.push(key);
          await tree.insert(key);
        } else if (op < 80) {
          if (_.isEmpty(keys)) continue;
          const idx = generator.random_int() % keys.length;
          const key = keys[idx];
          keys = _.filter(keys, (x) => x != key);
          await tree.remove(key);
        } else {
          if (_.isEmpty(keys)) continue;
          const idx = generator.random_int() % keys.length;
          const key = keys[idx];
          keys = _.filter(keys, (x) => x > key);
          await tree.removeLeft(key);
        }

        expect(await getKeys(tree)).to.deep.eq(_.sortBy(keys));
        await checkConsistency(tree);
      }
    });
  });
});
