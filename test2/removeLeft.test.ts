import { expect } from "chai"
import { waffle } from "hardhat"
import { TestBokkyPooBahsRedBlackTreeRaw } from "../typechain"
import { createFixture } from "./fixtures"
import _ from "lodash"

describe("removeLeft", () => {
    let loadFixture = waffle.createFixtureLoader(waffle.provider.getWallets())
    let fixture

    let tree: TestBokkyPooBahsRedBlackTreeRaw
    let reference

    beforeEach(async () => {
        fixture = await loadFixture(createFixture())
        tree = fixture.tree
        reference = []
    })

    const checkConsistency = async () => {
        const sorted = _.sortBy(reference, _.identity)
        const result = []
        let key = await tree.first();
        result.push(key)
        while (true) {
            // expect(key).to.eq(sorted[i])
            key = await tree.next(key)
            if (key.eq(0)) break
            result.push(key)
        }
        expect(result).to.eq(sorted)
    }

    describe("one", () => {
        it("ok", async () => {
            reference = [1, 2, 3, 8, 5, 4, 7, 6]
            for (let i = 0; i < reference.length; i++) {
                await tree.insert(reference[i])
            }
            await tree.removeLeft(4);
            reference = [8, 5, 7, 6]
            await checkConsistency();
        })
    })
})
