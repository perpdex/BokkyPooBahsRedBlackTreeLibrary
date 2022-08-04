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
        while (!key.eq(0)) {
            console.log(key)
            result.push(key)
            key = await tree.next(key)
        }
        expect(result).to.deep.eq(sorted)
    }

    describe("one", () => {
        it("ok", async () => {
            // reference = [1, 2, 3, 8, 5, 4, 7, 6]
            reference = _.range(1, 1000)
            // reference = [1, 8, 5]
            for (let i = 0; i < reference.length; i++) {
                await tree.insert(reference[i])
            }
            console.log('removeLeft start')
            await tree.removeLeft(1);
            await tree.removeLeft(2);
            await tree.removeLeft(3);
            await tree.removeLeft(1);
            console.log('removeLeft finished')
            console.log(await tree.root())
            console.log(await tree.getNode(5))
            console.log(await tree.getNode(6))
            console.log(await tree.getNode(7))
            console.log(await tree.getNode(8))
            reference = _.filter(reference, (x) => x > 1)
            // reference = [8, 5, 7, 6]
            // reference = [5, 8]
            await checkConsistency();
        })
    })
})
