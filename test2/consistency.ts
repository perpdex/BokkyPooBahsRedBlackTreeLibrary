import { expect } from "chai"
import { waffle } from "hardhat"
import { TestBokkyPooBahsRedBlackTreeRaw } from "../typechain"
import { createFixture } from "./fixtures"
import _ from "lodash"

describe("consistency", () => {
    let loadFixture = waffle.createFixtureLoader(waffle.provider.getWallets())
    let fixture

    let tree: TestBokkyPooBahsRedBlackTreeRaw
    let reference

    beforeEach(async () => {
        fixture = await loadFixture(createFixture())
        tree = fixture.tree
        reference = []
    })

    const checkNode = async (node) => {
        const {left, right, red} = await tree.getNode(node)
        let leftBlackHeight = 1
        let rightBlackHeight = 1
        if (!left.eq(0)) {
            const leftNode = await tree.getNode(left)
            if (red) {
                expect(leftNode.red).to.eq(false)
            }
            expect(leftNode.parent).to.eq(node)
            const leftRes = await checkNode(left)
            leftBlackHeight = leftRes.blackHeight
            expect(leftBlackHeight).to.eq(leftNode.blackHeight)
        }
        if (!right.eq(0)) {
            const rightNode = await tree.getNode(right)
            if (red) {
                expect(rightNode.red).to.eq(false)
            }
            expect(rightNode.parent).to.eq(node)
            const rightRes = await checkNode(right)
            rightBlackHeight = rightRes.blackHeight
            // console.log(rightBlackHeight)
            // console.log(rightNode)
            expect(rightBlackHeight).to.eq(rightNode.blackHeight)
        }
        expect(leftBlackHeight).to.eq(rightBlackHeight)
        return {
            blackHeight: leftBlackHeight + (red ? 0 : 1)
        }
    }

    const checkRedBlackConditions = async () => {
        const root = await tree.root()
        await checkNode(root)

        // const nodes = [root]
        // while (nodes.length > 0) {
        //     const node = nodes.shift()
        //     const {parent, left, right, red} = await tree.getNode(node)
        //     if (!left.eq(0)) {
        //         const leftNode = await tree.getNode(left)
        //         if (red) {
        //             expect(leftNode.red).to.eq(false)
        //         }
        //         expect(leftNode.parent).to.eq(node)
        //         nodes.push(left)
        //     }
        //     if (!left.eq(0)) {
        //         const rightNode = await tree.getNode(right)
        //         if (red) {
        //             expect(rightNode.red).to.eq(false)
        //         }
        //         expect(rightNode.parent).to.eq(node)
        //         nodes.push(right)
        //     }
        // }
    }

    const checkConsistency = async () => {
        const sorted = _.sortBy(reference, _.identity)
        let key = await tree.first();
        for (let i = 0; i < sorted.length; i++) {
            expect(key).to.eq(sorted[i])
            key = await tree.next(key)
        }

        await checkRedBlackConditions()
    }

    describe("insert", () => {
        it("ok", async () => {
            reference = [1, 2, 3, 8, 5, 4, 7, 6]
            for (let i = 0; i < reference.length; i++) {
                await tree.insert(reference[i])
            }
            await checkConsistency();
        })
    })

    describe("insert and remove", () => {
        it("ok", async () => {
            const ops = [
                1, 2, 3, 8,
                -3, -1,
                5, 4, 7, 6,
                -4
            ]
            reference = [2, 8, 5, 7, 6]
            for (let i = 0; i < ops.length; i++) {
                if (ops[i] > 0) {
                    await tree.insert(ops[i])
                } else {
                    await tree.remove(-ops[i])
                }
            }
            await checkConsistency();
        })
    })
})
